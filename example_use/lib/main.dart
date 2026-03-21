import 'package:flutter/material.dart';

import 'pages/home/index.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '组件使用示例',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        appBarTheme: AppBarTheme(color: Theme.of(context).colorScheme.inversePrimary),
      ),
      home: const HomePage(),
    );
  }
}
