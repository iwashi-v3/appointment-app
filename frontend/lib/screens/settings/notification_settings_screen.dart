import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _messages = true;
  bool _groups = true;
  bool _appUpdates = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('通知設定'),
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: AppColors.textBody),
        titleTextStyle: const TextStyle(color: AppColors.textBody, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('メッセージ通知'),
            subtitle: const Text('DMを受信した時に通知します'),
            activeColor: AppColors.primary,
            value: _messages,
            onChanged: (val) => setState(() => _messages = val),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('グループ通知'),
            subtitle: const Text('グループメッセージの通知'),
            activeColor: AppColors.primary,
            value: _groups,
            onChanged: (val) => setState(() => _groups = val),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('アプリからのお知らせ'),
            activeColor: AppColors.primary,
            value: _appUpdates,
            onChanged: (val) => setState(() => _appUpdates = val),
          ),
        ],
      ),
    );
  }
}