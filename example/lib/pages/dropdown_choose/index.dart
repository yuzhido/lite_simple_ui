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

  // 表单相关变量
  final _formKey = GlobalKey<FormState>();

  // 控制器
  final _userController = DropdownChooseController<int>();
  final _multiUserController = DropdownChooseController<int>();

  // 表单字段值
  int? _selectedUserId;
  List<int>? _selectedUserIds;
  int? _customDisplayUserId;
  List<int>? _multiSelectUserIds;

  @override
  void dispose() {
    _userController.dispose();
    _multiUserController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('导航栏标题')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('单选模式:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownChoose<int, UserInfo>(
                options: users,
                label: '用户',
                selectedValue: _selectedUserId,
                validator: (value) {
                  if (value == null) {
                    return '请选择用户';
                  }
                  return null;
                },
                onChange: (r, data, bool? isSelected) {
                  setState(() {
                    _selectedUserId = r;
                  });
                  print('选中这是最后从的结果: $r, ${data.name}');
                  print('是否选中$isSelected');
                },
              ),
              const SizedBox(height: 20),
              const Text('单选回显模式:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownChoose<int, UserInfo>(
                options: users,
                selectedValue: _selectedUserId ?? 25555555555121223,
                label: '用户（回显）',
                validator: (value) {
                  if (value == null) {
                    return '请选择用户';
                  }
                  return null;
                },
                onChange: (r, data, bool? isSelected) {
                  setState(() {
                    _selectedUserId = r;
                  });
                },
              ),
              const SizedBox(height: 20),
              const Text('自定义显示文本:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownChoose<int, UserInfo>(
                options: users,
                selectedValue: _customDisplayUserId ?? 25555555555121223,
                displayText: (user) => '${user.name}(${user.age}岁)',
                label: '自定义显示',
                validator: (value) {
                  if (value == null) {
                    return '请选择用户';
                  }
                  return null;
                },
                onChange: (r, data, bool? isSelected) {
                  setState(() {
                    _customDisplayUserId = r;
                  });
                },
              ),
              const SizedBox(height: 20),
              const Text('多选模式:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownChoose<int, UserInfo>(
                options: users,
                isMultiSelect: true,
                selectedValues: _selectedUserIds,
                label: '多选用户',
                validator: (value) {
                  final list = value as List?;
                  if (list == null || list.isEmpty) {
                    return '请至少选择一个用户';
                  }
                  return null;
                },
                onConfirm: (r, data) {
                  setState(() {
                    _selectedUserIds = r;
                  });
                  print('多选最后666999确认的结果: $r, $data');
                },
                onChange: (r, data, bool? isSelected) {
                  print('选中这是最后从的结果: $r, ${data.name}');
                  print('是否选中$isSelected');
                },
              ),
              const SizedBox(height: 20),
              const Text('多选回显模式:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownChoose<int, UserInfo>(
                options: users,
                isMultiSelect: true,
                selectedValues: _multiSelectUserIds ?? [25555555555121223, 65555555555121223],
                label: '多选用户（回显）',
                validator: (value) {
                  final list = value as List?;
                  if (list == null || list.isEmpty) {
                    return '请至少选择一个用户';
                  }
                  return null;
                },
                onConfirm: (r, data) {
                  setState(() {
                    _multiSelectUserIds = r;
                  });
                },
              ),
              const SizedBox(height: 30),
              // 表单操作按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // 表单验证通过
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('表单验证通过'), backgroundColor: Colors.green));

                        // 打印当前选中的值
                        print('单选用户ID: $_selectedUserId');
                        print('多选用户IDs: $_selectedUserIds');
                        print('自定义显示用户ID: $_customDisplayUserId');
                        print('多选回显用户IDs: $_multiSelectUserIds');
                      } else {
                        // 表单验证失败
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请完善表单信息'), backgroundColor: Colors.red));
                      }
                    },
                    child: const Text('提交'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // 重置表单
                      _formKey.currentState!.reset();
                      setState(() {
                        _selectedUserId = null;
                        _selectedUserIds = null;
                        _customDisplayUserId = null;
                        _multiSelectUserIds = null;
                      });
                    },
                    child: const Text('重置'),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text('控制器示例:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownChoose<int, UserInfo>(
                options: users,
                label: '用户（控制器）',
                controller: _userController,
                validator: (value) {
                  if (value == null) return '请选择用户';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              DropdownChoose<int, UserInfo>(
                options: users,
                isMultiSelect: true,
                label: '多选用户（控制器）',
                controller: _multiUserController,
                validator: (value) {
                  final list = value as List?;
                  if (list == null || list.isEmpty) return '请至少选择一个用户';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // 控制器操作按钮
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // 设置值
                      _userController.setValue(25555555555121223);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已设置值为: 李四'), backgroundColor: Colors.green));
                    },
                    child: const Text('设置值'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // 获取值
                      final value = _userController.value;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('当前值: $value'), backgroundColor: Colors.blue));
                    },
                    child: const Text('获取值'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // 清空值
                      _userController.clear();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已清空'), backgroundColor: Colors.orange));
                    },
                    child: const Text('清空'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // 设置多选值
                      _multiUserController.setValues([25555555555121223, 65555555555121223]);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已设置多选值'), backgroundColor: Colors.green));
                    },
                    child: const Text('设置多选值'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // 获取多选值
                      final values = _multiUserController.values;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('当前多选值: $values'), backgroundColor: Colors.blue));
                    },
                    child: const Text('获取多选值'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
