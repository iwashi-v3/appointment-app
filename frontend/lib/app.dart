import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'screens/home/home_screen.dart';
import 'screens/map/map_screen.dart';
import 'screens/message/message_list_screen.dart';
import 'screens/settings/settings_screen.dart';

class MachiawaseApp extends StatelessWidget {
  // ゲストモードかどうかを親から受け取る
  final bool isGuest;

  const MachiawaseApp({super.key, required this.isGuest});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Machiawase App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.background,
          background: AppColors.background,
        ),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textBody,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: AppColors.textBody),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: AppColors.ice.withOpacity(0.5),
          labelTextStyle: MaterialStateProperty.all(
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSub),
          ),
          iconTheme: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return const IconThemeData(color: AppColors.glacierBlue);
            }
            return const IconThemeData(color: AppColors.warmGray);
          }),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
      // ゲスト状態を RootScaffold に渡す
      home: RootScaffold(isGuest: isGuest),
    );
  }
}

class RootScaffold extends StatefulWidget {
  final bool isGuest;
  const RootScaffold({super.key, required this.isGuest});

  @override
  State<RootScaffold> createState() => _RootScaffoldState();
}

class _RootScaffoldState extends State<RootScaffold> {
  // ゲストユーザーはマップ機能がメインのため、初期表示をMap(インデックス1)にする
  int _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    // 各画面に isGuest フラグを渡す
    final List<Widget> screens = [
      HomeScreen(isGuest: widget.isGuest),           // 1. Home (制限あり)
      MapScreen(isGuest: widget.isGuest),            // 2. Map (制限なし、作成ボタンのみ制限)
      MessageListScreen(isGuest: widget.isGuest),    // 3. Message (制限あり)
      const SettingsScreen(),                        // 4. Setting (今回は制限なし)
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Message',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Setting',
          ),
        ],
      ),
    );
  }
}