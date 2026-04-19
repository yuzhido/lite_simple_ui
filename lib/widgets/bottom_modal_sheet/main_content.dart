import 'package:flutter/material.dart';

import 'content_show.dart';
import 'input_keyword.dart';
import 'no_data.dart';
import 'no_data_add.dart';
import 'title_info.dart';

class MainContent<R, T> extends StatefulWidget {
  final String? title;
  final bool? showAdd;
  final bool? remote;
  final bool? forceRefresh;
  final Future<List<T>?> Function()? remoteMethod;
  final List<T>? options;
  final String Function(T) displayText;
  final R Function(T) valueExtractor;
  final R? defaultValue; // 新增：默认选中值
  final bool isMultiSelect;

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
    this.defaultValue, // 新增
    this.isMultiSelect = false,
  });
  @override
  State<MainContent<R, T>> createState() => _MainContentState<R, T>();
}

class _MainContentState<R, T> extends State<MainContent<R, T>> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max, // 填满固定高度
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitleInfo(title: widget.title, options: widget.options),
        InputKeyword(),
        // 有备选内容显示区域
        Expanded(
          child: ContentShow<R, T>(
            options: widget.options ?? [],
            displayText: widget.displayText,
            valueExtractor: widget.valueExtractor,
            defaultValue: widget.defaultValue, // 传递默认值
            isMultiSelect: widget.isMultiSelect,
          ),
        ),
        // 没有任何备选数据时显示
        if (widget.options?.isEmpty == true) Expanded(child: NoData()),
        // 有备选内容,但是远程获取数据时,新增数据按钮
        if (widget.showAdd == true) NoDataAdd(),
      ],
    );
  }
}
