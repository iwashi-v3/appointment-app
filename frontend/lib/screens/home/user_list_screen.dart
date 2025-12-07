import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class UserListScreen extends StatefulWidget {
  final String title;
  final bool isFollowingList; // フォロー中リストかフォロワーリストかのフラグ

  const UserListScreen({
    super.key,
    required this.title,
    required this.isFollowingList,
  });

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  
  // ダミーデータ生成（実際はAPI等から取得）
  late List<String> _allUsers;

  @override
  void initState() {
    super.initState();
    // 20人分のダミーユーザーを作成
    _allUsers = List.generate(20, (index) => 'User Name $index');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 検索テキストに基づいてユーザーリストをフィルタリング
    final filteredUsers = _allUsers.where((name) {
      return name.toLowerCase().contains(_searchText.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textBody),
        titleTextStyle: const TextStyle(
          color: AppColors.textBody,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Column(
        children: [
          // --- 検索バー ---
          Padding(
            padding: const EdgeInsets.all(16),
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
                // 入力がある場合のみクリアボタンを表示
                suffixIcon: _searchText.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.warmGray),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchText = '');
                        },
                      )
                    : null,
              ),
              onChanged: (val) => setState(() => _searchText = val),
            ),
          ),

          // --- ユーザーリスト ---
          Expanded(
            child: filteredUsers.isEmpty
                ? const Center(
                    child: Text(
                      'ユーザーが見つかりませんでした',
                      style: TextStyle(color: AppColors.textSub),
                    ),
                  )
                : ListView.separated(
                    itemCount: filteredUsers.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, indent: 72),
                    itemBuilder: (context, index) {
                      final userName = filteredUsers[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: const CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.secondary,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(
                          userName,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textBody),
                        ),
                        subtitle: const Text(
                          'Hello!',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: AppColors.textSub),
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            // フォロー/解除の処理をここに記述
                          },
                          style: ElevatedButton.styleFrom(
                            // フォロー中リストならグレー（解除）、フォロワーリストならメインカラー（フォローバック）のような出し分け例
                            backgroundColor: widget.isFollowingList ? Colors.grey[300] : AppColors.primary,
                            foregroundColor: widget.isFollowingList ? Colors.black54 : Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            minimumSize: const Size(80, 36),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: Text(widget.isFollowingList ? 'フォロー中' : 'フォロー'),
                        ),
                        onTap: () {
                          // ユーザー詳細画面への遷移などを記述
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}