import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/auth_guard.dart';
import 'user_list_screen.dart';
import 'user_search_screen.dart';
import 'follow_requests_screen.dart';
import '../list/create_meeting_screen.dart';

class HomeScreen extends StatelessWidget {
  final bool isGuest;

  const HomeScreen({
    super.key,
    required this.isGuest,
  });

  // ダミーの過去履歴データ
  // リスト表示には場所を出さないが、再作成時に引き継ぐためにデータには持たせておく
  final List<Map<String, dynamic>> _historyMeetings = const [
    {
      'title': 'ハッカソン打ち合わせ',
      'location': '大学カフェテリア', // 再作成用
      'datetime': '2023/12/05(火) 12:00',
      'members': ['佐藤さん', '鈴木さん'],
    },
    {
      'title': '駅前ランチ',
      'location': '駅前パスタ屋',
      'datetime': '2023/12/01(金) 18:30',
      'members': ['田中さん'],
    },
    {
      'title': 'サークル部室',
      'location': '部室棟 301',
      'datetime': '2023/11/20(月) 16:00',
      'members': ['山田さん', '高橋さん'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Home'),
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textBody),
        titleTextStyle: const TextStyle(
          color: AppColors.textBody,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          // フォローリクエスト画面への遷移ボタン
          // 要望通り「人のマーク」に変更
          if (!isGuest)
            IconButton(
              icon: Stack(
                children: [
                  const Icon(Icons.person_outline, size: 28), // 人のマーク
                  // 通知バッジ
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.fromBorderSide(
                            BorderSide(color: AppColors.background, width: 1.5)),
                      ),
                    ),
                  ),
                ],
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FollowRequestsScreen()),
                );
              },
            ),
          const SizedBox(width: 16),
        ],
      ),
      
      // ユーザー検索ボタン (FAB)
      floatingActionButton: isGuest ? null : FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const UserSearchScreen(),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.search, color: Colors.white),
      ),
      
      body: AuthGuard(
        isGuest: isGuest,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),
              
              // --- プロフィールセクション ---
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.person, size: 48, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'User Name',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBody,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // フォロー・フォロワー数
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStatItem(
                          context,
                          count: '10', 
                          label: 'Followers',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const UserListScreen(
                                  title: 'フォロワー',
                                  isFollowingList: false,
                                ),
                              ),
                            );
                          },
                        ),
                        Container(
                          height: 24,
                          width: 1,
                          color: AppColors.warmGray,
                          margin: const EdgeInsets.symmetric(horizontal: 30),
                        ),
                        _buildStatItem(
                          context,
                          count: '12', 
                          label: 'Following',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const UserListScreen(
                                  title: 'フォロー中',
                                  isFollowingList: true,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // --- 履歴リストセクション ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: const [
                    Icon(Icons.history, size: 22, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      '過去の待ち合わせ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBody,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: _historyMeetings.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return _buildHistoryCard(context, _historyMeetings[index]);
                },
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  // 履歴カードのビルド (ListScreenのデザインを踏襲、場所は非表示)
  Widget _buildHistoryCard(BuildContext context, Map<String, dynamic> meeting) {
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
            // 再作成のために作成画面へ遷移
            // ここで meeting データ（場所含む）をそのまま渡す
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateMeetingScreen(
                  isGuest: isGuest,
                  initialData: meeting, // 履歴データを渡す
                ),
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
                      meeting['datetime'],
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBody,
                      ),
                    ),
                  ],
                ),
                
                // ※ 場所情報はここでは表示しない ※
                
                const SizedBox(height: 20),
                const Divider(height: 1, color: AppColors.overcast),
                const SizedBox(height: 16),
                
                // メンバーと再作成リンク
                Row(
                  children: [
                    // メンバーアイコン
                    for (var member in (meeting['members'] as List).take(3))
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
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
                    
                    const Spacer(),
                    
                    // 再作成への誘導
                    Row(
                      children: const [
                        Text(
                          '再作成', 
                          style: TextStyle(
                            fontSize: 12, 
                            color: AppColors.primary, 
                            fontWeight: FontWeight.bold
                          )
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.primary),
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

  // 数値アイテム（フォロワー数など）
  Widget _buildStatItem(BuildContext context, {required String count, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          children: [
            Text(
              count,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textBody,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSub,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}