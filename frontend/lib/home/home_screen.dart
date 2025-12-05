import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

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
      // 要望のあった検索ボタン（虫眼鏡アイコン）
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("検索ボタンが押されました");
          // 将来的に検索画面へ遷移する処理を記述
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.search, color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            
            // --- 1. プロフィールセクション ---
            Center(
              child: Column(
                children: [
                  // プロフィールアイコン（二重円デザイン）
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
                        color: AppColors.secondary, // Iceカラー
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
                  
                  // フォロー・フォロワー数
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatItem('10', 'Followers'),
                      Container(
                        height: 24,
                        width: 1,
                        color: AppColors.warmGray,
                        margin: const EdgeInsets.symmetric(horizontal: 30),
                      ),
                      _buildStatItem('12', 'Following'),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // --- 2. 履歴リストセクション ---
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
            
            // 履歴カードのリスト
            ListView.builder(
              shrinkWrap: true, // ScrollView内でListViewを使うための設定
              physics: const NeverScrollableScrollPhysics(), // 親のスクロールのみ有効にする
              itemCount: 3, // 仮のデータ数
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
                      onPressed: () {
                        // 再作成のロジック
                      },
                    ),
                  ),
                );
              },
            ),
            // FABとコンテンツが被らないように下の余白を追加
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // 数値表示用のヘルパーメソッド
  Widget _buildStatItem(String count, String label) {
    return Column(
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
    );
  }
}