import 'package:flutter/material.dart';

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToDoodle',
      home: Scaffold(body: const Center(child: Text("Let's go!"))),
    );
  }
}
