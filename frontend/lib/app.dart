import 'package:flutter/material.dart';
import 'constants/app_colors.dart'; // 定義した色をインポート

class MachiawaseApp extends StatelessWidget {
  const MachiawaseApp({super.key});

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
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 2,
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

  // まだファイルを作成していないため、標準的なWidgetで仮置きしています。
  // 後ほど lib/screens/ 以下のファイルを作成したら、それらをimportして置き換えてください。
  final List<Widget> _screens = [
    // 1. Home画面の仮置き
    const Scaffold(
      body: Center(child: Text('Home Screen (Page 3)')),
    ),
    // 2. Map画面の仮置き
    const Scaffold(
      body: Center(child: Text('Map Screen (Page 4)')),
    ),
    // 3. Message画面の仮置き
    const Scaffold(
      body: Center(child: Text('Message Screen (Page 8)')),
    ),
    // 4. Setting画面の仮置き
    const Scaffold(
      body: Center(child: Text('Setting Screen (Page 10)')),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 現在のインデックスに応じた画面を表示
      body: _screens[_currentIndex],
      
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