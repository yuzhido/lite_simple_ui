import 'package:example/pages/button/index.dart';
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
                  width: double.infinity,
                  height: 48,
                  backgroundColor: Colors.blue,
                  disabledColor: Colors.grey.shade300,
                  loadingWidget: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))),
                      SizedBox(width: 8),
                      Text('加载中...', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  onTap: () async {
                    await AppRouter.push(context, const ButtonPage());
                  },
                  child: const Text(
                    '点击进入按钮页面',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
