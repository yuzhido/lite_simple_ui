import 'package:flutter/material.dart';
import '../../model/tree_select.dart';

/// TreeSelect 组件配置类
class TreeSelectConfig {
  /// UI 模式，默认为下拉模式
  final TreeSelectMode mode;

  /// 选择模式，默认为单选
  final SelectType selectType;

  /// 字段映射配置
  final FieldMapping fieldMapping;

  /// 是否启用远程搜索（旧版本兼容）
  final bool enableRemoteSearch;

  /// 是否启用远程搜索模式（新版本）
  final bool remoteSearch;

  /// 缓存策略
  final CacheStrategy cacheStrategy;

  /// 搜索触发模式
  final SearchTriggerMode searchTriggerMode;

  /// 是否启用懒加载
  final bool enableLazyLoad;

  /// 远程搜索回调函数
  /// 返回原始数据列表（Map<String, dynamic>）
  final Future<List<Map<String, dynamic>>> Function(String? keyword)? onSearch;

  /// 懒加载子节点回调函数
  /// 返回原始数据列表（Map<String, dynamic>）
  final Future<List<Map<String, dynamic>>> Function(String parentId)? onLoadChildren;

  /// 占位符文本
  final String? placeholder;

  /// 组件高度（用于弹窗模式）
  final double? height;

  /// 输入框装饰
  final InputDecoration? inputDecoration;

  /// 是否显示搜索框
  final bool showSearch;

  /// 搜索框提示文本
  final String? searchHint;

  /// 空状态提示文本
  final String? emptyText;

  /// 加载中文本
  final String? loadingText;

  /// 是否支持清除
  final bool allowClear;

  /// 最大显示高度（下拉模式）
  final double? dropdownMaxHeight;

  /// 节点可选择性模式，默认为 all（所有节点可选）
  final SelectableMode selectableMode;

  /// 显示模式，默认为 text（文本模式）
  final DisplayMode displayMode;

  /// 空状态类型
  final EmptyType emptyType;

  /// 新增按钮回调（接收搜索关键字）
  final Function(String keyword)? onAddNew;

  const TreeSelectConfig({
    this.mode = TreeSelectMode.popup,
    this.selectType = SelectType.multiple,
    this.fieldMapping = const FieldMapping(),
    this.enableRemoteSearch = false,
    this.remoteSearch = false,
    this.cacheStrategy = CacheStrategy.session,
    this.searchTriggerMode = SearchTriggerMode.realTime,
    this.enableLazyLoad = false,
    this.onSearch,
    this.onLoadChildren,
    this.placeholder = '请选择',
    this.height,
    this.inputDecoration,
    this.showSearch = true,
    this.searchHint = '搜索...',
    this.emptyText = '暂无数据',
    this.loadingText = '加载中...',
    this.allowClear = false,
    this.dropdownMaxHeight = 300,
    this.selectableMode = SelectableMode.all,
    this.displayMode = DisplayMode.text,
    this.emptyType = EmptyType.initial,
    this.onAddNew,
  });
}
