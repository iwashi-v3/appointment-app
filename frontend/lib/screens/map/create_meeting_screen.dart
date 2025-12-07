import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/auth_guard.dart'; // AuthGuardをインポート

class CreateMeetingScreen extends StatefulWidget {
  // マップ画面から遷移するときに、ゲストかどうかを受け取る
  final bool isGuest;

  const CreateMeetingScreen({
    super.key,
    required this.isGuest,
  });

  @override
  State<CreateMeetingScreen> createState() => _CreateMeetingScreenState();
}

class _CreateMeetingScreenState extends State<CreateMeetingScreen> {
  // 入力状態の管理用変数
  bool _useCurrentLocation = false;
  TimeOfDay _selectedTime = TimeOfDay.now();
  int _inviteType = 0; // 0: フォロワー, 1: ゲスト(リンク)

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
      
      // ボディ全体を AuthGuard でラップする
      // isGuestがtrueの場合、中身は見えますがモザイクがかかり操作不能になります
      body: AuthGuard(
        isGuest: widget.isGuest,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- 1. 場所選択エリア (地図) ---
              const Text(
                '場所を選択',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSub),
              ),
              const SizedBox(height: 8),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.ice.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.secondary),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.location_on, size: 40, color: AppColors.primary),
                      SizedBox(height: 8),
                      Text('地図をタップしてピンを設置', style: TextStyle(color: AppColors.textBody)),
                    ],
                  ),
                ),
              ),
              
              // 現在地で待ち合わせチェック
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
                title: const Text('現在地で待ち合わせ', style: TextStyle(fontSize: 14, color: AppColors.textBody)),
                value: _useCurrentLocation,
                onChanged: (val) {
                  setState(() {
                    _useCurrentLocation = val ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),

              const SizedBox(height: 24),

              // --- 2. 時刻設定 ---
              const Text(
                '時刻を設定',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSub),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _selectedTime,
                  );
                  if (picked != null) {
                    setState(() => _selectedTime = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.warmGray.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, color: AppColors.primary),
                      const SizedBox(width: 16),
                      Text(
                        _selectedTime.format(context),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textBody),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // --- 3. 相手を選択 ---
              const Text(
                '待ち合わせ相手',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSub),
              ),
              const SizedBox(height: 8),
              Column(
                children: [
                  RadioListTile<int>(
                    title: const Text('フォロワーと待ち合わせ', style: TextStyle(fontSize: 14)),
                    subtitle: const Text('アプリ内で通知を送ります', style: TextStyle(fontSize: 12, color: AppColors.textSub)),
                    value: 0,
                    groupValue: _inviteType,
                    activeColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) => setState(() => _inviteType = val!),
                  ),
                  RadioListTile<int>(
                    title: const Text('ゲストと待ち合わせ', style: TextStyle(fontSize: 14)),
                    subtitle: const Text('共有リンクを作成します', style: TextStyle(fontSize: 12, color: AppColors.textSub)),
                    value: 1,
                    groupValue: _inviteType,
                    activeColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) => setState(() => _inviteType = val!),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // --- 4. 作成ボタン ---
              ElevatedButton(
                onPressed: () {
                  // 作成処理
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('待ち合わせを作成しました！')),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  '作成する',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}