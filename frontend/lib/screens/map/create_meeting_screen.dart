import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // iOSスタイルのピッカー用
import '../../constants/app_colors.dart';
import '../../widgets/auth_guard.dart'; // AuthGuardをインポート

class CreateMeetingScreen extends StatefulWidget {
  final bool isGuest;

  const CreateMeetingScreen({
    super.key,
    required this.isGuest,
  });

  @override
  State<CreateMeetingScreen> createState() => _CreateMeetingScreenState();
}

class _CreateMeetingScreenState extends State<CreateMeetingScreen> {
  // 入力状態の管理
  bool _useCurrentLocation = false;
  
  // 日付と時刻を両方扱うために DateTime に変更
  DateTime _selectedDateTime = DateTime.now();
  
  // 招待設定
  bool _inviteFollowers = false;
  bool _inviteGuest = false;

  // フォロワー選択用データ
  final List<Map<String, String>> _dummyFollowers = List.generate(
    15,
    (index) => {'id': 'user_$index', 'name': 'Friend User $index'},
  );
  // 選択されたフォロワーのIDセット
  final Set<String> _selectedFollowerIds = {};

  // 作成ボタン処理
  void _createMeeting() {
    // バリデーション
    if (!_inviteFollowers && !_inviteGuest) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('待ち合わせ相手を選択してください')),
      );
      return;
    }

    // フォロワー招待がONなのに誰も選択していない場合
    if (_inviteFollowers && _selectedFollowerIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('フォロワーを選択してください')),
      );
      return;
    }

    // 作成完了メッセージ
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('待ち合わせを作成しました！')),
    );

    // マップ画面へ結果を返して閉じる（共有機能はマップ画面側で制御）
    Navigator.pop(context, {
      'created': true,
      'inviteGuest': _inviteGuest,
      'inviteFollowers': _inviteFollowers,
      'meetingLink': _inviteGuest ? 'https://machiawase.app/meet/12345' : null,
    });
  }

  // ドラムロール式のピッカーを表示するメソッド
  void _showCupertinoDatePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (BuildContext builder) {
        return Container(
          height: 300, // ピッカーの高さ
          color: Colors.white,
          child: Column(
            children: [
              // 完了ボタンエリア
              Container(
                color: Colors.grey[100],
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        '完了',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // ピッカー本体
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.dateAndTime, // 日付と時刻
                  initialDateTime: _selectedDateTime,
                  use24hFormat: true,
                  // 過去の日時を選べないようにする（1分前まで許容）
                  minimumDate: DateTime.now().subtract(const Duration(minutes: 1)),
                  onDateTimeChanged: (DateTime newDateTime) {
                    setState(() {
                      _selectedDateTime = newDateTime;
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 日時を文字列に整形するヘルパー
  String _formatDateTime(DateTime dt) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final date = '${dt.year}/${dt.month}/${dt.day}';
    final time = '${twoDigits(dt.hour)}:${twoDigits(dt.minute)}';
    const weekdays = ['月', '火', '水', '木', '金', '土', '日'];
    final weekday = weekdays[dt.weekday - 1];
    
    return '$date ($weekday) $time';
  }

  // フォロワー選択シートを表示
  void _showFollowerSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 画面の高さに合わせて表示
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder( // シート内で状態更新するために必要
          builder: (context, setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7, // 画面の7割の高さ
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // ハンドルバー
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'フォロワーを選択',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('完了', style: TextStyle(color: AppColors.primary)),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // リスト
                  Expanded(
                    child: ListView.builder(
                      itemCount: _dummyFollowers.length,
                      itemBuilder: (context, index) {
                        final user = _dummyFollowers[index];
                        final id = user['id']!;
                        final name = user['name']!;
                        final isSelected = _selectedFollowerIds.contains(id);

                        return CheckboxListTile(
                          value: isSelected,
                          activeColor: AppColors.primary,
                          secondary: const CircleAvatar(
                            backgroundColor: AppColors.secondary,
                            child: Icon(Icons.person, color: Colors.white, size: 20),
                          ),
                          title: Text(name),
                          onChanged: (val) {
                            setSheetState(() { // シート内の再描画
                              if (val == true) {
                                _selectedFollowerIds.add(id);
                              } else {
                                _selectedFollowerIds.remove(id);
                              }
                            });
                            // 親画面（作成画面）の表示も更新する
                            this.setState(() {}); 
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

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
      
      body: AuthGuard(
        isGuest: widget.isGuest,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- 1. 場所選択 ---
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
              
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
                title: const Text('現在地で待ち合わせ', style: TextStyle(fontSize: 14, color: AppColors.textBody)),
                value: _useCurrentLocation,
                onChanged: (val) => setState(() => _useCurrentLocation = val ?? false),
                controlAffinity: ListTileControlAffinity.leading,
              ),

              const SizedBox(height: 24),

              // --- 2. 開始日時設定 (ドラムロール式に変更) ---
              const Text(
                '開始日時',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSub),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _showCupertinoDatePicker(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.warmGray.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, color: AppColors.primary),
                          const SizedBox(width: 16),
                          Text(
                            _formatDateTime(_selectedDateTime),
                            style: const TextStyle(
                              fontSize: 18, 
                              fontWeight: FontWeight.bold, 
                              color: AppColors.textBody
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '変更',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // --- 3. 相手を選択 (複数選択可能) ---
              const Text(
                '待ち合わせ相手 (複数選択可)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSub),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    // フォロワーと待ち合わせ
                    CheckboxListTile(
                      title: const Text('フォロワーと待ち合わせ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      subtitle: const Text('アプリ内で通知を送ります', style: TextStyle(fontSize: 12, color: AppColors.textSub)),
                      secondary: const Icon(Icons.people_outline, color: AppColors.primary),
                      value: _inviteFollowers,
                      activeColor: AppColors.primary,
                      onChanged: (val) => setState(() => _inviteFollowers = val ?? false),
                    ),
                    
                    // フォロワー選択がONの場合のみ表示される詳細設定エリア
                    if (_inviteFollowers)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(left: 72, right: 16, bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedFollowerIds.isEmpty
                                  ? 'まだ選択されていません'
                                  : '${_selectedFollowerIds.length}人を選択中',
                              style: TextStyle(
                                fontSize: 13,
                                color: _selectedFollowerIds.isEmpty ? Colors.red : AppColors.textBody,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            OutlinedButton.icon(
                              onPressed: _showFollowerSelector,
                              icon: const Icon(Icons.person_add, size: 18),
                              label: const Text('相手を選択する'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(color: AppColors.primary),
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                          ],
                        ),
                      ),

                    const Divider(height: 1),
                    
                    // ゲストと待ち合わせ
                    CheckboxListTile(
                      title: const Text('ゲストと待ち合わせ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      subtitle: const Text('共有リンクを作成します', style: TextStyle(fontSize: 12, color: AppColors.textSub)),
                      secondary: const Icon(Icons.link, color: AppColors.primary),
                      value: _inviteGuest,
                      activeColor: AppColors.primary,
                      onChanged: (val) => setState(() => _inviteGuest = val ?? false),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // --- 4. 作成ボタン ---
              ElevatedButton(
                onPressed: _createMeeting,
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