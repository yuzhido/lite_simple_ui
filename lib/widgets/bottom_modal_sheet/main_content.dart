import 'dart:async';

import 'package:flutter/material.dart';

import 'content_show.dart';
import 'data_cache_manager.dart';
import 'input_keyword.dart';
import 'no_data.dart';
import 'no_data_add.dart';
import 'title_info.dart';

class MainContent<R, T> extends StatefulWidget {
  final String? title;
  final bool? showAdd;
  final bool? remote;
  final bool? forceRefresh;
  final Future<List<T>?> Function(String? keyword)? remoteMethod;
  final List<T>? options;
  final String Function(T) displayText;
  final R Function(T) valueExtractor;
  final dynamic defaultValue;
  final bool isMultiSelect;
  final bool showSearchButton;
  final int searchDebounceMs;
  final T? initialDisplayValue;

  final Function(R, T, bool)? onChange; // 第三个参数：isSelected
  final Function(List<R>, List<T>)? onConfirm;

  const MainContent({
    super.key,
    this.title,
    this.showAdd,
    this.remote,
    this.forceRefresh,
    this.remoteMethod,
    this.options,
    required this.displayText,
    required this.valueExtractor,
    this.defaultValue,
    this.isMultiSelect = false,
    this.showSearchButton = false,
    this.searchDebounceMs = 500,
    this.initialDisplayValue,
    this.onChange,
    this.onConfirm,
  });
  @override
  State<MainContent<R, T>> createState() => _MainContentState<R, T>();
}

class _MainContentState<R, T> extends State<MainContent<R, T>> {
  late final DataCacheManager<T> _cacheManager;
  List<T>? _displayOptions;
  bool _isLoading = false;
  String? _errorMessage;
  String _searchKeyword = '';
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _cacheManager = DataCacheManager<T>();

    // 如果有初始显示值，添加到选项列表
    if (widget.initialDisplayValue != null && widget.options != null) {
      widget.options!.insert(0, widget.initialDisplayValue!);
    }

    _loadInitialData();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _cacheManager.clearCache(); // 组件销毁时清除缓存
    super.dispose();
  }

  /// 加载初始数据
  Future<void> _loadInitialData() async {
    if (widget.remote == true && widget.remoteMethod != null) {
      if (!_cacheManager.shouldReload(widget.forceRefresh ?? false)) {
        setState(() {
          _displayOptions = _cacheManager.cachedData;
        });
        return;
      }

      await _fetchRemoteData(); // 无关键字，会缓存
    } else {
      setState(() {
        _displayOptions = widget.options ?? [];
        _cacheManager.setCache(_displayOptions!);
      });
    }
  }

  /// 远程获取数据
  Future<void> _fetchRemoteData({String? keyword}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await widget.remoteMethod!(keyword);

      setState(() {
        _displayOptions = data ?? [];
        _isLoading = false;

        // 只有无关键字时才缓存（初始列表）
        if (keyword == null || keyword.isEmpty) {
          _cacheManager.setCache(_displayOptions!);
        }
        // 有关键字的搜索结果不缓存
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  /// 处理搜索
  void _handleSearch(String keyword) {
    setState(() {
      _searchKeyword = keyword;
    });

    if (widget.remote == true && widget.remoteMethod != null) {
      // 远程模式
      if (widget.showSearchButton) {
        return; // 等待点击搜索按钮
      } else {
        // 防抖自动搜索
        _debouncedRemoteSearch(keyword);
      }
    } else {
      // 本地模式 - 实时过滤
      _filterLocalData(keyword);
    }
  }

  /// 本地数据过滤
  void _filterLocalData(String keyword) {
    if (keyword.isEmpty) {
      setState(() {
        _displayOptions = _cacheManager.cachedData ?? [];
      });
    } else {
      final filtered = (_cacheManager.cachedData ?? []).where((item) {
        final text = widget.displayText(item).toLowerCase();
        return text.contains(keyword.toLowerCase());
      }).toList();

      setState(() {
        _displayOptions = filtered;
      });
    }
  }

  /// 防抖远程搜索
  void _debouncedRemoteSearch(String keyword) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(milliseconds: widget.searchDebounceMs), () {
      _fetchRemoteData(keyword: keyword.isEmpty ? null : keyword);
    });
  }

  /// 点击搜索按钮
  void _onSearchButtonClick() {
    _debounceTimer?.cancel();
    _fetchRemoteData(keyword: _searchKeyword.isEmpty ? null : _searchKeyword);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitleInfo(title: widget.title, options: _displayOptions),
        InputKeyword(
          onSearch: _handleSearch,
          showSearchButton: widget.showSearchButton,
          onSearchButtonClick: widget.showSearchButton ? _onSearchButtonClick : null,
          debounceMilliseconds: widget.searchDebounceMs,
        ),
        Expanded(child: _buildContent()),
        if (widget.showAdd == true) NoDataAdd(),
      ],
    );
  }

  Widget _buildContent() {
    // Loading 状态
    if (_isLoading) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(), SizedBox(height: 16), Text('加载中...')]),
      );
    }

    // 错误状态
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            SizedBox(height: 16),
            Text('加载失败: $_errorMessage'),
            SizedBox(height: 16),
            ElevatedButton(onPressed: _loadInitialData, child: Text('重试')),
          ],
        ),
      );
    }

    // 空数据状态
    if (_displayOptions == null || _displayOptions!.isEmpty) {
      return NoData();
    }

    // 正常显示数据
    return ContentShow<R, T>(
      options: _displayOptions!,
      displayText: widget.displayText,
      valueExtractor: widget.valueExtractor,
      defaultValue: widget.defaultValue,
      isMultiSelect: widget.isMultiSelect,
      onChange: widget.onChange,
      onConfirm: widget.onConfirm,
    );
  }
}
