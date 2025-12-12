import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class FollowRequestsScreen extends StatelessWidget {
  const FollowRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('フォローリクエスト'),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textBody),
        titleTextStyle: const TextStyle(
          color: AppColors.textBody,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: 3, // ダミーデータ
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: const CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.secondary,
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text(
              'Request User $index',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textBody),
            ),
            subtitle: const Text('フォロー許可待ち', style: TextStyle(fontSize: 12, color: AppColors.textSub)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 拒否ボタン
                InkWell(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[400]!),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text('削除', style: TextStyle(fontSize: 12, color: AppColors.textSub)),
                  ),
                ),
                const SizedBox(width: 8),
                // 承認ボタン
                InkWell(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text('承認', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}