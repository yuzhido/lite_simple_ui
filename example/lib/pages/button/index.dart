import 'package:flutter/material.dart';
import 'package:lite_simple_ui/lite_simple_ui.dart';

class ButtonPage extends StatefulWidget {
  const ButtonPage({super.key});
  @override
  State<ButtonPage> createState() => _ButtonPageState();
}

class _ButtonPageState extends State<ButtonPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('按钮使用示例页面'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('1. 简洁用法 - 直接传递文字（同步）'),
            _buildExample1(),
            const SizedBox(height: 24),
            _buildSectionTitle('2. 异步操作 - 自动显示 loading'),
            _buildExample2(),
            const SizedBox(height: 24),
            _buildSectionTitle('3. 自定义 Widget'),
            _buildExample3(),
            const SizedBox(height: 24),
            _buildSectionTitle('4. 自定义样式'),
            _buildExample4(),
            const SizedBox(height: 24),
            _buildSectionTitle('5. 自定义加载动画'),
            _buildExample5(),
            const SizedBox(height: 24),
            _buildSectionTitle('6. 自定义加载文字样式'),
            _buildExample6(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  /// 示例1：简洁用法 - 直接传递文字（同步）
  Widget _buildExample1() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Button(
          text: '点击我',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('同步操作')));
          },
        ),
      ),
    );
  }

  /// 示例2：异步操作 - 自动显示 loading
  Widget _buildExample2() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Button(
          text: '提交232313131',
          onTap: () async {
            await Future.delayed(const Duration(seconds: 2));
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('提交成功！')));
            }
          },
        ),
      ),
    );
  }

  /// 示例3：自定义 Widget
  Widget _buildExample3() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Button(
          child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.send, size: 18), SizedBox(width: 8), Text('发送')]),
          onTap: () async {
            await Future.delayed(const Duration(seconds: 1));
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('发送成功！')));
            }
          },
        ),
      ),
    );
  }

  /// 示例4：自定义样式
  Widget _buildExample4() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Button(
          text: '确认',
          width: 200,
          height: 50,
          backgroundColor: Colors.blue,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已确认')));
          },
        ),
      ),
    );
  }

  /// 示例5：自定义加载动画
  Widget _buildExample5() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Button(
          text: '保存',
          loadingWidget: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))),
              SizedBox(width: 8),
              Text('保存中...', style: TextStyle(color: Colors.white)),
            ],
          ),
          onTap: () async {
            await Future.delayed(const Duration(seconds: 3));
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('保存成功！')));
            }
          },
        ),
      ),
    );
  }

  /// 示例6：自定义加载文字样式
  Widget _buildExample6() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Button(
          text: '上传',
          loadingText: '上传中...',
          loadingTextColor: Colors.yellow,
          loadingTextSize: 14,
          backgroundColor: Colors.orange,
          onTap: () async {
            await Future.delayed(const Duration(seconds: 2));
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('上传成功！')));
            }
          },
        ),
      ),
    );
  }
}
