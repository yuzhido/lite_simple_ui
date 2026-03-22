import 'package:flutter/material.dart';
import '../../model/index.dart';
import '../src/tree_node.dart';
import '../src/tree_view.dart';
import '../../widgets/empty_state_view.dart';

/// 树形结构列表组件
class TreeStructure<ID, DATA extends Map<String, dynamic>> extends StatelessWidget {
  /// 树节点数据
  final List<TreeNode> nodes;

  /// 选择类型
  final SelectType selectType;

  /// 可选模式
  final SelectableMode selectableMode;

  /// 字段映射
  final FieldMapping? fieldMapping;

  /// 节点选中回调
  final Function(TreeNode node)? onNodeSelected;

  /// 懒加载回调
  final Future<List<Map<String, dynamic>>> Function(String parentId)? onLoadChildren;

  /// 搜索关键词
  final String? searchKeyword;

  /// 是否正在搜索
  final bool isSearching;

  /// 空状态提示文字
  final String emptyText;

  /// 加载中提示文字
  final String loadingText;

  /// 空状态类型
  final EmptyType emptyType;

  /// 新增按钮回调
  final Function(String keyword)? onAddNew;

  /// 刷新按钮回调
  final VoidCallback? onRefresh;

  /// 是否是远程搜索模式
  final bool isRemoteSearch;

  const TreeStructure({
    super.key,
    required this.nodes,
    required this.selectType,
    required this.selectableMode,
    this.fieldMapping,
    this.onNodeSelected,
    this.onLoadChildren,
    this.searchKeyword,
    this.isSearching = false,
    this.emptyText = '暂无数据',
    this.loadingText = '加载中...',
    this.emptyType = EmptyType.initial,
    this.onAddNew,
    this.onRefresh,
    this.isRemoteSearch = false,
  });

  @override
  Widget build(BuildContext context) {
    // 正在搜索
    if (isSearching) {
      return _buildLoadingView();
    }

    // 数据为空
    if (nodes.isEmpty) {
      return _buildEmptyView();
    }

    // 树形列表 + 底部提示（如果有搜索不匹配）
    return Column(
      children: [
        // 树形列表
        Expanded(child: _buildTreeView()),
        // 底部提示（只在搜索不匹配时显示）
        if (emptyType == EmptyType.searchMismatch) _buildMismatchTip(),
      ],
    );
  }

  /// 构建加载中视图
  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: Colors.blue),
          const SizedBox(height: 16),
          Text(loadingText, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  /// 构建空视图
  Widget _buildEmptyView() {
    return EmptyStateView(type: _convertEmptyType(emptyType), isRemoteSearch: isRemoteSearch, onRefresh: onRefresh, onAddNew: onAddNew, searchKeyword: searchKeyword);
  }

  /// 转换枚举类型
  EmptyStateType _convertEmptyType(EmptyType type) {
    switch (type) {
      case EmptyType.initial:
        return EmptyStateType.initial;
      case EmptyType.searchEmpty:
        return EmptyStateType.searchEmpty;
      case EmptyType.searchMismatch:
        return EmptyStateType.searchMismatch;
    }
  }

  /// 构建搜索不匹配提示（底部）
  Widget _buildMismatchTip() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border(top: BorderSide(color: Colors.orange.shade200, width: 1)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '没有找到你想要的数据',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.orange),
                ),
                const SizedBox(height: 2),
                Text('是否去新增？', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () => onAddNew?.call(searchKeyword ?? ''),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('新增'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
          ),
        ],
      ),
    );
  }

  /// 构建树形视图
  Widget _buildTreeView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: TreeView(
        nodes: nodes,
        selectType: selectType,
        selectableMode: selectableMode,
        fieldMapping: fieldMapping!,
        onNodeSelected: onNodeSelected,
        onLoadChildren: onLoadChildren,
        searchKeyword: searchKeyword,
      ),
    );
  }
}
