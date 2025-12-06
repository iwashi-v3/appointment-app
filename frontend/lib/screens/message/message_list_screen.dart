import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import 'chat_screen.dart';     // チャット詳細画面
import 'new_chat_screen.dart'; // 新規トーク作成画面

class MessageListScreen extends StatefulWidget {
  const MessageListScreen({super.key});

  @override
  State<MessageListScreen> createState() => _MessageListScreenState();
}

class _MessageListScreenState extends State<MessageListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  // ダミーデータ
  late List<Map<String, dynamic>> _allChats;

  @override
  void initState() {
    super.initState();
    // 初期データの生成
    _allChats = List.generate(15, (index) {
      final isGroup = index % 3 == 0;
      return {
        'id': index,
        'isGroup': isGroup,
        'name': isGroup ? 'グループ名 $index' : 'User Name $index',
        'lastMessage': isGroup ? '明日の待ち合わせ場所決めよう' : 'こんにちは！元気？',
        'time': '12:${30 + index}',
      };
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 検索フィルタリング
    final filteredChats = _allChats.where((chat) {
      final name = chat['name'] as String;
      return name.toLowerCase().contains(_searchText.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Message'),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: AppColors.textBody,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      
      // 新規トーク作成ボタン (FAB)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NewChatScreen(),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_comment_outlined, color: Colors.white),
      ),
      
      body: Column(
        children: [
          // --- 検索バー ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'トークを検索',
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

          // --- チャットリスト ---
          Expanded(
            child: filteredChats.isEmpty
                ? Center(
                    child: Text(
                      'トークが見つかりませんでした',
                      style: TextStyle(color: AppColors.textSub),
                    ),
                  )
                : ListView.separated(
                    itemCount: filteredChats.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, indent: 72),
                    itemBuilder: (context, index) {
                      final chat = filteredChats[index];
                      final isGroup = chat['isGroup'] as bool;
                      final name = chat['name'] as String;
                      final lastMessage = chat['lastMessage'] as String;
                      final time = chat['time'] as String;

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          radius: 28,
                          backgroundColor: isGroup ? AppColors.ice : AppColors.secondary,
                          child: Icon(
                            isGroup ? Icons.groups : Icons.person,
                            color: isGroup ? AppColors.primary : Colors.white,
                          ),
                        ),
                        title: Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textBody),
                        ),
                        subtitle: Text(
                          lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.textSub),
                        ),
                        trailing: Text(
                          time,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSub),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                name: name,
                                isGroup: isGroup,
                              ),
                            ),
                          );
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