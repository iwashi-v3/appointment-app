import 'package:flutter/material.dart';
import 'package:frontend/screens/home/home_screen.dart';
import 'constants/app_colors.dart';
// 作成したHomeScreenをインポート

class MachiawaseApp extends StatelessWidget {
  const MachiawaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Machiawase App',
      debugShowCheckedModeBanner: false,
      
      // アプリ全体のテーマ設定
      theme: ThemeData(
        useMaterial3: true,
        
        // カラーパレットの適用
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,       // Glacier Blue
          secondary: AppColors.secondary,   // Ice
          surface: AppColors.background,    // Overcast
          background: AppColors.background, // Overcast
        ),
        
        // 背景色の設定
        scaffoldBackgroundColor: AppColors.background,
        
        // AppBar（ヘッダー）のテーマ
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textBody,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: AppColors.textBody),
        ),
        
        // 下部ナビゲーションバーのテーマ
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
        
        // フローティングアクションボタンのテーマ
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        
        // ボタンのテーマ
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
      home: const RootScaffold(),
    );
  }
}

class RootScaffold extends StatefulWidget {
  const RootScaffold({super.key});

  @override
  State<RootScaffold> createState() => _RootScaffoldState();
}

class _RootScaffoldState extends State<RootScaffold> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // 画面のリスト
    final List<Widget> screens = [
      // 1. Home: 作成済みの本物のファイルを使用
      const HomeScreen(),
      
      // 2. Map: 仮置き
      const Scaffold(
        body: Center(child: Text('Map Screen (Page 4)')),
      ),
      
      // 3. Message: 仮置き
      const Scaffold(
        body: Center(child: Text('Message Screen (Page 8)')),
      ),
      
      // 4. Setting: 仮置き
      const Scaffold(
        body: Center(child: Text('Setting Screen (Page 10)')),
      ),
    ];

    return Scaffold(
      // 現在選択されているインデックスの画面を表示
      body: screens[_currentIndex],
      
      // 下部のナビゲーションバー
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