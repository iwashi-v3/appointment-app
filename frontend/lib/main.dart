import 'package:flutter/material.dart';
import 'app.dart';

void main() {
  // Flutterのバインディングを初期化（将来的にFirebaseなどを入れる場合に必要になります）
  WidgetsFlutterBinding.ensureInitialized();
  
  // アプリを起動
  runApp(const MachiawaseApp(isGuest: true));
}