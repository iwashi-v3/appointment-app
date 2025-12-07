import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/auth_guard.dart';
import '../list/create_meeting_screen.dart';
import 'meeting_detail_map_screen.dart';

class ListScreen extends StatefulWidget {
  final bool isGuest;

  const ListScreen({
    super.key,
    required this.isGuest,
  });

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  // ダミーデータ (locationはデータとして保持しますが、リストには表示しません)
  final List<Map<String, dynamic>> _meetings = [
    {
      'id': '1',
      'title': 'ハッカソン打ち合わせ',
      'location': '大学カフェテリア',
      'datetime': DateTime.now().add(const Duration(hours: 2)),
      'members': ['佐藤さん', '鈴木さん'],
    },
    {
      'id': '2',
      'title': 'ランチ',
      'location': '駅前パスタ屋',
      'datetime': DateTime.now().add(const Duration(days: 1, hours: 1)),
      'members': ['田中さん'],
    },
    {
      'id': '3',
      'title': 'サークル集合',
      'location': '正門前',
      'datetime': DateTime.now().add(const Duration(days: 3)),
      'members': ['山田さん', '高橋さん', '伊藤さん'],
    },
  ];

  // 日時フォーマット (例: 12/7(日) 16:17)
  String _formatDateTime(DateTime dt) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final date = '${dt.month}/${dt.day}';
    final time = '${twoDigits(dt.hour)}:${twoDigits(dt.minute)}';
    const weekdays = ['月', '火', '水', '木', '金', '土', '日'];
    final weekday = weekdays[dt.weekday - 1];
    return '$date($weekday) $time';
  }

  // 作成画面への遷移
  Future<void> _navigateToCreateMeeting() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateMeetingScreen(isGuest: widget.isGuest),
      ),
    );
    if (result != null && result is Map<String, dynamic> && result['created'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('新しい待ち合わせが追加されました（ダミー）')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('List'),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: AppColors.textBody,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // 新規作成ボタン (FAB)
      floatingActionButton: widget.isGuest ? null : FloatingActionButton(
        onPressed: _navigateToCreateMeeting,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_location_alt, color: Colors.white),
      ),

      body: AuthGuard(
        isGuest: widget.isGuest,
        child: Column(
          children: [
            // ヘッダー的な表示
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Row(
                children: const [
                  Icon(Icons.event_available, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text(
                    '予定一覧',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBody,
                    ),
                  ),
                ],
              ),
            ),

            // リスト本体
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: _meetings.length,
                separatorBuilder: (context, index) => const SizedBox(height: 20),
                itemBuilder: (context, index) {
                  final meeting = _meetings[index];
                  return _buildMeetingCard(meeting);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // カードデザインのビルド (場所表示を削除し、ホーム画面とデザインを統一)
  Widget _buildMeetingCard(Map<String, dynamic> meeting) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            // 詳細マップ画面へ遷移
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MeetingDetailMapScreen(meetingData: meeting),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // タイトル
                Text(
                  meeting['title'],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBody,
                  ),
                ),
                const SizedBox(height: 16),

                // 日時
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 20, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      _formatDateTime(meeting['datetime']),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBody,
                      ),
                    ),
                  ],
                ),
                
                // ※ 場所情報の表示行は削除しました ※

                const SizedBox(height: 20),
                const Divider(height: 1, color: AppColors.overcast),
                const SizedBox(height: 16),

                // 下段：メンバー表示
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '待ち合わせ相手',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSub,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        for (var member in (meeting['members'] as List).take(3))
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Column(
                              children: [
                                const CircleAvatar(
                                  radius: 16,
                                  backgroundColor: AppColors.secondary,
                                  child: Icon(Icons.person, size: 20, color: Colors.white),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  member,
                                  style: const TextStyle(fontSize: 10, color: AppColors.textSub),
                                ),
                              ],
                            ),
                          ),
                        if ((meeting['members'] as List).length > 3)
                          const Text('...', style: TextStyle(color: AppColors.textSub)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}