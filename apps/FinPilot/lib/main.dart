import 'package:flutter/material.dart';

void main() {
  runApp(const FinPilotApp());
}

class FinPilotApp extends StatelessWidget {
  const FinPilotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinPilot',
      debugShowCheckedModeBanner: false,
      home: const Scaffold(body: Center(child: Text('FinPilot'))),
    );
  }
}
