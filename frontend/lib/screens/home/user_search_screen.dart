import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key});

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _searchResults = []; // 検索結果（ダミーデータ）
  bool _hasSearched = false; // 検索を実行したかどうか

  // 検索処理（ダミー）
  void _performSearch(String query) {
    setState(() {
      _hasSearched = true;
      if (query.isNotEmpty) {
        // 入力があればダミー結果を生成
        _searchResults = List.generate(
          5,
          (index) => '$query-user-$index', // 入力されたIDを含むダミーユーザー
        );
      } else {
        _searchResults = [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ユーザー検索'),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textBody),
        titleTextStyle: const TextStyle(
          color: AppColors.textBody,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Column(
        children: [
          // --- 検索窓エリア ---
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.background,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ユーザーIDを入力',
                hintStyle: const TextStyle(color: AppColors.warmGray),
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: AppColors.secondary, width: 0.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
                // 入力があったらクリアボタンを表示
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.warmGray),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                    : null,
              ),
              onSubmitted: _performSearch, // キーボードのエンターで検索
              onChanged: (text) {
                // 入力変更時にクリアボタンの出し分けのために再描画
                setState(() {});
              },
            ),
          ),

          // --- 検索結果リストエリア ---
          Expanded(
            child: _searchResults.isEmpty
                ? Center(
                    child: Text(
                      _hasSearched ? 'ユーザーが見つかりませんでした' : 'IDを入力してユーザーを検索',
                      style: const TextStyle(color: AppColors.textSub),
                    ),
                  )
                : ListView.separated(
                    itemCount: _searchResults.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, indent: 72),
                    itemBuilder: (context, index) {
                      final userId = _searchResults[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.secondary,
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(
                          userId, // ユーザーIDを表示
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textBody),
                        ),
                        subtitle: const Text('ID検索結果', style: TextStyle(fontSize: 12, color: AppColors.textSub)),
                        trailing: ElevatedButton(
                          onPressed: () {
                            // フォロー処理
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            minimumSize: const Size(80, 36),
                          ),
                          child: const Text('フォロー'),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}