import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // クリップボード用
import '../../constants/app_colors.dart';
import 'create_meeting_screen.dart';

class MapScreen extends StatefulWidget {
  final bool isGuest; // ゲストフラグ

  const MapScreen({
    super.key,
    required this.isGuest,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {

  // 作成画面へ遷移し、戻り値を受け取る処理
  Future<void> _navigateToCreateMeeting() async {
    // 作成画面へ遷移
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateMeetingScreen(isGuest: widget.isGuest),
      ),
    );

    // 戻り値をチェック
    // 作成画面から戻ってきたときに「ゲスト招待あり」の情報があれば共有シートを表示
    if (result != null && result is Map<String, dynamic>) {
      if (result['created'] == true && result['inviteGuest'] == true) {
        final link = result['meetingLink'] as String? ?? '';
        
        // 非同期処理の後なので、ウィジェットがまだ存在するか確認してから表示
        if (mounted) {
           _showShareSheet(link);
        }
      }
    }
  }

  // リンク共有用のボトムシート
  void _showShareSheet(String meetingLink) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // 上部の角丸用
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                const Text(
                  '待ち合わせを共有',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textBody),
                ),
                const SizedBox(height: 20),

                // リンク表示エリア
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.secondary),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.link, color: AppColors.textSub),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          meetingLink,
                          style: const TextStyle(color: AppColors.textBody),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 10),
                      // コピーボタン
                      InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: meetingLink));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('リンクをコピーしました')),
                          );
                          Navigator.pop(context); // シートを閉じる
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'コピー',
                            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // SNSアイコン
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildShareIcon(Icons.mail_outline, 'メール', Colors.blueGrey),
                    _buildShareIcon(Icons.chat_bubble_outline, 'LINE', const Color(0xFF06C755)),
                    _buildShareIcon(Icons.alternate_email, 'X', Colors.black),
                    _buildShareIcon(Icons.more_horiz, 'その他', Colors.grey),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShareIcon(IconData icon, String label, Color color) {
    return InkWell(
      onTap: () {
        Navigator.pop(context); // シートを閉じる
      },
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSub)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Map'),
        backgroundColor: Colors.white.withOpacity(0.7),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: AppColors.textBody,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      
      // 作成ボタン (_navigateToCreateMeetingを呼ぶ)
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateMeeting,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_location_alt, color: Colors.white),
      ),
      
      body: Stack(
        children: [
          // 地図エリア（ダミー）
          Container(
            width: double.infinity,
            height: double.infinity,
            color: AppColors.ice.withOpacity(0.3),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // グリッド
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
                // 現在地ピン
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