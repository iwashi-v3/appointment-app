import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

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
              // プロフィール編集画面へ遷移
            },
          ),
          _buildSettingTile(
            context,
            icon: Icons.notifications_outlined,
            title: '通知設定',
            onTap: () {
              // 通知設定画面へ遷移
            },
          ),
          _buildSettingTile(
            context,
            icon: Icons.block,
            title: 'ブロックユーザー管理',
            onTap: () {
              // ブロックリスト画面へ遷移
            },
          ),

          const SizedBox(height: 24),

          // --- サポート・情報セクション ---
          _buildSectionHeader('サポート・情報'),
          _buildSettingTile(
            context,
            icon: Icons.help_outline,
            title: 'ヘルプ・お問い合わせ',
            onTap: () {},
          ),
          _buildSettingTile(
            context,
            icon: Icons.description_outlined,
            title: '利用規約',
            onTap: () {},
          ),
          _buildSettingTile(
            context,
            icon: Icons.privacy_tip_outlined,
            title: 'プライバシーポリシー',
            onTap: () {},
          ),
          _buildSettingTile(
            context,
            icon: Icons.info_outline,
            title: 'バージョン情報',
            trailing: const Text(
              '1.0.0',
              style: TextStyle(color: AppColors.textSub, fontSize: 12),
            ),
            onTap: () {}, // バージョンタップは何もしなくてOK
          ),

          const SizedBox(height: 24),

          // --- その他（危険な操作など）セクション ---
          _buildSectionHeader('その他'),
          _buildSettingTile(
            context,
            icon: Icons.logout,
            title: 'ログアウト',
            textColor: AppColors.primary, // 目立たせるならメインカラーか
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

  // セクションのタイトル
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

  // 設定項目のタイル
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
              // ログアウト処理
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
              // 削除処理
              Navigator.pop(context);
            },
            child: const Text('削除する', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}