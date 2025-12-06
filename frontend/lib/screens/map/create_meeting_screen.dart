import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class CreateMeetingScreen extends StatelessWidget {
  const CreateMeetingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('待ち合わせの新規作成'),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textBody),
        titleTextStyle: const TextStyle(
          color: AppColors.textBody,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.edit_location_alt, size: 64, color: AppColors.warmGray),
            SizedBox(height: 16),
            Text(
              'ここでピンを立てたり\n時間を設定します\n(Page 5)',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSub),
            ),
          ],
        ),
      ),
    );
  }
}