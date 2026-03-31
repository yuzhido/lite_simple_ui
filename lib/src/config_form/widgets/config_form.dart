import 'package:flutter/material.dart';
import '../src/form_item.dart';
import '../src/form_config.dart';
import '../src/config_form_controller.dart';
import '../src/enums.dart';
import 'vertical_layout.dart';
import 'horizontal_layout.dart';

/// 配置表单主组件
class ConfigForm extends StatefulWidget {
  /// 表单项列表
  final List<FormItem> items;

  /// 表单配置
  final FormConfig? config;

  /// 表单控制器
  final ConfigFormController? controller;

  /// 提交回调
  final Function(Map<String, dynamic>)? onSubmit;

  const ConfigForm({super.key, required this.items, this.config, this.controller, this.onSubmit});

  @override
  State<ConfigForm> createState() => _ConfigFormState();
}

class _ConfigFormState extends State<ConfigForm> {
  late ConfigFormController _controller;
  late VerticalLayoutStrategy _verticalStrategy;
  late HorizontalLayoutStrategy _horizontalStrategy;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ConfigFormController();
    _controller.initializeValues(widget.items);
    _verticalStrategy = VerticalLayoutStrategy();
    _horizontalStrategy = HorizontalLayoutStrategy();
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config ?? const FormConfig();

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Column(
          children: widget.items.map((item) {
            return Padding(
              padding: config.padding ?? const EdgeInsets.symmetric(vertical: 8),
              child: config.layout == LayoutStyle.vertical
                  ? _verticalStrategy.buildFormItem(context, item, _controller, config)
                  : _horizontalStrategy.buildFormItem(context, item, _controller, config),
            );
          }).toList(),
        );
      },
    );
  }

  @override
  void dispose() {
    // 如果控制器是内部创建的，需要 dispose
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }
}
