import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Asosiy Sahifa")),
      body: const Center(
        child: Text("Siz muvaffaqiyatli kirdingiz!"),
      ),
    );
  }
}