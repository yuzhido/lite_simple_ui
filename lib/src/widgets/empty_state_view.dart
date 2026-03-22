import 'package:flutter/material.dart';

/// 空状态类型枚举
enum EmptyStateType {
  /// 初始加载无数据
  initial,

  /// 搜索无结果
  searchEmpty,

  /// 搜索结果不匹配
  searchMismatch,
}

/// 空状态组件
class EmptyStateView extends StatelessWidget {
  /// 空状态类型
  final EmptyStateType type;

  /// 是否是远程搜索模式（决定刷新按钮是否显示）
  final bool isRemoteSearch;

  /// 刷新按钮点击回调
  final VoidCallback? onRefresh;

  /// 新增按钮点击回调（传递搜索关键字）
  final Function(String keyword)? onAddNew;

  /// 搜索关键字
  final String? searchKeyword;

  /// 自定义提示文字（可选）
  final String? tipText;

  /// 自定义按钮文字（可选）
  final String? buttonText;

  const EmptyStateView({super.key, required this.type, this.isRemoteSearch = false, this.onRefresh, this.onAddNew, this.searchKeyword, this.tipText, this.buttonText});

  @override
  Widget build(BuildContext context) {
    // 根据类型获取配置
    final config = _getConfigByType(type);

    // 根据是否是远程搜索模式决定提示文字
    String displayTipText = tipText ?? config.tipText;
    if (type == EmptyStateType.initial && !isRemoteSearch) {
      // 非远程模式下，初始无数据不显示"点击刷新"
      displayTipText = tipText ?? '很遗憾,没有过滤到你想要的数据';
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 图标
          Icon(_getIconByType(type), size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),

          // 主提示文字
          Text(
            displayTipText,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // 按钮组
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (config.showRefresh && isRemoteSearch) ElevatedButton.icon(onPressed: onRefresh, icon: const Icon(Icons.refresh, size: 18), label: const Text('刷新')),
              if (config.showAdd) ElevatedButton.icon(onPressed: () => onAddNew?.call(searchKeyword ?? ''), icon: const Icon(Icons.add, size: 18), label: Text(buttonText ?? '新增')),
            ],
          ),
        ],
      ),
    );
  }

  /// 根据类型获取配置
  _EmptyStateConfig _getConfigByType(EmptyStateType type) {
    switch (type) {
      case EmptyStateType.initial:
        return _EmptyStateConfig(tipText: '暂无数据，点击刷新试试', showRefresh: true, showAdd: false);
      case EmptyStateType.searchEmpty:
        return _EmptyStateConfig(tipText: '未搜索到相关数据，是否去新增', showRefresh: false, showAdd: true);
      case EmptyStateType.searchMismatch:
        return _EmptyStateConfig(tipText: '没有找到你想要的数据，是否去新增', showRefresh: false, showAdd: true);
    }
  }

  /// 根据类型获取图标
  IconData _getIconByType(EmptyStateType type) {
    switch (type) {
      case EmptyStateType.initial:
        return Icons.inbox_outlined;
      case EmptyStateType.searchEmpty:
        return Icons.search_off;
      case EmptyStateType.searchMismatch:
        return Icons.info_outline;
    }
  }
}

/// 空状态配置
class _EmptyStateConfig {
  final String tipText;
  final bool showRefresh;
  final bool showAdd;

  _EmptyStateConfig({required this.tipText, required this.showRefresh, required this.showAdd});
}
