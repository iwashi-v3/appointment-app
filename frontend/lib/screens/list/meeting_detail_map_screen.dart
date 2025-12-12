import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Google Maps
import 'dart:async';
import '../../constants/app_colors.dart';

class MeetingDetailMapScreen extends StatefulWidget {
  final Map<String, dynamic> meetingData;

  const MeetingDetailMapScreen({
    super.key,
    required this.meetingData,
  });

  @override
  State<MeetingDetailMapScreen> createState() => _MeetingDetailMapScreenState();
}

class _MeetingDetailMapScreenState extends State<MeetingDetailMapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  
  // マーカーリスト
  Set<Marker> _markers = {};
  
  // 初期表示位置（例として東京駅周辺）
  // 実際は meetingData['location'] に紐づく座標を使うべきですが、今回はダミー座標を使用
  final LatLng _initialPosition = const LatLng(35.681236, 139.767125);

  @override
  void initState() {
    super.initState();
    _loadMarkers();
  }

  // マーカーを作成（集合場所 + メンバーの現在地）
  void _loadMarkers() {
    // 1. 集合場所のマーカー
    final destinationMarker = Marker(
      markerId: const MarkerId('destination'),
      position: _initialPosition,
      infoWindow: InfoWindow(title: '集合場所: ${widget.meetingData['title']}'),
      icon: BitmapDescriptor.defaultMarker, // 赤いピン
    );

    // 2. メンバーの現在地マーカー（ダミー）
    // 実際はFirestoreなどでリアルタイムな位置情報を取得して更新します
    final List<Map<String, dynamic>> dummyMembers = [
      {'id': '1', 'name': '自分', 'lat': 35.681236, 'lng': 139.767125, 'hue': BitmapDescriptor.hueBlue},
      {'id': '2', 'name': '佐藤さん', 'lat': 35.682000, 'lng': 139.768000, 'hue': BitmapDescriptor.hueViolet},
      {'id': '3', 'name': '鈴木さん', 'lat': 35.680000, 'lng': 139.766000, 'hue': BitmapDescriptor.hueGreen},
    ];

    final memberMarkers = dummyMembers.map((m) {
      return Marker(
        markerId: MarkerId(m['id']),
        position: LatLng(m['lat'], m['lng']),
        infoWindow: InfoWindow(title: m['name'], snippet: '現在地'),
        // 色を変えてメンバーを区別
        icon: BitmapDescriptor.defaultMarkerWithHue(m['hue']),
      );
    }).toSet();

    setState(() {
      _markers = {destinationMarker, ...memberMarkers};
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // AppBarを地図の上に重ねる
      appBar: AppBar(
        title: Text(widget.meetingData['title']),
        backgroundColor: Colors.white.withOpacity(0.8), // 半透明
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
          // --- Google Map ---
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 16,
            ),
            markers: _markers,
            myLocationEnabled: true, // 自分の位置を表示（権限が必要）
            myLocationButtonEnabled: false, // デフォルトの現在地ボタンは隠す
            zoomControlsEnabled: false, // ズームボタンを隠す
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),

          // --- 下部操作パネル ---
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // メンバー状況表示バー
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.people, size: 18, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text(
                        '3人が移動中...', // ダミーテキスト
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // 開始ボタン
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('位置情報の共有を開始しました')),
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
                
                // 終了ボタン
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('終了しました')),
                    );
                  },
                  icon: const Icon(Icons.stop_rounded),
                  label: const Text('終了する'),
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