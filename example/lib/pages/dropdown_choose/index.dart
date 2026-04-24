import 'package:flutter/material.dart';
import 'package:lite_simple_ui/lite_simple_ui.dart';
import 'package:lite_simple_ui/src/dropdown_choose/display_mode.dart';

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

  // 回调示例状态
  int? _singleUserId;
  List<int>? _multiUserIds;

  @override
  void dispose() {
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
              const Text('单选模式 - onChange回调示例:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownChoose<int, UserInfo>(
                options: users,
                label: '用户',
                defaultValue: _singleUserId,
                onChange: (id, user, isSelected) {
                  setState(() {
                    _singleUserId = id;
                  });
                  print('✅ 单选onChange触发 - ID: $id, 姓名: ${user.name}, 年龄: ${user.age}, isSelected: $isSelected');
                },
              ),
              if (_singleUserId != null)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Text('已选择: ${users.firstWhere((u) => u.id == _singleUserId).name}', style: TextStyle(color: Colors.green.shade700, fontSize: 12)),
                ),
              const SizedBox(height: 20),
              const Text('多选模式 - onChange + onConfirm双回调示例:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownChoose<int, UserInfo>(
                options: users,
                isMultiSelect: true,
                label: '用户',
                tip: '请选择多个用户',
                defaultValue: _multiUserIds,
                onChange: (id, user, isSelected) {
                  print('🔄 多选onChange触发 - ID: $id, 姓名: ${user.name}, isSelected: $isSelected');
                },
                onConfirm: (ids, userList) {
                  setState(() {
                    _multiUserIds = ids;
                  });
                  print('✅ 多选onConfirm触发 - 选中数量: ${userList.length}');
                  print('   ID列表: $ids');
                  print('   用户列表: ${userList.map((u) => u.name).join(", ")}');
                },
              ),
              if (_multiUserIds != null && _multiUserIds!.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '已确认选择 ${_multiUserIds!.length} 个用户:',
                        style: TextStyle(color: Colors.blue.shade700, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(_multiUserIds!.map((id) => users.firstWhere((u) => u.id == id).name).join(', '), style: TextStyle(color: Colors.blue.shade600, fontSize: 12)),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              const Text('多选模式 - 纯文本显示:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownChoose<int, UserInfo>(options: users, isMultiSelect: true, label: '用户', displayMode: DropdownDisplayMode.text),
              const SizedBox(height: 20),
              const Text('多选模式 - 折叠显示 (+N更多):', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownChoose<int, UserInfo>(options: users, isMultiSelect: true, label: '用户', displayMode: DropdownDisplayMode.compact, maxVisibleTags: 2),
              const SizedBox(height: 20),
              const Text('多选模式 - 自定义显示 (头像示例):', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownChoose<int, UserInfo>(
                options: users,
                isMultiSelect: true,
                label: '用户',
                customDisplayBuilder: (context, selectedItems) {
                  if (selectedItems.isEmpty) return const Text('请选择用户', style: TextStyle(color: Colors.grey));
                  return Wrap(
                    spacing: 4,
                    children: selectedItems
                        .map(
                          (user) => Chip(
                            avatar: CircleAvatar(backgroundColor: Colors.blue.shade100, child: Text(user.name[0])),
                            label: Text(user.name, style: const TextStyle(fontSize: 12)),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 20),
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
                        print('单选用户ID: $_singleUserId');
                        print('多选用户IDs: $_multiUserIds');
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
                        _singleUserId = null;
                        _multiUserIds = null;
                      });
                    },
                    child: const Text('重置'),
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
