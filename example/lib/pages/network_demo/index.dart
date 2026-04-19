import 'package:flutter/material.dart';
import '../../api/user.dart';
import '../../core/network/index.dart';

class NetworkDemoPage extends StatefulWidget {
  const NetworkDemoPage({super.key});

  @override
  State<NetworkDemoPage> createState() => _NetworkDemoPageState();
}

class _NetworkDemoPageState extends State<NetworkDemoPage> {
  String _result = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 初始化 HTTP 客户端
    final httpClient = HttpClient.getInstance();

    // API 地址配置
    const String baseUrl = 'http://192.168.1.20:3001/api';

    httpClient.configure(baseUrl: baseUrl, connectTimeout: 30000, receiveTimeout: 30000, sendTimeout: 30000, enableLog: true);

    debugPrint('🌐 API Base URL: $baseUrl');
  }

  /// 获取用户列表（分页）
  Future<void> _testGetPage() async {
    setState(() {
      _isLoading = true;
      _result = '正在加载用户列表...';
    });

    try {
      final pageData = await UserApi.getPage(page: 1, limit: 5);

      setState(() {
        _result =
            '✅ 获取用户列表成功\n\n'
            '总数: ${pageData.total}\n'
            '当前页: ${pageData.page}\n'
            '每页数量: ${pageData.limit}\n'
            '总页数: ${pageData.pages}\n\n'
            '用户列表:\n'
            '${pageData.list.map((user) => '  - ${user.username} (${user.email})').join('\n')}';
      });
    } on ApiException catch (e) {
      setState(() {
        _result = '❌ 错误: ${e.code}\n消息: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _result = '❌ 未知错误: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 搜索用户
  Future<void> _testSearch() async {
    setState(() {
      _isLoading = true;
      _result = '正在搜索用户...';
    });

    try {
      final pageData = await UserApi.search(keyword: 'test', page: 1, limit: 10);

      setState(() {
        _result =
            '✅ 搜索成功\n\n'
            '关键字: test\n'
            '找到 ${pageData.total} 个结果\n\n'
            '${pageData.list.isEmpty ? '暂无结果' : pageData.list.map((user) => '  - ${user.username}').join('\n')}';
      });
    } on ApiException catch (e) {
      setState(() {
        _result = '❌ 错误: ${e.message}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 获取用户详情
  Future<void> _testGetUser() async {
    setState(() {
      _isLoading = true;
      _result = '正在获取用户详情...\n提示: 请先获取列表查看用户ID';
    });

    try {
      // 先获取第一个用户的 ID
      final pageData = await UserApi.getPage(page: 1, limit: 1);
      if (pageData.list.isEmpty) {
        setState(() {
          _result = '⚠️ 没有用户数据，请先创建用户';
        });
        return;
      }

      final userId = pageData.list.first.id;
      final user = await UserApi.getUser(userId);

      setState(() {
        _result =
            '✅ 获取用户详情成功\n\n'
            'ID: ${user.id}\n'
            '用户名: ${user.username}\n'
            '邮箱: ${user.email}\n'
            '角色: ${user.role}\n'
            '是否激活: ${user.isActive ? "是" : "否"}\n'
            '头像: ${user.avatar ?? "无"}\n'
            '创建时间: ${user.createdAt?.toString().substring(0, 19) ?? "无"}';
      });
    } on ApiException catch (e) {
      setState(() {
        _result = '❌ 错误: ${e.code}\n消息: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _result = '❌ 未知错误: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 创建用户
  Future<void> _testAddUser() async {
    setState(() {
      _isLoading = true;
      _result = '正在创建用户...';
    });

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newUser = await UserApi.add(username: 'test_user_$timestamp', email: 'test$timestamp@example.com', password: '123456', role: 'user', isActive: true);

      setState(() {
        _result =
            '✅ 创建用户成功\n\n'
            'ID: ${newUser.id}\n'
            '用户名: ${newUser.username}\n'
            '邮箱: ${newUser.email}\n'
            '角色: ${newUser.role}';
      });
    } on ApiException catch (e) {
      setState(() {
        _result = '❌ 创建失败: ${e.code}\n消息: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _result = '❌ 未知错误: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 更新用户
  Future<void> _testUpdateUser() async {
    setState(() {
      _isLoading = true;
      _result = '正在更新用户...';
    });

    try {
      // 先获取第一个用户
      final pageData = await UserApi.getPage(page: 1, limit: 1);
      if (pageData.list.isEmpty) {
        setState(() {
          _result = '⚠️ 没有用户数据，请先创建用户';
        });
        return;
      }

      final userId = pageData.list.first.id;
      final updatedUser = await UserApi.update(id: userId, username: 'updated_user', role: 'admin');

      setState(() {
        _result =
            '✅ 更新用户成功\n\n'
            'ID: ${updatedUser.id}\n'
            '新用户名: ${updatedUser.username}\n'
            '新角色: ${updatedUser.role}';
      });
    } on ApiException catch (e) {
      setState(() {
        _result = '❌ 更新失败: ${e.code}\n消息: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _result = '❌ 未知错误: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 删除用户
  Future<void> _testDeleteUser() async {
    setState(() {
      _isLoading = true;
      _result = '正在删除用户...';
    });

    try {
      // 先获取第一个用户
      final pageData = await UserApi.getPage(page: 1, limit: 1);
      if (pageData.list.isEmpty) {
        setState(() {
          _result = '⚠️ 没有用户数据';
        });
        return;
      }

      final userId = pageData.list.first.id;
      final success = await UserApi.delete(userId);

      setState(() {
        _result = success ? '✅ 删除用户成功\nID: $userId' : '❌ 删除失败';
      });
    } on ApiException catch (e) {
      setState(() {
        _result = '❌ 删除失败: ${e.code}\n消息: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _result = '❌ 未知错误: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 获取管理员列表
  Future<void> _testGetAdmins() async {
    setState(() {
      _isLoading = true;
      _result = '正在获取管理员列表...';
    });

    try {
      final pageData = await UserApi.getByRole(role: 'admin', page: 1, limit: 10);

      setState(() {
        _result =
            '✅ 获取管理员列表成功\n\n'
            '总数: ${pageData.total}\n\n'
            '${pageData.list.isEmpty ? '暂无管理员' : pageData.list.map((user) => '  - ${user.username} (${user.email})').join('\n')}';
      });
    } on ApiException catch (e) {
      setState(() {
        _result = '❌ 错误: ${e.message}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 获取激活用户
  Future<void> _testGetActiveUsers() async {
    setState(() {
      _isLoading = true;
      _result = '正在获取激活用户...';
    });

    try {
      final pageData = await UserApi.getActiveUsers(page: 1, limit: 10);

      setState(() {
        _result =
            '✅ 获取激活用户成功\n\n'
            '总数: ${pageData.total}\n\n'
            '${pageData.list.map((user) => '  - ${user.username}').join('\n')}';
      });
    } on ApiException catch (e) {
      setState(() {
        _result = '❌ 错误: ${e.message}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UserApi 测试'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _result = '';
              });
            },
            tooltip: '清空结果',
          ),
        ],
      ),
      body: Column(
        children: [
          // 按钮区域
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testGetPage,
                  icon: const Icon(Icons.list),
                  label: const Text('获取列表'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testSearch,
                  icon: const Icon(Icons.search),
                  label: const Text('搜索用户'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testGetUser,
                  icon: const Icon(Icons.person),
                  label: const Text('获取详情'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testAddUser,
                  icon: const Icon(Icons.add),
                  label: const Text('创建用户'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testUpdateUser,
                  icon: const Icon(Icons.edit),
                  label: const Text('更新用户'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testDeleteUser,
                  icon: const Icon(Icons.delete),
                  label: const Text('删除用户'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testGetAdmins,
                  icon: const Icon(Icons.admin_panel_settings),
                  label: const Text('管理员列表'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testGetActiveUsers,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('激活用户'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.lightGreen, foregroundColor: Colors.white),
                ),
              ],
            ),
          ),

          const Divider(),

          // 结果显示区域
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              padding: const EdgeInsets.all(12),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_result.isEmpty)
                      const Text(
                        '👆 点击上方按钮测试 API\n\n'
                        '💡 提示：\n'
                        '• 先点击“创建用户”添加测试数据\n'
                        '• 然后点击“获取列表”查看用户\n'
                        '• 其他操作会自动使用现有数据',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      )
                    else
                      SelectableText(_result, style: const TextStyle(fontFamily: 'monospace', fontSize: 13, height: 1.5)),
                  ],
                ),
              ),
            ),
          ),

          // Loading 指示器
          if (_isLoading)
            Container(
              padding: const EdgeInsets.all(16),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  SizedBox(width: 12),
                  Text('请求处理中...'),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
