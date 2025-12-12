import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import 'edit_profile_screen.dart';        // プロフィール編集画面
import 'notification_settings_screen.dart'; // 通知設定画面
import 'blocked_users_screen.dart';       // ブロックユーザー管理画面
import 'text_content_screen.dart';        // テキスト表示画面（規約等）

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setting'),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: AppColors.textBody,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),

          // --- アカウント設定セクション ---
          _buildSectionHeader('アカウント'),
          _buildSettingTile(
            context,
            icon: Icons.person_outline,
            title: 'プロフィール編集',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditProfileScreen()),
              );
            },
          ),
          _buildSettingTile(
            context,
            icon: Icons.notifications_outlined,
            title: '通知設定',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationSettingsScreen()),
              );
            },
          ),
          _buildSettingTile(
            context,
            icon: Icons.block,
            title: 'ブロックユーザー管理',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BlockedUsersScreen()),
              );
            },
          ),

          const SizedBox(height: 24),

          // --- サポート・情報セクション ---
          _buildSectionHeader('サポート・情報'),
          _buildSettingTile(
            context,
            icon: Icons.help_outline,
            title: 'ヘルプ・お問い合わせ',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TextContentScreen(
                    title: 'ヘルプ・お問い合わせ',
                    content: 'ここにFAQやお問い合わせフォームへのリンクなどを記載します。\n\n・使い方がわからない場合\n・不具合を見つけた場合\n...',
                  ),
                ),
              );
            },
          ),
          _buildSettingTile(
            context,
            icon: Icons.description_outlined,
            title: '利用規約',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TextContentScreen(
                    title: '利用規約',
                    content: '第1条（目的）\nこの利用規約は、本アプリの利用条件を定めるものです。\n\n第2条（定義）\n...',
                  ),
                ),
              );
            },
          ),
          _buildSettingTile(
            context,
            icon: Icons.privacy_tip_outlined,
            title: 'プライバシーポリシー',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TextContentScreen(
                    title: 'プライバシーポリシー',
                    content: '1. 個人情報の収集について\n当アプリでは、サービスの提供に必要な範囲で...\n\n2. 情報の利用目的\n取得した情報は以下の目的で利用します...',
                  ),
                ),
              );
            },
          ),
          _buildSettingTile(
            context,
            icon: Icons.info_outline,
            title: 'バージョン情報',
            trailing: const Text(
              '1.0.0',
              style: TextStyle(color: AppColors.textSub, fontSize: 12),
            ),
            onTap: () {},
          ),

          const SizedBox(height: 24),

          // --- その他（危険な操作など）セクション ---
          _buildSectionHeader('その他'),
          _buildSettingTile(
            context,
            icon: Icons.logout,
            title: 'ログアウト',
            textColor: AppColors.primary,
            iconColor: AppColors.primary,
            onTap: () => _showLogoutDialog(context),
          ),
          _buildSettingTile(
            context,
            icon: Icons.delete_forever,
            title: 'アカウント削除',
            textColor: Colors.red,
            iconColor: Colors.red,
            onTap: () => _showDeleteAccountDialog(context),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // セクションのタイトルウィジェット
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textSub,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // 設定項目のタイルウィジェット
  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? AppColors.textBody),
        title: Text(
          title,
          style: TextStyle(
            color: textColor ?? AppColors.textBody,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: trailing ?? const Icon(Icons.chevron_right, color: AppColors.warmGray),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ログアウト確認ダイアログ
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ログアウト'),
        content: const Text('ログアウトしますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル', style: TextStyle(color: AppColors.textSub)),
          ),
          TextButton(
            onPressed: () {
              // ログアウト処理をここに記述
              Navigator.pop(context);
            },
            child: const Text('ログアウト', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  // アカウント削除確認ダイアログ
  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('アカウント削除'),
        content: const Text('アカウントを削除すると、全てのデータが消去され復元できません。本当によろしいですか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル', style: TextStyle(color: AppColors.textSub)),
          ),
          TextButton(
            onPressed: () {
              // 削除処理をここに記述
              Navigator.pop(context);
            },
            child: const Text('削除する', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}