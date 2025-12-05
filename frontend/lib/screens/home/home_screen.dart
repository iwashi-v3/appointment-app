import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import 'user_list_screen.dart'; // 作成した一覧画面をインポート

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        automaticallyImplyLeading: false, // 戻るボタンを消す
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("検索ボタンが押されました");
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.search, color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            
            // --- プロフィールセクション ---
            Center(
              child: Column(
                children: [
                  // アイコン画像
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
                  
                  // ユーザー名
                  const Text(
                    'User Name',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBody,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // --- フォロー・フォロワー数 (タップ機能付き) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // フォロワー
                      _buildStatItem(
                        context,
                        count: '10', 
                        label: 'Followers',
                        onTap: () {
                          // フォロワー一覧へ遷移
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const UserListScreen(
                                title: 'フォロワー',
                                isFollowingList: false, // フォロワー一覧モード
                              ),
                            ),
                          );
                        },
                      ),
                      
                      // 区切り線
                      Container(
                        height: 24,
                        width: 1,
                        color: AppColors.warmGray,
                        margin: const EdgeInsets.symmetric(horizontal: 30),
                      ),
                      
                      // フォロー中
                      _buildStatItem(
                        context,
                        count: '12', 
                        label: 'Following',
                        onTap: () {
                          // フォロー中一覧へ遷移
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const UserListScreen(
                                title: 'フォロー中',
                                isFollowingList: true, // フォロー中リストモード
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            // 履歴リスト
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.secondary, width: 0.5),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.location_on_outlined, color: AppColors.glacierBlue),
                    ),
                    title: Text(
                      '大学カフェテリア ${index + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBody,
                      ),
                    ),
                    subtitle: const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text('2023.12.05 12:00'),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.refresh, color: AppColors.primary),
                      tooltip: 'もう一度作成',
                      onPressed: () {},
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // タップ可能な数値アイテムを作成するヘルパーメソッド
  Widget _buildStatItem(BuildContext context, {required String count, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8), // タップ時の波紋を丸くする
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), // タップ領域を確保
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