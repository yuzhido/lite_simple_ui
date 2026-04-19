import 'package:flutter/material.dart';
import 'package:lite_simple_ui/lite_simple_ui.dart';

class DropdownChoosePage extends StatefulWidget {
  const DropdownChoosePage({super.key});
  @override
  State<DropdownChoosePage> createState() => _DropdownChoosePageState();
}

class UserInfo {
  final String name;
  final int age;
  final int id;
  UserInfo({required this.name, required this.age, required this.id});
}

class _DropdownChoosePageState extends State<DropdownChoosePage> {
  List<UserInfo> users = [
    UserInfo(name: '张三', age: 18, id: 15555555555121223),
    UserInfo(name: '李四', age: 19, id: 25555555555121223),
    UserInfo(name: '王五', age: 20, id: 35555555555121223),
    UserInfo(name: '张柳', age: 20, id: 45555555555121223),
    UserInfo(name: '李五', age: 21, id: 55555555555121223),
    UserInfo(name: '赵六', age: 22, id: 65555555555121223),
    UserInfo(name: '孙七', age: 23, id: 75555555555121223),
    UserInfo(name: '赵六', age: 24, id: 65555555555121223),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('导航栏标题')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('单选模式:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownChoose<int, UserInfo>(options: users),
            const SizedBox(height: 20),
            const Text('多选模式:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownChoose<int, UserInfo>(options: users, isMultiSelect: true),
          ],
        ),
      ),
    );
  }
}
