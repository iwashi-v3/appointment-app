import 'package:flutter/material.dart';

class AppColors {
  // 画像から抽出したカラーコード
  static const Color overcast = Color(0xFFF1F1F2);   // 背景色など
  static const Color warmGray = Color(0xFFBCBABE);   // サブテキスト、非アクティブアイコン
  static const Color ice = Color(0xFFA1D6E2);        // アクセント、薄い背景
  static const Color glacierBlue = Color(0xFF1995AD); // メインカラー、ボタン、強調

  // 意味合いを持たせたエイリアス（使いやすくするため）
  static const Color primary = glacierBlue;
  static const Color secondary = ice;
  static const Color background = overcast;
  static const Color textBody = Color(0xFF4A4A4A); // 読みやすさのため、WarmGrayより濃いグレーを文字用に用意
  static const Color textSub = warmGray;
}