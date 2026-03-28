import 'package:flutter/material.dart';

import '../../model/index.dart';

/// 下拉选择器配置
class DropdownConfig {
  /// 选择类型（单选/多选）
  final SelectType selectType;

  /// 显示模式（文本模式/标签模式）
  final DisplayMode displayMode;

  /// 字段映射配置
  final FieldMapping fieldMapping;

  /// 占位符文本
  final String placeholder;

  /// 容器高度
  final double? height;

  /// 输入框装饰
  final InputDecoration? inputDecoration;

  /// 是否显示搜索框
  final bool showSearch;

  /// 搜索框提示文本
  final String searchHint;

  /// 空状态提示文本
  final String emptyText;

  /// 是否支持清除
  final bool allowClear;

  const DropdownConfig({
    this.selectType = SelectType.multiple,
    this.displayMode = DisplayMode.text,
    this.fieldMapping = const FieldMapping(),
    this.placeholder = '请选择',
    this.height,
    this.inputDecoration,
    this.showSearch = false,
    this.searchHint = '搜索...',
    this.emptyText = '暂无数据',
    this.allowClear = false,
  });

  /// 复制并修改配置
  DropdownConfig copyWith({
    SelectType? selectType,
    DisplayMode? displayMode,
    FieldMapping? fieldMapping,
    String? placeholder,
    double? height,
    InputDecoration? inputDecoration,
    bool? showSearch,
    String? searchHint,
    String? emptyText,
    bool? allowClear,
  }) {
    return DropdownConfig(
      selectType: selectType ?? this.selectType,
      displayMode: displayMode ?? this.displayMode,
      fieldMapping: fieldMapping ?? this.fieldMapping,
      placeholder: placeholder ?? this.placeholder,
      height: height ?? this.height,
      inputDecoration: inputDecoration ?? this.inputDecoration,
      showSearch: showSearch ?? this.showSearch,
      searchHint: searchHint ?? this.searchHint,
      emptyText: emptyText ?? this.emptyText,
      allowClear: allowClear ?? this.allowClear,
    );
  }
}
