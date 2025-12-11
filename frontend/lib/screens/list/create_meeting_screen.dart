import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Google Maps
import 'dart:async';
import '../../constants/app_colors.dart';
import '../../widgets/auth_guard.dart';

class CreateMeetingScreen extends StatefulWidget {
  final bool isGuest;
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
  // コントローラー
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  
  // Google Maps用
  final Completer<GoogleMapController> _mapController = Completer();
  // 初期位置 (例: 東京駅)
  LatLng _selectedLocation = const LatLng(35.681236, 139.767125); 
  Set<Marker> _markers = {};

  // 日時
  DateTime _selectedDateTime = DateTime.now();
  
  // 招待設定
  bool _inviteFollowers = false;
  bool _inviteGuest = false;

  final List<Map<String, String>> _dummyFollowers = List.generate(
    15,
    (index) => {'id': 'user_$index', 'name': 'Friend User $index'},
  );
  final Set<String> _selectedFollowerIds = {};

  @override
  void initState() {
    super.initState();
    // 履歴データの反映
    if (widget.initialData != null) {
      final data = widget.initialData!;
      if (data['title'] != null) {
        _titleController.text = data['title'];
      }
      // ※ここに位置情報の復元ロジックを追加可能
    }
    // 初期マーカーをセット
    _updateMarker();
  }

  // マーカー更新処理
  void _updateMarker() {
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('selected-location'),
          position: _selectedLocation,
          infoWindow: const InfoWindow(title: '待ち合わせ場所'),
        ),
      };
    });
  }

  // マップタップ時の処理
  void _onMapTapped(LatLng position) {
    setState(() {
      _selectedLocation = position;
      _updateMarker();
    });
  }

  // マップ生成時の処理
  void _onMapCreated(GoogleMapController controller) {
    _mapController.complete(controller);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // 作成ボタン
  void _createMeeting() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('タイトルを入力してください')));
      return;
    }
    if (!_inviteFollowers && !_inviteGuest) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('待ち合わせ相手を選択してください')));
      return;
    }
    if (_inviteFollowers && _selectedFollowerIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('フォロワーを選択してください')));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('待ち合わせを作成しました！')),
    );

    // 作成完了として戻る (座標情報も含める)
    Navigator.pop(context, {
      'created': true,
      'title': _titleController.text,
      'latitude': _selectedLocation.latitude,
      'longitude': _selectedLocation.longitude,
      'inviteGuest': _inviteGuest,
      'inviteFollowers': _inviteFollowers,
      'meetingLink': _inviteGuest ? 'https://machiawase.app/meet/12345' : null,
    });
  }

  // --- DatePicker / TimePicker / FollowerSelector (省略せず記述) ---
  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: AppColors.primary)),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDateTime = DateTime(picked.year, picked.month, picked.day, _selectedDateTime.hour, _selectedDateTime.minute));
    }
  }

  void _pickTime(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (context) => SizedBox(
        height: 300,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('完了', style: TextStyle(fontWeight: FontWeight.bold))),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: _selectedDateTime,
                use24hFormat: true,
                onDateTimeChanged: (val) => setState(() => _selectedDateTime = DateTime(_selectedDateTime.year, _selectedDateTime.month, _selectedDateTime.day, val.hour, val.minute)),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  const Text('フォロワーを選択', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _dummyFollowers.length,
                      itemBuilder: (context, index) {
                        final user = _dummyFollowers[index];
                        final id = user['id']!;
                        final isSelected = _selectedFollowerIds.contains(id);
                        return CheckboxListTile(
                          value: isSelected,
                          activeColor: AppColors.primary,
                          title: Text(user['name']!),
                          onChanged: (val) {
                            setSheetState(() {
                              val == true ? _selectedFollowerIds.add(id) : _selectedFollowerIds.remove(id);
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

  String _formatDate(DateTime dt) => '${dt.year}年${dt.month}月${dt.day}日';
  String _formatTime(DateTime dt) => '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('待ち合わせの新規作成'),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textBody),
        titleTextStyle: const TextStyle(color: AppColors.textBody, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      
      body: AuthGuard(
        isGuest: widget.isGuest,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- 1. 場所選択エリア (Google Map) ---
              const Text('場所を選択', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSub)),
              const SizedBox(height: 8),
              
              // マップコンテナ
              SizedBox(
                height: 300,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      GoogleMap(
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(
                          target: _selectedLocation,
                          zoom: 15.0,
                        ),
                        // タップでピンを立てる
                        onTap: _onMapTapped,
                        markers: _markers,
                        myLocationEnabled: true, // 現在地ボタン
                        myLocationButtonEnabled: true,
                      ),
                      
                      // 検索窓 (マップの上に重ねる)
                      Positioned(
                        top: 10,
                        left: 10,
                        right: 10,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2)),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            textInputAction: TextInputAction.search,
                            decoration: const InputDecoration(
                              hintText: '場所を検索',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              suffixIcon: Icon(Icons.search, color: AppColors.primary),
                            ),
                            // 実際はここで検索処理を呼ぶ
                            onSubmitted: (_) {},
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text('※地図をタップしてピンを立ててください', style: TextStyle(fontSize: 12, color: AppColors.textSub), textAlign: TextAlign.center),
              ),
              
              const SizedBox(height: 24),

              // --- 2. タイトル入力 ---
              const Text('タイトル', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSub)),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: '例: ランチ、ハッカソン打ち合わせ',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),

              const SizedBox(height: 24),

              // --- 3. 開始日時 ---
              const Text('開始日時', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSub)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: InkWell(
                      onTap: () => _pickDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(_formatDate(_selectedDateTime), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: InkWell(
                      onTap: () => _pickTime(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                        child: Center(child: Text(_formatTime(_selectedDateTime), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // --- 4. 相手選択 ---
              const Text('待ち合わせ相手', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSub)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    CheckboxListTile(
                      title: const Text('フォロワーと待ち合わせ', style: TextStyle(fontWeight: FontWeight.bold)),
                      value: _inviteFollowers,
                      activeColor: AppColors.primary,
                      onChanged: (val) => setState(() => _inviteFollowers = val!),
                    ),
                    if (_inviteFollowers)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: OutlinedButton(onPressed: _showFollowerSelector, child: const Text('相手を選択する')),
                      ),
                    const Divider(height: 1),
                    CheckboxListTile(
                      title: const Text('ゲストと待ち合わせ', style: TextStyle(fontWeight: FontWeight.bold)),
                      value: _inviteGuest,
                      activeColor: AppColors.primary,
                      onChanged: (val) => setState(() => _inviteGuest = val!),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // --- 5. 作成ボタン ---
              ElevatedButton(
                onPressed: _createMeeting,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('作成する', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}