import 'package:example_use/pages/choose_tree/index.dart';
import 'package:example_use/pages/choose_tree/remote_search_example.dart';
import 'package:example_use/pages/choose_tree/default_value_example.dart';
import 'package:flutter/material.dart';

/// 组件信息数据模型
class ComponentInfo {
  final String title;
  final String description;
  final IconData icon;
  final Widget page;

  const ComponentInfo({required this.title, required this.description, required this.icon, required this.page});
}

class BasicFormInfo extends StatelessWidget {
  BasicFormInfo({super.key});

  // 组件列表数据
  final List<ComponentInfo> _components = [
    ComponentInfo(title: 'ChooseTree 树形选择器', description: '支持下拉、弹窗、列表三种展示模式，可单选/多选，支持远程搜索和懒加载', icon: Icons.list_alt, page: const ChooseTreePage()),
    ComponentInfo(title: '远程搜索示例', description: '演示远程搜索功能：实时搜索、点击搜索、缓存策略等配置', icon: Icons.search, page: const RemoteSearchExamplePage()),
    ComponentInfo(title: '默认值示例', description: '演示如何设置默认选中值：通过 value 属性控制初始化和动态更新', icon: Icons.check_circle_outline, page: const DefaultValueExamplePage()),
    // 后续添加新组件时，在这里配置即可
    // ComponentInfo(
    //   title: '新组件名称',
    //   description: '组件描述',
    //   icon: Icons.xxx,
    //   page: NewComponentPage(),
    // ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _components.map((component) {
        return _buildComponentCard(context, component);
      }).toList(),
    );
  }

  /// 构建组件卡片
  Widget _buildComponentCard(BuildContext context, ComponentInfo component) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(component.icon, size: 32, color: Colors.blue),
        title: Text(component.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        subtitle: Text(component.description, style: const TextStyle(fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => component.page));
        },
      ),
    );
  }
}
