import 'package:flutter/material.dart';

class ContainerWrapper extends StatefulWidget {
  const ContainerWrapper({super.key});
  @override
  State<ContainerWrapper> createState() => _ContainerWrapperState();
}

class _ContainerWrapperState extends State<ContainerWrapper> {
  @override
  Widget build(BuildContext context) {
    return const Text('组件内容');
  }
}
