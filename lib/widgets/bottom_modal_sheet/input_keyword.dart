import 'dart:async';

import 'package:flutter/material.dart';

class InputKeyword extends StatefulWidget {
  final Function(String)? onSearch;
  final VoidCallback? onSearchButtonClick;
  final bool showSearchButton;
  final String? hintText;
  final int debounceMilliseconds;

  const InputKeyword({super.key, this.onSearch, this.onSearchButtonClick, this.showSearchButton = false, this.hintText = '请输入内容', this.debounceMilliseconds = 500});

  @override
  State<InputKeyword> createState() => _InputKeywordState();
}

class _InputKeywordState extends State<InputKeyword> {
  final searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    // 如果显示搜索按钮，不触发自动搜索
    if (widget.showSearchButton) return;

    // 防抖处理
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(milliseconds: widget.debounceMilliseconds), () {
      widget.onSearch?.call(value);
    });
  }

  void _onSearchButtonClick() {
    _debounceTimer?.cancel();
    widget.onSearchButtonClick?.call();
  }

  void _onClear() {
    searchController.clear();
    _debounceTimer?.cancel();

    if (widget.showSearchButton) {
      // 清空后立即触发搜索（显示全部）
      widget.onSearchButtonClick?.call();
    } else {
      widget.onSearch?.call('');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            spacing: 10,
            children: [
              Expanded(
                child: TextFormField(
                  controller: searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                    suffixIcon: searchController.text.isNotEmpty ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: _onClear) : null,
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  ),
                ),
              ),
              // 根据配置显示搜索按钮
              if (widget.showSearchButton)
                ElevatedButton.icon(
                  onPressed: _onSearchButtonClick,
                  icon: Icon(Icons.search),
                  label: Text('搜索'),
                  style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
                ),
            ],
          ),
          SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xfff5f5f5)),
        ],
      ),
    );
  }
}
