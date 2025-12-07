import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class MeetingDetailMapScreen extends StatelessWidget {
  final Map<String, dynamic> meetingData;

  const MeetingDetailMapScreen({
    super.key,
    required this.meetingData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(meetingData['title']),
        backgroundColor: Colors.white.withOpacity(0.8),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textBody),
        titleTextStyle: const TextStyle(
          color: AppColors.textBody,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Stack(
        children: [
          // --- マップエリア (全画面) ---
          Container(
            width: double.infinity,
            height: double.infinity,
            color: AppColors.ice.withOpacity(0.3),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // グリッド線（ダミーマップ）
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
                // 目的地ピン
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
                      child: Text(
                        meetingData['location'],
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // --- 下部操作パネル ---
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 待ち合わせ開始ボタン
                ElevatedButton.icon(
                  onPressed: () {
                    // 開始処理（位置情報共有の開始など）
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('待ち合わせを開始しました。位置情報を共有します。')),
                    );
                  },
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('待ち合わせを開始'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 4,
                  ),
                ),
                const SizedBox(height: 12),
                
                // 待ち合わせ終了ボタン
                OutlinedButton.icon(
                  onPressed: () {
                    // 終了処理
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('待ち合わせを終了しました')),
                    );
                  },
                  icon: const Icon(Icons.stop_rounded),
                  label: const Text('待ち合わせを終了'),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}