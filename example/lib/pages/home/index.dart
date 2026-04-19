import 'package:example/pages/button/index.dart';
import 'package:example/pages/dropdown_choose/index.dart';
import 'package:example/pages/network_demo/index.dart';
import 'package:flutter/material.dart';
import 'package:lite_simple_ui/lite_simple_ui.dart';

import '../../router/index.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('当前项目中组件使用示例')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Button(
                  height: 48,
                  onTap: () async {
                    await AppRouter.push(context, const ButtonPage());
                  },
                  child: const Text('点击进入按钮页面', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                ),
              ),
            ),
            // 下拉选择
            Button(
              text: '点击进入下拉选择页面',
              onTap: () {
                AppRouter.push(context, const DropdownChoosePage());
              },
            ),
            Button(
              text: '点击进入网络请求页面',
              onTap: () {
                AppRouter.push(context, const NetworkDemoPage());
              },
            ),
          ],
        ),
      ),
    );
  }
}
