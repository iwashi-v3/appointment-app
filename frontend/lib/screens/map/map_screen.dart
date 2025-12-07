import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import 'create_meeting_screen.dart'; // 作成画面への遷移用

class MapScreen extends StatelessWidget {
  // isGuestを受け取るように変更
  final bool isGuest;
  const MapScreen({super.key, required this.isGuest});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBarを地図の上に重ねる設定
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Map'),
        backgroundColor: Colors.white.withOpacity(0.7), // 半透明にして地図を見やすく
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: AppColors.textBody,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      
      // --- 待ち合わせ作成ボタン (Floating Action Buttonに変更) ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 待ち合わせ作成画面へ遷移
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateMeetingScreen(isGuest: isGuest),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_location_alt, color: Colors.white),
      ),
      
      body: Stack(
        children: [
          // --- 地図表示エリア（仮実装） ---
          Container(
            width: double.infinity,
            height: double.infinity,
            color: AppColors.ice.withOpacity(0.3), // 地図っぽい背景色
            child: Stack(
              alignment: Alignment.center,
              children: [
                // グリッド線で地図っぽさを演出
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                  ),
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white.withOpacity(0.5)),
                      ),
                    );
                  },
                ),
                // 仮の現在地ピン
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on, size: 48, color: Colors.redAccent),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 4),
                        ],
                      ),
                      child: const Text('現在地', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}