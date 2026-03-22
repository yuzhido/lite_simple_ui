import 'package:flutter/material.dart';
import '../../model/index.dart';
import 'tree_node.dart';

/// 树形视图渲染器
class TreeView extends StatefulWidget {
  /// 树节点列表
  final List<TreeNode> nodes;

  /// 选择模式
  final SelectType selectType;

  /// 字段映射
  final FieldMapping fieldMapping;

  /// 节点选中变化回调
  final Function(TreeNode node)? onNodeSelected;

  /// 节点展开变化回调
  final Function(TreeNode node)? onNodeExpanded;

  /// 懒加载回调
  final Future<List<Map<String, dynamic>>> Function(String parentId)? onLoadChildren;

  /// 搜索关键词（用于高亮）
  final String? searchKeyword;

  /// 节点层级缩进
  final double indent;

  /// 当前层级（内部使用）
  final int level;

  /// 节点可选择性模式
  final SelectableMode selectableMode;

  const TreeView({
    super.key,
    required this.nodes,
    required this.selectType,
    required this.fieldMapping,
    this.onNodeSelected,
    this.onNodeExpanded,
    this.onLoadChildren,
    this.searchKeyword,
    this.indent = 20.0,
    this.level = 0,
    this.selectableMode = SelectableMode.all,
  });

  @override
  State<TreeView> createState() => _TreeViewState();
}

class _TreeViewState extends State<TreeView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.nodes.map((node) {
        return _buildTreeNode(node, widget.level);
      }).toList(),
    );
  }

  /// 构建单个树节点
  Widget _buildTreeNode(TreeNode node, int level) {
    final hasChildren = node.children != null && node.children!.isNotEmpty;
    final isLoading = node.isLoading;
    final isSingleMode = widget.selectType == SelectType.single;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => _handleNodeTap(node),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(color: node.isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null, borderRadius: BorderRadius.circular(4)),
            child: Row(
              children: [
                // 层级缩进
                SizedBox(width: level * widget.indent),

                // 展开/收起按钮（独立点击区域）
                if (hasChildren || widget.onLoadChildren != null)
                  GestureDetector(
                    onTap: () => _handleExpandTap(node),
                    behavior: HitTestBehavior.deferToChild,
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: isLoading
                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                          : Transform.rotate(angle: node.isExpanded ? 0 : -90 * 3.14159 / 180, child: const Icon(Icons.arrow_drop_down, size: 20)),
                    ),
                  )
                else
                  const SizedBox(width: 20),

                // 选择框/单选按钮（单选模式不显示）
                if (!isSingleMode && widget.selectType == SelectType.multiple)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(node.isSelected ? Icons.check_box : Icons.check_box_outline_blank, size: 20, color: node.isSelected ? Theme.of(context).primaryColor : Colors.grey),
                  ),

                // 节点文本（支持搜索高亮）
                Expanded(
                  child: widget.searchKeyword != null && widget.searchKeyword!.isNotEmpty
                      ? _buildHighlightText(node.label, widget.searchKeyword!)
                      : Text(
                          node.label,
                          style: TextStyle(color: node.isSelected ? Theme.of(context).primaryColor : null, fontWeight: node.isSelected ? FontWeight.bold : null),
                        ),
                ),
              ],
            ),
          ),
        ),

        // 子节点
        if (node.isExpanded && hasChildren)
          TreeView(
            nodes: node.children!,
            selectType: widget.selectType,
            fieldMapping: widget.fieldMapping,
            onNodeSelected: widget.onNodeSelected,
            onNodeExpanded: widget.onNodeExpanded,
            onLoadChildren: widget.onLoadChildren,
            searchKeyword: widget.searchKeyword,
            indent: widget.indent,
            level: level + 1,
            selectableMode: widget.selectableMode,
          ),
      ],
    );
  }

  /// 构建高亮文本（支持多个匹配）
  Widget _buildHighlightText(String text, String keyword) {
    final pattern = RegExp('(${RegExp.escape(keyword)})', caseSensitive: false);
    final matches = pattern.allMatches(text);

    if (matches.isEmpty) {
      return Text(text);
    }

    final children = <TextSpan>[];
    int start = 0;

    for (final match in matches) {
      // 添加匹配前的普通文本
      if (match.start > start) {
        children.add(TextSpan(text: text.substring(start, match.start)));
      }
      // 添加高亮的关键词
      children.add(
        TextSpan(
          text: match.group(0),
          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
      );
      start = match.end;
    }

    // 添加剩余的普通文本
    if (start < text.length) {
      children.add(TextSpan(text: text.substring(start)));
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black),
        children: children,
      ),
    );
  }

  /// 处理展开按钮点击（只展开，不选中）
  Future<void> _handleExpandTap(TreeNode node) async {
    final hasChildren = node.children != null && node.children!.isNotEmpty;

    if (hasChildren) {
      // 本地有子节点，直接切换展开状态
      node.isExpanded = !node.isExpanded;
      widget.onNodeExpanded?.call(node);
      setState(() {});
    } else if (widget.onLoadChildren != null && node.isLeaf == null) {
      // 懒加载模式
      node.isLoading = true;
      setState(() {});

      try {
        final childrenData = await widget.onLoadChildren!(node.id);
        node.update(children: childrenData.map((e) => TreeNode.fromData(e, mapping: widget.fieldMapping)).toList(), isExpanded: true);
        widget.onNodeExpanded?.call(node);
      } catch (e) {
        // 加载失败处理
        debugPrint('加载子节点失败：$e');
      } finally {
        node.isLoading = false;
      }
      setState(() {});
    }
  }

  /// 处理节点点击
  Future<void> _handleNodeTap(TreeNode node) async {
    // 处理选中逻辑
    if (widget.selectType == SelectType.single) {
      // 单选模式：互斥选择
      _clearAllSelection();
      node.isSelected = true;
    } else {
      // 多选模式
      if (widget.selectableMode == SelectableMode.hierarchical) {
        // 层级联动选择
        await _handleHierarchicalSelection(node);
        return; // 层级联动已经调用了 setState 和 onNodeSelected
      } else {
        // 普通模式：切换选中状态
        node.isSelected = !node.isSelected;
      }
    }

    widget.onNodeSelected?.call(node);
    setState(() {});
  }

  /// 处理层级联动选择
  Future<void> _handleHierarchicalSelection(TreeNode node) async {
    final hasChildren = node.children != null && node.children!.isNotEmpty;

    debugPrint('点击节点：${node.label}, hasChildren=$hasChildren');

    if (hasChildren) {
      // 点击父节点：切换所有子节点
      final newState = !node.isSelected;
      debugPrint('点击父节点，切换所有子节点到：$newState');
      _toggleChildrenSelection(node, newState);
      node.isSelected = newState;
      // 不需要更新父节点，因为父节点就是当前点击的节点
    } else {
      // 点击叶子节点：切换状态
      node.isSelected = !node.isSelected;
      debugPrint('点击叶子节点，${node.label} 切换到：${node.isSelected}');
      // 更新父节点状态
      debugPrint('准备调用 _updateParentSelection 更新父节点状态');
      _updateParentSelection(node);
    }

    // 确保在状态更新后再调用 setState
    widget.onNodeSelected?.call(node);
    setState(() {});
  }

  /// 递归切换子节点选中状态
  void _toggleChildrenSelection(TreeNode node, bool isSelected) {
    if (node.children != null) {
      for (final child in node.children!) {
        child.isSelected = isSelected;
        _toggleChildrenSelection(child, isSelected);
      }
    }
  }

  /// 更新父节点选中状态
  void _updateParentSelection(TreeNode node) {
    debugPrint('_updateParentSelection 被调用，当前节点：${node.label}');
    final parent = node.parent;
    debugPrint('找到父节点：${parent?.label ?? "null"}');
    if (parent != null && parent.children != null) {
      // 检查所有子节点是否都选中
      final allChildrenSelected = parent.children!.every((child) => child.isSelected);
      debugPrint('父节点 ${parent.label} 的子节点选中情况：$allChildrenSelected');

      // 只有所有子节点都选中，父节点才选中
      parent.isSelected = allChildrenSelected;

      debugPrint('更新父节点状态：${parent.label} isSelected=$allChildrenSelected');

      // 递归向上更新
      if (allChildrenSelected) {
        _updateParentSelection(parent);
      }
    } else {
      debugPrint('父节点为 null 或没有子节点，跳过更新');
    }
  }

  /// 清空所有选中状态
  void _clearAllSelection() {
    _clearNodesSelection(widget.nodes);
  }

  /// 递归清空节点选中状态
  void _clearNodesSelection(List<TreeNode> nodes) {
    for (final node in nodes) {
      node.isSelected = false;
      if (node.children != null) {
        _clearNodesSelection(node.children!);
      }
    }
  }
}
