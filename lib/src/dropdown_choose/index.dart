import 'package:flutter/material.dart';
import 'package:lite_simple_ui/widgets/bottom_modal_sheet/index.dart';

class DropdownChoose extends StatefulWidget {
  const DropdownChoose({super.key});
  @override
  State<DropdownChoose> createState() => _DropdownChooseState();
}

class UserInfo {
  final String name;
  final int age;
  final int id;
  UserInfo({required this.name, required this.age, required this.id});
}

class _DropdownChooseState extends State<DropdownChoose> {
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

  int? _selectedId; // 维护选中的 ID

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        // 方式1: 极简模式（数据有 name 和 id 字段时使用）
        final res = await BottomModalSheet.show<int, UserInfo>(
          context,
          title: '请选择用户',
          options: users,
          defaultValue: _selectedId, // 传入上次的选中值
        );

        if (res != null) {
          setState(() {
            _selectedId = res; // 更新状态
          });
          print('选中的用户ID: $res');
        }

        // 方式2: 自定义显示字段和返回值
        // final res = await BottomModalSheet.show<int, UserInfo>(
        //   context,
        //   title: '请选择用户',
        //   options: users,
        //   displayText: (user) => '${user.name} (年龄:${user.age})',
        //   valueExtractor: (user) => user.id,
        // );
      },
      child: Text(_selectedId != null ? '已选择: $_selectedId (点击修改)' : '组件内容'),
    );
  }
}
