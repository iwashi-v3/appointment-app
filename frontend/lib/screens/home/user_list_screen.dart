import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class UserListScreen extends StatelessWidget {
  final String title; // "フォロー中" や "フォロワー" などのタイトルを受け取る
  final bool isFollowingList; // フォロー中リストかどうかのフラグ（将来的なボタンの出し分け用）

  const UserListScreen({
    super.key,
    required this.title,
    required this.isFollowingList,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textBody), // 戻るボタンの色
      ),
      body: ListView.separated(
        itemCount: 15, // ダミーデータの数
        separatorBuilder: (context, index) => const Divider(height: 1, indent: 72),
        itemBuilder: (context, index) {
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.secondary,
              child: const Icon(Icons.person, color: Colors.white),
            ),
            title: Text(
              'User Name $index',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textBody),
            ),
            subtitle: const Text('Hello! Nice to meet you.', maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: ElevatedButton(
              onPressed: () {
                // フォロー/解除などのアクション
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isFollowingList ? Colors.grey[300] : AppColors.primary,
                foregroundColor: isFollowingList ? Colors.black54 : Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                minimumSize: const Size(80, 36),
              ),
              child: Text(isFollowingList ? 'フォロー中' : 'フォロー'),
            ),
            onTap: () {
              // ユーザー詳細へ飛ぶならここ
            },
          );
        },
      ),
    );
  }
}