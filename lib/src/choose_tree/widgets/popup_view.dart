import 'dart:async';
import 'package:flutter/material.dart';
import '../../model/index.dart';
import '../src/tree_node.dart';
import '../src/tree_select_config.dart';
import '../../widgets/input_search.dart';
import 'header_info.dart';
import 'bottom_action.dart';
import 'tree_structure.dart';

/// 单选确认回调 typedef
typedef SingleConfirmCallback<ID, DATA> = void Function(List<TreeNode> selected);

/// 多选确认回调 typedef
typedef MultiConfirmCallback<ID, DATA> = void Function(List<TreeNode> selected);

/// 弹窗模式视图 - 用于显示弹窗选择器
class TreeSelectPopup<ID, DATA extends Map<String, dynamic>> {
  /// 配置
  final TreeSelectConfig config;

  /// 树节点数据
  final List<TreeNode> nodes;

  /// 已选中的节点
  final List<TreeNode> selectedNodes;

  /// 节点选中变化回调
  final Function(List<TreeNode> selected)? onSelectChanged;

  /// 单选确认回调
  final SingleConfirmCallback<ID, DATA>? onSingleConfirm;

  /// 多选确认回调
  final MultiConfirmCallback<ID, DATA>? onMultiConfirm;

  /// 远程搜索
  final Future<List<Map<String, dynamic>>> Function(String? keyword)? onSearch;

  /// 懒加载
  final Future<List<Map<String, dynamic>>> Function(String parentId)? onLoadChildren;

  /// 远程搜索方法（新版本）
  final Future<List<Map<String, dynamic>>> Function(String?)? remoteMethod;

  /// 新增按钮回调
  final Function(String keyword)? onAddNew;

  TreeSelectPopup({
    required this.config,
    required this.nodes,
    required this.selectedNodes,
    this.onSelectChanged,
    this.onSingleConfirm,
    this.onMultiConfirm,
    this.onSearch,
    this.onLoadChildren,
    this.remoteMethod,
    this.onAddNew,
  });

  /// 显示弹窗
  Future<void> show(BuildContext context, {String? title}) async {
    final tempSelected = List<TreeNode>.from(selectedNodes);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PopupContent<ID, DATA>(
        config: config,
        nodes: nodes,
        tempSelectedNodes: tempSelected,
        customTitle: title,
        onSearch: onSearch,
        onLoadChildren: onLoadChildren,
        remoteMethod: remoteMethod,
        onAddNew: onAddNew,
        onSelectChanged: onSelectChanged,
        onSingleConfirm: onSingleConfirm,
        onMultiConfirm: onMultiConfirm,
        onConfirm: () {
          selectedNodes.clear();
          selectedNodes.addAll(tempSelected);
          onSelectChanged?.call(selectedNodes);
        },
      ),
    );
  }
}

class _PopupContent<ID, DATA extends Map<String, dynamic>> extends StatefulWidget {
  final TreeSelectConfig config;
  final List<TreeNode> nodes;
  final List<TreeNode> tempSelectedNodes;
  final String? customTitle;
  final Function(List<TreeNode> selected)? onSelectChanged;
  final SingleConfirmCallback<ID, DATA>? onSingleConfirm;
  final MultiConfirmCallback<ID, DATA>? onMultiConfirm;
  final Function? onConfirm;
  final Future<List<Map<String, dynamic>>> Function(String? keyword)? onSearch;
  final Future<List<Map<String, dynamic>>> Function(String parentId)? onLoadChildren;
  final Future<List<Map<String, dynamic>>> Function(String?)? remoteMethod;
  final Function(String keyword)? onAddNew;

  const _PopupContent({
    required this.config,
    required this.nodes,
    required this.tempSelectedNodes,
    this.customTitle,
    this.onSelectChanged,
    this.onSingleConfirm,
    this.onMultiConfirm,
    this.onConfirm,
    this.onSearch,
    this.onLoadChildren,
    this.remoteMethod,
    this.onAddNew,
  });

  @override
  State<_PopupContent<ID, DATA>> createState() => _PopupContentState<ID, DATA>();
}

class _PopupContentState<ID, DATA extends Map<String, dynamic>> extends State<_PopupContent<ID, DATA>> {
  List<TreeNode> _filteredNodes = [];
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  // 缓存相关
  List<Map<String, dynamic>>? _cachedData;

  // 空状态类型
  EmptyType _emptyType = EmptyType.initial;

  @override
  void initState() {
    super.initState();
    // 判断是否是远程搜索模式（新版本）
    final isRemoteSearch = widget.config.remoteSearch && widget.remoteMethod != null;

    if (isRemoteSearch) {
      // 远程模式：初始加载数据
      _loadRemoteData(null).then((_) {
        // 数据加载完成后，如果有默认值，需要匹配并展开
        if (widget.tempSelectedNodes.isNotEmpty) {
          _matchAndExpandSelectedNodes();
        }
      });
    } else if (widget.config.enableRemoteSearch && widget.onSearch != null) {
      // 旧的远程搜索模式：等待用户输入
      _filteredNodes = [];
    } else {
      // 本地模式
      _filteredNodes = widget.nodes;
      // 本地模式下，立即展开选中的节点
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.tempSelectedNodes.isNotEmpty) {
          _expandSelectedNodes();
        }
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    // 如果是 session 缓存策略，清理缓存
    if (widget.config.cacheStrategy == CacheStrategy.session) {
      _cachedData = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = widget.config.height ?? MediaQuery.of(context).size.height * 0.7;

    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 标题栏
          HeaderInfo(customTitle: widget.customTitle, onClose: () => Navigator.pop(context)),

          // 搜索框（远程和本地模式都显示）
          InputSearch(
            hintText: widget.config.searchHint ?? '搜索...',
            onSearch: _handleSearch,
            enableDebounce: widget.config.searchTriggerMode == SearchTriggerMode.realTime,
            debounceDuration: const Duration(milliseconds: 300),
            controller: _searchController, // 传入外部 controller
            showSearchButton: widget.config.remoteSearch && widget.config.searchTriggerMode == SearchTriggerMode.click,
            onSearchButtonClick: _handleSearchButtonClick,
          ),

          // 分割线（始终显示）
          Divider(height: 1, thickness: 1, color: Colors.grey.shade200),

          // 树形列表
          Expanded(
            child: TreeStructure(
              nodes: _filteredNodes,
              selectType: widget.config.selectType,
              selectableMode: widget.config.selectableMode,
              fieldMapping: widget.config.fieldMapping,
              onNodeSelected: _handleNodeSelected,
              onLoadChildren: widget.onLoadChildren,
              // 只要有搜索关键字就传递（本地和远程搜索都需要高亮）
              searchKeyword: _searchController.text.isNotEmpty ? _searchController.text : null,
              isSearching: _isSearching,
              emptyText: widget.config.emptyText!,
              loadingText: widget.config.loadingText!,
              emptyType: _emptyType,
              onAddNew: _handleAddNew,
              onRefresh: _handleRefresh,
              isRemoteSearch: widget.config.remoteSearch && widget.remoteMethod != null,
            ),
          ),

          // 底部按钮 (单选模式不显示)
          if (widget.config.selectType != SelectType.single)
            BottomAction(selectedCount: widget.tempSelectedNodes.length, showCancelButton: true, onCancel: _handleCancel, onConfirm: _handleConfirm),
        ],
      ),
    );
  }

  /// 处理取消选中
  void _handleCancel() {
    widget.tempSelectedNodes.clear();
    _clearAllNodesSelection(_filteredNodes);

    // 远程模式且不是总是缓存：重新加载初始数据
    final isRemoteSearch = widget.config.remoteSearch && widget.remoteMethod != null;
    if (isRemoteSearch && widget.config.cacheStrategy != CacheStrategy.always) {
      _loadRemoteData(null);
    }

    setState(() {});
  }

  /// 处理确认
  void _handleConfirm() {
    // 多选模式 + 只定义了 onMultiConfirm：直接调用并关闭弹窗
    if (widget.config.selectType != SelectType.single && widget.onMultiConfirm != null && widget.onSelectChanged == null) {
      widget.onMultiConfirm?.call(widget.tempSelectedNodes);
      Navigator.pop(context);
      return;
    }

    // 其他情况：调用原有回调（用于内部状态同步）
    widget.onConfirm?.call();

    // 如果同时定义了 onSelectChanged 和 onConfirm，再次调用外部回调
    if (widget.onSelectChanged != null ||
        (widget.config.selectType == SelectType.single && widget.onSingleConfirm != null) ||
        (widget.config.selectType != SelectType.single && widget.onMultiConfirm != null)) {
      // 根据选择类型调用对应的回调
      if (widget.config.selectType == SelectType.single) {
        widget.onSingleConfirm?.call(widget.tempSelectedNodes);
      } else {
        widget.onMultiConfirm?.call(widget.tempSelectedNodes);
      }
    }

    Navigator.pop(context);
  }

  void _handleNodeSelected(TreeNode node) {
    if (widget.config.selectType == SelectType.single) {
      widget.tempSelectedNodes.clear();
      if (node.isSelected) {
        widget.tempSelectedNodes.add(node);
        // 单选模式：只要传递了回调就执行
        widget.onSingleConfirm?.call(widget.tempSelectedNodes);
        widget.onSelectChanged?.call(widget.tempSelectedNodes);
        Navigator.pop(context);
        return;
      }
    } else {
      if (widget.config.selectableMode == SelectableMode.hierarchical) {
        // 层级联动模式：重新收集所有选中的节点
        _collectAllSelectedNodes();
      } else {
        // 普通模式：切换选中状态
        if (node.isSelected && !widget.tempSelectedNodes.contains(node)) {
          widget.tempSelectedNodes.add(node);
        } else if (!node.isSelected) {
          widget.tempSelectedNodes.remove(node);
        }
      }
      // 多选模式：实时回调（如果有定义）
      widget.onSelectChanged?.call(widget.tempSelectedNodes);
      // 只在需要更新底部栏 UI 时才调用 setState
      // 使用 hasWidgets 检查确保组件还在树上
      if (mounted) {
        setState(() {});
      }
    }
  }

  /// 收集所有选中的节点（用于层级联动模式）
  void _collectAllSelectedNodes() {
    widget.tempSelectedNodes.clear();
    _collectSelectedNodes(widget.nodes);
  }

  /// 递归收集选中的节点
  void _collectSelectedNodes(List<TreeNode> nodes) {
    for (final node in nodes) {
      if (node.isSelected) {
        widget.tempSelectedNodes.add(node);
      }
      if (node.children != null && node.children!.isNotEmpty) {
        _collectSelectedNodes(node.children!);
      }
    }
  }

  /// 递归清空所有节点的选中状态
  void _clearAllNodesSelection(List<TreeNode> nodes) {
    for (final node in nodes) {
      node.isSelected = false;
      if (node.children != null && node.children!.isNotEmpty) {
        _clearAllNodesSelection(node.children!);
      }
    }
  }

  /// 匹配并展开所有选中节点的父节点（用于远程搜索模式）
  void _matchAndExpandSelectedNodes() {
    // 远程搜索模式下，需要根据 ID 重新匹配节点
    final selectedIds = widget.tempSelectedNodes.map((e) => e.id).toSet();
    final matchedNodes = <TreeNode>[];

    void findNodes(List<TreeNode> nodes) {
      for (final node in nodes) {
        if (selectedIds.contains(node.id)) {
          matchedNodes.add(node);
          node.isSelected = true; // 设置选中状态
          _expandParentNodes(node); // 展开父节点
        }
        if (node.children != null && node.children!.isNotEmpty) {
          findNodes(node.children!);
        }
      }
    }

    findNodes(_filteredNodes);

    // 更新临时选中列表为新节点的引用
    widget.tempSelectedNodes.clear();
    widget.tempSelectedNodes.addAll(matchedNodes);

    // 刷新 UI
    if (mounted) {
      setState(() {});
    }
  }

  /// 展开所有选中节点的父节点（用于本地模式）
  void _expandSelectedNodes() {
    // 本地模式：直接使用现有节点
    for (final node in widget.tempSelectedNodes) {
      _expandParentNodes(node);
    }

    // 刷新 UI
    if (mounted) {
      setState(() {});
    }
  }

  /// 递归展开节点的所有父节点
  void _expandParentNodes(TreeNode node) {
    TreeNode? parent = node.parent;
    while (parent != null) {
      parent.isExpanded = true;
      parent = parent.parent;
    }
  }

  void _handleSearch(String value) {
    _debounceTimer?.cancel();

    // 判断是否是远程搜索模式
    final isRemoteSearch = widget.config.remoteSearch && widget.remoteMethod != null;

    if (isRemoteSearch) {
      // 远程搜索模式：根据触发模式决定是否立即搜索
      if (widget.config.searchTriggerMode == SearchTriggerMode.click) {
        // 点击搜索模式：不自动搜索，等待点击按钮
        // 这个方法是通过 onChanged 调用的，所以直接 return
        return;
      }

      // 实时搜索模式：直接调用远程方法
      setState(() {
        _isSearching = true;
      });

      _loadRemoteData(value);
    } else {
      // 本地搜索模式：使用防抖
      _debounceTimer = Timer(const Duration(milliseconds: 300), () {
        if (widget.onSearch != null && widget.config.enableRemoteSearch) {
          _performRemoteSearch(value);
        } else {
          _filterLocalNodes(value);
        }
      });
    }
  }

  /// 点击搜索按钮时触发的搜索
  void _handleSearchButtonClick() {
    final isRemoteSearch = widget.config.remoteSearch && widget.remoteMethod != null;

    if (isRemoteSearch && widget.config.searchTriggerMode == SearchTriggerMode.click) {
      // 点击搜索模式：执行远程搜索
      setState(() {
        _isSearching = true;
      });

      _loadRemoteData(_searchController.text);
    }
  }

  void _filterLocalNodes(String keyword) {
    if (keyword.isEmpty) {
      setState(() {
        _filteredNodes = widget.nodes;
      });
      return;
    }

    setState(() {
      _filteredNodes = _filterNodes(widget.nodes, keyword);
    });
  }

  List<TreeNode> _filterNodes(List<TreeNode> nodes, String keyword) {
    final result = <TreeNode>[];

    for (final node in nodes) {
      if (node.label.toLowerCase().contains(keyword.toLowerCase())) {
        result.add(node);
      } else if (node.children != null) {
        final filteredChildren = _filterNodes(node.children!, keyword);
        if (filteredChildren.isNotEmpty) {
          final newNode = node.copyWith(children: filteredChildren);
          newNode.isExpanded = true;
          result.add(newNode);
        }
      }
    }

    return result;
  }

  Future<void> _performRemoteSearch(String keyword) async {
    setState(() {
      _isSearching = true;
    });

    try {
      final searchData = await widget.onSearch!(keyword);
      final searchNodes = searchData.map((e) => TreeNode.fromData(e, mapping: widget.config.fieldMapping)).toList();

      setState(() {
        _filteredNodes = searchNodes;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      debugPrint('远程搜索失败：$e');
    }
  }

  /// 加载远程数据
  Future<void> _loadRemoteData(String? keyword) async {
    // 总是缓存模式：首次加载远程数据，后续基于缓存本地过滤
    if (widget.config.cacheStrategy == CacheStrategy.always && _cachedData != null) {
      // 使用缓存数据进行本地过滤
      if (keyword == null || keyword.isEmpty) {
        // 清空搜索：显示全部缓存数据
        setState(() {
          _filteredNodes = _cachedData!.map((e) => TreeNode.fromData(e, mapping: widget.config.fieldMapping)).toList();
          _emptyType = EmptyType.initial;
          _isSearching = false;
        });
        // 展开选中的节点
        _expandSelectedNodes();
      } else {
        // 本地过滤
        final filtered = _filterNodesByKeyword(_cachedData!, keyword);
        setState(() {
          _filteredNodes = filtered;
          // 判断是否有完全匹配
          final hasExactMatch = _cachedData!.any((item) => (item['name'] as String?)?.toLowerCase() == keyword.toLowerCase());
          _emptyType = filtered.isEmpty ? EmptyType.searchEmpty : (hasExactMatch ? EmptyType.initial : EmptyType.searchMismatch);
          _isSearching = false;
        });
      }
      return;
    }

    if (widget.config.cacheStrategy == CacheStrategy.never) {
      // 不清除缓存，继续加载
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final searchData = await widget.remoteMethod!(keyword);

      // 缓存数据
      if (widget.config.cacheStrategy != CacheStrategy.never) {
        _cachedData = searchData;
      }

      // 判断空状态类型
      if (searchData.isEmpty) {
        setState(() {
          _filteredNodes = [];
          _emptyType = (keyword == null || keyword.isEmpty) ? EmptyType.initial : EmptyType.searchEmpty;
          _isSearching = false;
        });
      } else {
        // 有数据，检查是否完全匹配
        if (keyword != null && keyword.isNotEmpty) {
          final hasExactMatch = searchData.any((item) => (item['name'] as String?)?.toLowerCase() == keyword.toLowerCase());
          setState(() {
            _filteredNodes = searchData.map((e) => TreeNode.fromData(e, mapping: widget.config.fieldMapping)).toList();
            _emptyType = hasExactMatch ? EmptyType.initial : EmptyType.searchMismatch;
            _isSearching = false;
          });
        } else {
          setState(() {
            _filteredNodes = searchData.map((e) => TreeNode.fromData(e, mapping: widget.config.fieldMapping)).toList();
            _emptyType = EmptyType.initial;
            _isSearching = false;
          });
          // 展开选中的节点
          _expandSelectedNodes();
        }
      }
    } catch (e) {
      setState(() {
        _isSearching = false;
        _filteredNodes = [];
        _emptyType = EmptyType.initial;
      });
      debugPrint('远程加载失败：$e');
    }
  }

  /// 根据关键字过滤节点
  List<TreeNode> _filterNodesByKeyword(List<Map<String, dynamic>> data, String keyword) {
    final result = <TreeNode>[];

    for (final item in data) {
      final label = (item['name'] as String?) ?? '';
      if (label.toLowerCase().contains(keyword.toLowerCase())) {
        result.add(TreeNode.fromData(item, mapping: widget.config.fieldMapping));
      }
    }

    return result;
  }

  /// 处理刷新按钮点击
  void _handleRefresh() {
    _searchController.clear();
    _loadRemoteData(null);
  }

  /// 处理新增按钮点击
  void _handleAddNew(String keyword) {
    // 关闭弹窗
    Navigator.pop(context);
    // 调用外部回调
    if (widget.onAddNew != null) {
      widget.onAddNew!(keyword);
    }
  }
}
