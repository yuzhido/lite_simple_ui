import 'package:flutter/material.dart';
import 'widgets/index.dart';
import '../choose_tree/index.dart';
import '../dropdown_choose/index.dart';
import '../config_form/index.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// 构建组件入口卡片
  Widget _buildComponentSection(BuildContext context, {required String title, required String description, required VoidCallback onTap}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.touch_app, color: Theme.of(context).primaryColor, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right, color: Colors.grey.shade400),
                ],
              ),
              const SizedBox(height: 8),
              Text(description, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('UI 组件示例使用分类主页')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 新增组件入口
            _buildComponentSection(
              context,
              title: '下拉选择组件',
              description: '支持单选、多选，底部弹窗式选择界面',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const DropdownChooseExamplePage()));
              },
            ),
            const SizedBox(height: 12),
            // 树形选择组件
            _buildComponentSection(
              context,
              title: '树形选择组件',
              description: '支持树形数据展示、层级联动选择',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ChooseTreePage()));
              },
            ),
            const SizedBox(height: 12),
            // 配置表单组件
            _buildComponentSection(
              context,
              title: '配置表单组件',
              description: '支持多种验证方式、灵活布局风格的表单组件',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ConfigFormExample()));
              },
            ),
            const SizedBox(height: 24),
            // 原有组件
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [BasicFormInfo(), UploadFile(), DataShow()]),
          ],
        ),
      ),
    );
  }
}
