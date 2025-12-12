import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class TextContentScreen extends StatelessWidget {
  final String title;
  final String content;

  const TextContentScreen({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: AppColors.textBody),
        titleTextStyle: const TextStyle(color: AppColors.textBody, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Text(
          content,
          style: const TextStyle(fontSize: 14, height: 1.6, color: AppColors.textBody),
        ),
      ),
    );
  }
}