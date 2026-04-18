import 'package:flutter/material.dart';

class NoDataAdd extends StatelessWidget {
  const NoDataAdd({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('没有找到你想要的数据,去新增?'),
          ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.add), label: const Text('新增')),
        ],
      ),
    );
  }
}
