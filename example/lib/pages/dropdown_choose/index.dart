import 'package:flutter/material.dart';
import 'package:lite_simple_ui/lite_simple_ui.dart';

class DropdownChoosePage extends StatefulWidget {
  const DropdownChoosePage({super.key});
  @override
  State<DropdownChoosePage> createState() => _DropdownChoosePageState();
}

class _DropdownChoosePageState extends State<DropdownChoosePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('导航栏标题')),
      body: Column(
        children: [
          //
          DropdownChoose(),
          const Text('页面内容正在开发中...'),
        ],
      ),
    );
  }
}
