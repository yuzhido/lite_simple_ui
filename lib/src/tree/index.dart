import 'package:flutter/material.dart';

class Tree extends StatefulWidget {
  const Tree({super.key});
  @override
  State<Tree> createState() => _TreeState();
}

class _TreeState extends State<Tree> {
  @override
  Widget build(BuildContext context) {
    return const Text('组件内容');
  }
}
