import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class BlockedUsersScreen extends StatelessWidget {
  const BlockedUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ブロック中のユーザー'),
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: AppColors.textBody),
        titleTextStyle: const TextStyle(color: AppColors.textBody, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      body: ListView.builder(
        itemCount: 3, // ダミー
        itemBuilder: (context, index) {
          return ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.grey,
              child: Icon(Icons.person_off, color: Colors.white),
            ),
            title: Text('Blocked User ${index + 1}'),
            trailing: OutlinedButton(
              onPressed: () {
                // 解除処理
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textBody,
                side: const BorderSide(color: AppColors.warmGray),
              ),
              child: const Text('解除'),
            ),
          );
        },
      ),
    );
  }
}