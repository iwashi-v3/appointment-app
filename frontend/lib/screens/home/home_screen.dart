import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/auth_guard.dart'; // AuthGuardをインポート
import 'user_list_screen.dart';
import 'user_search_screen.dart';

class HomeScreen extends StatelessWidget {
  final bool isGuest; // ゲストフラグを受け取る

  const HomeScreen({
    super.key,
    required this.isGuest,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      
      // ゲスト時は検索ボタン(FAB)を表示しない
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
      
      // ボディ全体を AuthGuard でラップする
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
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
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textBody),
                      ),
                      subtitle: const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text('2023.12.05 12:00'),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.refresh, color: AppColors.primary),
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
      ),
    );
  }

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
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textBody),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.textSub, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}