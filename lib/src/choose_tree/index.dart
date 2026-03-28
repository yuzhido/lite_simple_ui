import 'package:flutter/material.dart';

import '../model/index.dart';
import '../widgets/input_container.dart';
import 'widgets/popup_view.dart';
import 'src/tree_node.dart';
import 'src/tree_select_config.dart';

/// 单选确认回调typedef
typedef SingleConfirmCallback<ID, DATA> = void Function(ID id, DATA data);

/// 多选确认回调 typedef
typedef MultiConfirmCallback<ID, DATA> = void Function(List<ID> ids, List<DATA> dataList);

class ChooseTree<ID, DATA extends Map<String, dynamic>> extends StatefulWidget {
  /// 自定义标题，用于显示在 label 区域和弹窗标题
  final String? title;

  /// 树形数据（由使用页面传入）
  final List<Map<String, dynamic>>? data;

  /// 选中变化回调
  final Function(List<Map<String, dynamic>> selected)? onSelectChanged;

  /// 当前选中的值（由外部控制）
  final List<Map<String, dynamic>>? value;

  /// 选择类型（单选/多选）
  final SelectType? selectType;

  /// 节点可选择性模式
  final SelectableMode? selectableMode;

  /// 显示模式（文本模式/标签模式）
  final DisplayMode? displayMode;

  /// 单选确认回调
  final SingleConfirmCallback<ID, DATA>? onSingleConfirm;

  /// 多选确认回调
  final MultiConfirmCallback<ID, DATA>? onMultiConfirm;

  /// 自定义内容区构建器
  final Widget Function(BuildContext context, List<Map<String, dynamic>> selectedValues)? customContentBuilder;

  /// 是否启用远程搜索模式
  final bool? remoteSearch;

  /// 远程搜索方法
  final Future<List<Map<String, dynamic>>> Function(String?)? remoteMethod;

  /// 缓存策略
  final CacheStrategy? cacheStrategy;

  /// 搜索触发模式
  final SearchTriggerMode? searchTriggerMode;

  /// 新增按钮回调（接收搜索关键字）
  final Function(String keyword)? onAddNew;

  /// 字段映射配置
  final FieldMapping? fieldMapping;

  const ChooseTree({
    super.key,
    this.title,
    this.data,
    this.onSelectChanged,
    this.value,
    this.selectType,
    this.selectableMode,
    this.displayMode,
    this.onSingleConfirm,
    this.onMultiConfirm,
    this.customContentBuilder,
    this.remoteSearch,
    this.remoteMethod,
    this.cacheStrategy,
    this.searchTriggerMode,
    this.onAddNew,
    this.fieldMapping,
  });
  @override
  State<ChooseTree<ID, DATA>> createState() => _ChooseTreeState<ID, DATA>();
}

class _ChooseTreeState<ID, DATA extends Map<String, dynamic>> extends State<ChooseTree<ID, DATA>> {
  List<TreeNode> _treeNodes = [];
  List<TreeNode> _selectedNodes = [];
  String? _selectedValue; // 用于显示在内容区域的选中值
  bool _isExpanded = false; // 是否展开弹窗

  @override
  void initState() {
    super.initState();
    _initializeData();
    _initializeSelectedNodes();
  }

  @override
  void didUpdateWidget(ChooseTree<ID, DATA> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 数据变化时重新初始化
    if (widget.data != oldWidget.data) {
      _initializeData();
      _initializeSelectedNodes();
      return;
    }

    // value 变化时重新初始化选中节点
    if (widget.value != oldWidget.value) {
      // 检查是否是清除操作导致的 value 变化
      final wasNotEmpty = oldWidget.value != null && oldWidget.value!.isNotEmpty;
      final isEmptyNow = widget.value == null || widget.value!.isEmpty;

      // 如果之前有值现在为空，说明是清除操作，不要重新初始化（因为 _selectedNodes 已经清空了）
      if (!(wasNotEmpty && isEmptyNow)) {
        _initializeSelectedNodes();
      }
    }
  }

  /// 初始化数据
  void _initializeData() {
    if (widget.data == null) {
      setState(() {
        _treeNodes = [];
      });
      return;
    }

    setState(() {
      _treeNodes = widget.data!
          .map(
            (e) => TreeNode.fromData(
              e,
              mapping: const FieldMapping(idField: 'id', labelField: 'name', childrenField: 'children'),
            ),
          )
          .toList();
    });
  }

  /// 初始化选中的节点
  void _initializeSelectedNodes() {
    // 先清空所有节点的选中状态
    _clearAllNodeSelection(_treeNodes);

    if (widget.value == null || widget.value!.isEmpty) {
      setState(() {
        _selectedNodes = [];
        _selectedValue = null;
      });
      return;
    }

    // 根据 value 找到对应的节点
    final selectedIds = widget.value!.map((e) => e['id'].toString()).toSet();
    final matchedNodes = <TreeNode>[];

    void findNodes(List<TreeNode> nodes) {
      for (final node in nodes) {
        if (selectedIds.contains(node.id)) {
          matchedNodes.add(node);
          node.isSelected = true; // 设置选中状态
          // 关键：展开该节点的所有父节点
          _expandParentNodes(node);
        }
        if (node.children != null && node.children!.isNotEmpty) {
          findNodes(node.children!);
        }
      }
    }

    findNodes(_treeNodes);

    setState(() {
      _selectedNodes = matchedNodes;
      _selectedValue = matchedNodes.map((e) => e.label).join(', ');
    });
  }

  /// 清空所有节点的选中状态
  void _clearAllNodeSelection(List<TreeNode> nodes) {
    for (final node in nodes) {
      node.isSelected = false;
      if (node.children != null && node.children!.isNotEmpty) {
        _clearAllNodeSelection(node.children!);
      }
    }
  }

  /// 展开选中节点的所有父节点（用于展示选中项）
  void _expandParentNodes(TreeNode node) {
    TreeNode? parent = node.parent;
    while (parent != null) {
      parent.isExpanded = true;
      parent = parent.parent;
    }
  }

  /// 将 value 转换为 TreeNode 列表（用于远程搜索模式）
  List<TreeNode> _convertValueToNodes(List<Map<String, dynamic>> value) {
    if (value.isEmpty) return [];

    return value.map((data) {
      final node = TreeNode.fromData(
        data,
        mapping: widget.fieldMapping ?? const FieldMapping(idField: 'id', labelField: 'name', childrenField: 'children'),
      );
      node.isSelected = true;
      return node;
    }).toList();
  }

  /// 显示弹窗
  void _showPopup() {
    setState(() {
      _isExpanded = true;
    });

    // 判断是否需要远程搜索模式
    final isRemoteSearch = widget.remoteSearch == true && widget.remoteMethod != null;

    // 远程搜索模式：直接传递 widget.value 对应的节点（即使为空，弹窗会自己匹配）
    // 本地模式：使用已经初始化的 _selectedNodes
    final nodesToPass = isRemoteSearch ? _convertValueToNodes(widget.value ?? []) : _selectedNodes;

    final popupView = TreeSelectPopup<ID, DATA>(
      config: TreeSelectConfig(
        mode: TreeSelectMode.popup,
        selectType: widget.selectType ?? SelectType.multiple,
        placeholder: widget.title ?? '请选择',
        showSearch: isRemoteSearch, // 只有远程搜索模式才显示搜索框
        selectableMode: widget.selectableMode ?? SelectableMode.all,
        fieldMapping: widget.fieldMapping ?? const FieldMapping(idField: 'id', labelField: 'name', childrenField: 'children'),
        remoteSearch: isRemoteSearch,
        cacheStrategy: widget.cacheStrategy ?? CacheStrategy.session,
        searchTriggerMode: widget.searchTriggerMode ?? SearchTriggerMode.realTime,
      ),
      nodes: _treeNodes,
      selectedNodes: nodesToPass,
      remoteMethod: widget.remoteMethod,
      onAddNew: widget.onAddNew,
      onSelectChanged: (selected) {
        setState(() {
          _selectedNodes = selected;
          // 将选中的节点名称组合成字符串
          if (selected.isNotEmpty) {
            _selectedValue = selected.map((e) => e.label).join(', ');
          } else {
            _selectedValue = null;
          }
        });
        // 调用外部回调
        final rawData = selected.map((e) => e.rawData).toList();
        widget.onSelectChanged?.call(rawData);
      },
      onSingleConfirm: widget.onSingleConfirm != null || widget.onMultiConfirm != null
          ? (selected) {
              // 单选模式：提取第一个节点的 id 和 data
              if (selected.isNotEmpty) {
                final firstNode = selected.first;
                final id = firstNode.id as ID;
                final data = firstNode.rawData as DATA;

                // 调用单选回调
                widget.onSingleConfirm?.call(id, data);
                // 如果是多选回调，也调用（传递单个元素的列表）
                if (widget.onMultiConfirm != null) {
                  widget.onMultiConfirm?.call([id], [data]);
                }
              }
            }
          : null,
      onMultiConfirm: widget.onMultiConfirm != null
          ? (selected) {
              // 多选模式：提取所有节点的 id 列表和 data 列表
              final ids = selected.map((node) => node.id as ID).toList();
              final dataList = selected.map((node) => node.rawData as DATA).toList();
              widget.onMultiConfirm?.call(ids, dataList);
            }
          : null,
    );

    popupView.show(context, title: widget.title).then((_) {
      // 弹窗关闭后，设置箭头为收起状态
      setState(() {
        _isExpanded = false;
      });
    });
  }

  /// 清空选中
  void _clearSelection() {
    // 清空所有节点的选中状态
    void clearNodeStates(List<TreeNode> nodes) {
      for (final node in nodes) {
        node.isSelected = false;
        if (node.children != null && node.children!.isNotEmpty) {
          clearNodeStates(node.children!);
        }
      }
    }

    setState(() {
      clearNodeStates(_treeNodes);
      _selectedNodes = [];
      _selectedValue = null;
    });
    // 调用外部回调，传递空列表
    widget.onSelectChanged?.call([]);
  }

  @override
  Widget build(BuildContext context) {
    return InputContainer(
      customContentBuilder: widget.customContentBuilder != null
          ? (context, tagValues) => widget.customContentBuilder!(context, _selectedNodes.map((e) => e.rawData).toList())
          : null,
      onTap: _showPopup,
      label: widget.title ?? '请选择',
      selectedValue: _selectedValue,
      selectedValues: _selectedNodes.map((e) => e.label).toList(),
      onClear: _clearSelection,
      isExpanded: _isExpanded,
      displayMode: widget.displayMode,
    );
  }
}
