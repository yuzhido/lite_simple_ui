import 'dart:async';
import 'package:flutter/material.dart';

/// 搜索框回调 typedef
typedef SearchCallback = void Function(String keyword);

/// 清除回调 typedef
typedef ClearCallback = void Function();

/// 搜索栏组件 - 用于弹窗搜索功能
class InputSearch extends StatefulWidget {
  /// 搜索提示文本
  final String hintText;

  /// 搜索回调
  final SearchCallback? onSearch;

  /// 是否启用防抖 (默认 true)
  final bool enableDebounce;

  /// 防抖延迟时间 (默认 300ms)
  final Duration debounceDuration;

  /// 搜索框背景色
  final Color? backgroundColor;

  /// 搜索按钮背景色
  final Color? searchButtonColor;

  /// 搜索按钮文字颜色
  final Color? searchButtonTextColor;

  /// 搜索图标颜色
  final Color? searchIconColor;

  /// 外部传入的文本控制器 (可选)
  final TextEditingController? controller;

  /// 边距
  final EdgeInsets padding;

  /// 搜索框高度
  final double height;

  /// 清除回调
  final ClearCallback? onClear;

  /// 是否显示搜索按钮（默认 false，只在点击搜索模式时显示）
  final bool showSearchButton;

  /// 搜索按钮点击回调（可选，不传则使用 onSearch）
  final VoidCallback? onSearchButtonClick;

  const InputSearch({
    super.key,
    this.hintText = '请输入关键字',
    this.onSearch,
    this.enableDebounce = true,
    this.debounceDuration = const Duration(milliseconds: 300),
    this.backgroundColor,
    this.searchButtonColor,
    this.searchButtonTextColor,
    this.searchIconColor,
    this.controller,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 8),
    this.height = 40,
    this.onClear,
    this.showSearchButton = false,
    this.onSearchButtonClick,
  });

  @override
  State<InputSearch> createState() => _InputSearchState();
}

class _InputSearchState extends State<InputSearch> {
  late final TextEditingController _searchController;
  late final FocusNode _focusNode;
  Timer? _debounceTimer;
  bool _hasContent = false;

  @override
  void initState() {
    super.initState();
    // 如果外部传入了 controller 就使用，否则创建自己的
    _searchController = widget.controller ?? TextEditingController();
    // 创建焦点节点
    _focusNode = FocusNode();
    // 监听输入框内容变化
    _searchController.addListener(_onContentChanged);
  }

  void _onContentChanged() {
    setState(() {
      _hasContent = _searchController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    // 只有当 controller 是自己创建的时候才需要 dispose
    if (widget.controller == null) {
      _searchController.dispose();
    } else {
      // 如果是外部的 controller，需要移除监听器
      _searchController.removeListener(_onContentChanged);
    }
    // 释放焦点节点
    _focusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding,
      child: Row(
        spacing: 5,
        children: [
          // 搜索输入框
          Expanded(
            child: Container(
              height: widget.height, // 可根据需要调整或通过参数传递
              decoration: BoxDecoration(color: widget.backgroundColor ?? Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 12,
                    right: 12,
                    child: Row(
                      children: [
                        // 搜索图标 - 无内容时显示
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            focusNode: _focusNode,
                            onTapUpOutside: (event) {
                              // 点击外部区域时取消焦点
                              _focusNode.unfocus();
                            },
                            decoration: InputDecoration(
                              hintText: widget.hintText,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                            ),
                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                            maxLines: 1,
                            onChanged: _handleSearch,
                          ),
                        ),
                        // 清除图标 - 有内容时显示
                        const SizedBox(width: 5),
                        if (!_hasContent) Icon(Icons.search, size: 20, color: widget.searchIconColor ?? Colors.grey),
                        if (_hasContent)
                          InkWell(
                            onTap: _handleClear,
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: const EdgeInsets.all(2),
                              child: Icon(Icons.close, size: 18, color: widget.searchIconColor ?? Colors.grey),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 搜索按钮（只在点击搜索模式时显示）
          if (widget.showSearchButton)
            Container(
              height: widget.height, // 与输入框高度保持一致
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(color: widget.searchButtonColor ?? Colors.blue.shade600, borderRadius: BorderRadius.circular(8)),
              child: TextButton.icon(
                label: Text(
                  '搜索',
                  style: TextStyle(color: widget.searchButtonTextColor ?? Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                onPressed: () {
                  // 如果定义了搜索按钮点击回调，优先使用
                  if (widget.onSearchButtonClick != null) {
                    widget.onSearchButtonClick!();
                  } else {
                    _triggerSearch(_searchController.text);
                  }
                },
                // icon: Icon(Icons.search, size: 20, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  void _handleClear() {
    _searchController.clear();
    // 触发清除回调
    widget.onClear?.call();
    // 触发搜索回调（清空搜索）
    _triggerSearch('');
  }

  void _handleSearch(String value) {
    if (widget.enableDebounce) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(widget.debounceDuration, () {
        _triggerSearch(value);
      });
    } else {
      _triggerSearch(value);
    }
  }

  void _triggerSearch(String keyword) {
    widget.onSearch?.call(keyword);
  }
}
