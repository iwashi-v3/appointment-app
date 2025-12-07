import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // iOSスタイルのピッカー用
import 'package:flutter/services.dart';
import '../../constants/app_colors.dart';
import '../../widgets/auth_guard.dart';

class CreateMeetingScreen extends StatefulWidget {
  final bool isGuest;
  // 履歴からの再作成用データ
  final Map<String, dynamic>? initialData;

  const CreateMeetingScreen({
    super.key,
    required this.isGuest,
    this.initialData,
  });

  @override
  State<CreateMeetingScreen> createState() => _CreateMeetingScreenState();
}

class _CreateMeetingScreenState extends State<CreateMeetingScreen> {
  // 入力コントローラー
  final TextEditingController _titleController = TextEditingController();
  // 場所名入力（_locationController）は削除しました
  
  DateTime _selectedDateTime = DateTime.now();
  
  bool _inviteFollowers = false;
  bool _inviteGuest = false;

  // ダミーのフォロワーデータ
  final List<Map<String, String>> _dummyFollowers = List.generate(
    15,
    (index) => {'id': 'user_$index', 'name': 'Friend User $index'},
  );
  final Set<String> _selectedFollowerIds = {};

  @override
  void initState() {
    super.initState();
    // 初期データの反映
    if (widget.initialData != null) {
      final data = widget.initialData!;
      
      // タイトル
      if (data['title'] != null) {
        _titleController.text = data['title'];
      }
      
      // 場所名の反映処理は削除（マップ上のピン位置などに反映するのが理想ですが、今回はUI削除のみ）
      
      // メンバー（フォロワー）の反映
      if (data['members'] != null && data['members'] is List) {
        final members = data['members'] as List<dynamic>;
        if (members.isNotEmpty) {
          _inviteFollowers = true;
          for (var memberName in members) {
            for (var user in _dummyFollowers) {
              if (user['name'] == memberName.toString()) {
                _selectedFollowerIds.add(user['id']!);
              }
            }
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  // 作成ボタン処理
  void _createMeeting() {
    // バリデーション
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('タイトルを入力してください')),
      );
      return;
    }
    
    // 場所名のバリデーションは削除しました

    if (!_inviteFollowers && !_inviteGuest) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('待ち合わせ相手を選択してください')),
      );
      return;
    }

    if (_inviteFollowers && _selectedFollowerIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('フォロワーを選択してください')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('待ち合わせを作成しました！')),
    );

    // 作成完了として戻る
    Navigator.pop(context, {
      'created': true,
      'title': _titleController.text,
      // location (場所名) は返さない（あるいはマップから取得した座標を返す）
      'inviteGuest': _inviteGuest,
      'inviteFollowers': _inviteFollowers,
      'meetingLink': _inviteGuest ? 'https://machiawase.app/meet/12345' : null,
    });
  }

  // 日付選択 (カレンダー)
  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textBody,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDateTime.hour,
          _selectedDateTime.minute,
        );
      });
    }
  }

  // 時刻選択 (ドラムロール)
  void _pickTime(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (BuildContext builder) {
        return Container(
          height: 300,
          color: Colors.white,
          child: Column(
            children: [
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
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: _selectedDateTime,
                  use24hFormat: true,
                  onDateTimeChanged: (DateTime newDateTime) {
                    setState(() {
                      _selectedDateTime = DateTime(
                        _selectedDateTime.year,
                        _selectedDateTime.month,
                        _selectedDateTime.day,
                        newDateTime.hour,
                        newDateTime.minute,
                      );
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

  String _formatDate(DateTime dt) {
    const weekdays = ['月', '火', '水', '木', '金', '土', '日'];
    final weekday = weekdays[dt.weekday - 1];
    return '${dt.year}年${dt.month}月${dt.day}日($weekday)';
  }

  String _formatTime(DateTime dt) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(dt.hour)}:${twoDigits(dt.minute)}';
  }

  // フォロワー選択シート
  void _showFollowerSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
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
                            setSheetState(() {
                              if (val == true) {
                                _selectedFollowerIds.add(id);
                              } else {
                                _selectedFollowerIds.remove(id);
                              }
                            });
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
              // --- マップエリア ---
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
              
              const SizedBox(height: 24),

              // --- タイトル入力 ---
              const Text(
                'タイトル',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSub),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: '例: ランチ、ハッカソン打ち合わせ',
                  hintStyle: const TextStyle(color: AppColors.warmGray),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.secondary.withOpacity(0.5)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.secondary.withOpacity(0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),

              // --- 場所名入力欄は削除しました ---

              const SizedBox(height: 24),

              // --- 開始日時設定 ---
              const Text(
                '開始日時',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSub),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  // 日付選択
                  Expanded(
                    flex: 3,
                    child: InkWell(
                      onTap: () => _pickDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.warmGray.withOpacity(0.5)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              _formatDate(_selectedDateTime),
                              style: const TextStyle(
                                fontSize: 16, 
                                fontWeight: FontWeight.bold, 
                                color: AppColors.textBody
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 時刻選択
                  Expanded(
                    flex: 2,
                    child: InkWell(
                      onTap: () => _pickTime(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.warmGray.withOpacity(0.5)),
                        ),
                        child: Center(
                          child: Text(
                            _formatTime(_selectedDateTime),
                            style: const TextStyle(
                              fontSize: 18, 
                              fontWeight: FontWeight.bold, 
                              color: AppColors.textBody
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // --- 相手選択 ---
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

              // --- 作成ボタン ---
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