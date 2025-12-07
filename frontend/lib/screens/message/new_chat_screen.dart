import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import 'chat_screen.dart';

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({super.key});

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  // 現在のタブ (true: フォロー中, false: フォロワー)
  bool _showFollowing = true;
  
  // 検索テキスト
  String _searchText = '';
  final TextEditingController _searchController = TextEditingController();

  // 選択されたユーザーのIDセット
  final Set<String> _selectedUserIds = {};
  // 選択されたユーザーの名前リスト（遷移時に使用）
  final List<String> _selectedUserNames = [];

  // ダミーデータ: フォロー中
  final List<Map<String, String>> _followingUsers = List.generate(
    15,
    (index) => {
      'id': 'following_$index',
      'name': 'Friend User $index',
      'subtitle': 'こんにちは！',
    },
  );

  // ダミーデータ: フォロワー
  final List<Map<String, String>> _followerUsers = List.generate(
    15,
    (index) => {
      'id': 'follower_$index',
      'name': 'Fan User $index',
      'subtitle': 'フォローありがとうございます',
    },
  );

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ユーザー選択のトグル処理
  void _toggleUserSelection(String id, String name) {
    setState(() {
      if (_selectedUserIds.contains(id)) {
        _selectedUserIds.remove(id);
        _selectedUserNames.remove(name);
      } else {
        _selectedUserIds.add(id);
        _selectedUserNames.add(name);
      }
    });
  }

  // チャット画面へ遷移
  void _createChat() {
    if (_selectedUserIds.isEmpty) return;

    final isGroup = _selectedUserIds.length > 1;
    
    // グループの場合は名前を結合、個人の場合はその人の名前
    String chatName;
    if (isGroup) {
      chatName = _selectedUserNames.take(3).join(', '); // 長すぎないように3人まで結合
      if (_selectedUserNames.length > 3) {
        chatName += '...';
      }
    } else {
      chatName = _selectedUserNames.first;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          name: chatName,
          isGroup: isGroup,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 現在のリストと検索フィルタリング
    final currentList = _showFollowing ? _followingUsers : _followerUsers;
    final filteredList = currentList.where((user) {
      final name = user['name']!.toLowerCase();
      final query = _searchText.toLowerCase();
      return name.contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('新規トーク作成'),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textBody),
        titleTextStyle: const TextStyle(
          color: AppColors.textBody,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Column(
        children: [
          // --- 1. 検索バー ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ユーザーを検索',
                hintStyle: const TextStyle(color: AppColors.warmGray),
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: _searchText.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.warmGray),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchText = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
            ),
          ),

          // --- 2. トグルスイッチ (フォロー中 / フォロワー) ---
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.secondary.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                _buildToggleButton('フォロー中', true),
                _buildToggleButton('フォロワー', false),
              ],
            ),
          ),

          // --- 3. ユーザーリスト ---
          Expanded(
            child: ListView.separated(
              itemCount: filteredList.length,
              separatorBuilder: (context, index) => const Divider(height: 1, indent: 72),
              itemBuilder: (context, index) {
                final user = filteredList[index];
                final id = user['id']!;
                final name = user['name']!;
                final isSelected = _selectedUserIds.contains(id);

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  // 選択時の背景色変更
                  tileColor: isSelected ? AppColors.ice.withOpacity(0.2) : null,
                  leading: Stack(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.secondary,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      // 選択中ならチェックマークを表示
                      if (isSelected)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 2)),
                            ),
                            child: const Icon(Icons.check, size: 12, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                  title: Text(
                    name,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppColors.primary : AppColors.textBody,
                    ),
                  ),
                  subtitle: Text(
                    user['subtitle']!,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSub),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: AppColors.primary)
                      : const Icon(Icons.circle_outlined, color: AppColors.warmGray),
                  onTap: () => _toggleUserSelection(id, name),
                );
              },
            ),
          ),

          // --- 4. 作成ボタン (下部固定) ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: ElevatedButton(
                onPressed: _selectedUserIds.isEmpty ? null : _createChat,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.warmGray,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _getButtonLabel(),
                  style: const TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ボタンのラベルを動的に生成
  String _getButtonLabel() {
    if (_selectedUserIds.isEmpty) {
      return 'ユーザーを選択してください';
    } else if (_selectedUserIds.length == 1) {
      return 'トークを開始';
    } else {
      return 'グループを作成 (${_selectedUserIds.length}人)';
    }
  }

  // トグルボタンのウィジェット
  Widget _buildToggleButton(String label, bool isFollowingTab) {
    final isSelected = _showFollowing == isFollowingTab;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _showFollowing = isFollowingTab;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSub,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}