import 'package:flutter/material.dart';

class BiletFlowApp extends StatelessWidget {
  const BiletFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BiletFlow',
      debugShowCheckedModeBanner: false,
      home: const Scaffold(
        body: Center(
          child: Text('BiletFlow'),
        ),
      ),
    );
  }
}