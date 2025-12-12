import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../constants/app_colors.dart';
import 'otp_verify_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _userIdController = TextEditingController();
  final _userNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // --- 追加: パスワードバリデーション関数 ---
  String? _validatePassword(String password) {
    if (password.length < 8) {
      return 'パスワードは8文字以上で入力してください';
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'パスワードには大文字を1文字以上含めてください';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'パスワードには数字を1文字以上含めてください';
    }
    return null;
  }

  Future<void> _signup() async {
    // 1. 空文字チェック
    if (_userIdController.text.isEmpty ||
        _userNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('全ての項目を入力してください')),
      );
      return;
    }

    // 2. 追加: パスワード強度チェック
    final passwordError = _validatePassword(_passwordController.text);
    if (passwordError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(passwordError),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;
      
      // サインアップ処理
      await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        data: {
          'username': _userIdController.text.trim(),
          'full_name': _userNameController.text.trim(),
        },
      );

      if (!mounted) return;

      // 成功したらOTP入力画面へ遷移
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpVerifyScreen(email: _emailController.text.trim()),
        ),
      );

    } on AuthException catch (e) {
      if (!mounted) return;

      String errorMessage;
      switch (e.message) {
        case 'User already registered':
          errorMessage = 'このメールアドレスは既に登録されています';
          break;
        case 'Password should be at least 6 characters':
          // ※ローカルバリデーションで弾くためここに来る確率は低いですが念のため
          errorMessage = 'パスワードは6文字以上必要です';
          break;
        case 'Invalid login credentials':
          errorMessage = 'メールアドレスまたはパスワードが正しくありません';
          break;
        case 'Email not confirmed':
          errorMessage = 'メールアドレスが確認されていません';
          break;
        default:
          errorMessage = '登録に失敗しました: ${e.message}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.redAccent),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('予期せぬエラーが発生しました'), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textBody),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('新規登録', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
              const SizedBox(height: 32),
              
              _buildTextField(_userIdController, 'User ID', Icons.alternate_email, helperText: '※重複しないID'),
              const SizedBox(height: 16),
              _buildTextField(_userNameController, 'User Name', Icons.person_outline),
              const SizedBox(height: 16),
              _buildTextField(_emailController, 'Email', Icons.email_outlined, inputType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _buildTextField(
                _passwordController, 
                'Password', 
                Icons.lock_outline, 
                isObscure: true,
                helperText: '※8文字以上、大文字・数字を含めてください', // ヘルパーテキストを追加してユーザーに要件を伝達
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isLoading ? null : _signup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                    : const Text('登録して認証コードを受け取る', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isObscure = false, TextInputType? inputType, String? helperText}) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText, // ヘルパーテキストを表示できるように修正
        helperMaxLines: 2,      // 長くなっても表示されるように
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}

