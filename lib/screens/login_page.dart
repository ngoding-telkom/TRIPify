import 'dart:async';

import 'package:flutter/material.dart';

import '../data/models/user_model.dart';
import '../data/repositories/firestore_auth_repository.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.authRepository,
    required this.onLoggedIn,
  });

  final AuthRepository authRepository;
  final ValueChanged<AuthUserModel> onLoggedIn;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _rememberMe = false;
  bool _loggingIn = false;
  bool _loginErrorFlash = false;
  Timer? _errorResetTimer;

  @override
  void dispose() {
    _errorResetTimer?.cancel();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0451C4),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Masuk',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Masuk ke akun Tripify Anda.',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 28),
              _buildInput(
                label: 'Username',
                controller: _usernameController,
                hintText: 'Masukkan username',
              ),
              const SizedBox(height: 16),
              _buildInput(
                label: 'Password',
                controller: _passwordController,
                hintText: 'Masukkan password',
                obscureText: true,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: _loggingIn
                        ? null
                        : (value) =>
                              setState(() => _rememberMe = value ?? false),
                    side: const BorderSide(color: Colors.white),
                    checkColor: Colors.black,
                    activeColor: const Color(0xFFFBD146),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Remember Me',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loggingIn ? null : _onLoginPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFBD146),
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: const Color(0xFFE9DCA0),
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _loggingIn
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Masuk',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: TextButton(
                  onPressed: _loggingIn ? null : _openRegisterPage,
                  child: const Text(
                    'Belum punya akun? Daftar',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required String label,
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
  }) {
    final hasError = _loginErrorFlash;
    final borderColor = hasError ? const Color(0xFFFF5C5C) : Colors.white;
    final textColor = hasError ? const Color(0xFFFF5C5C) : Colors.black;
    final hintColor = hasError
        ? const Color(0xCCFF9A9A)
        : const Color(0xFF9A9A9A);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscureText,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: hintColor),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor, width: 1.6),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor, width: 1.6),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor, width: 1.8),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _onLoginPressed() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    if (username.isEmpty || password.isEmpty) {
      _flashErrorState();
      return;
    }

    setState(() => _loggingIn = true);
    try {
      final user = await widget.authRepository.login(
        username: username,
        password: password,
        rememberMe: _rememberMe,
      );
      if (!mounted) {
        return;
      }
      widget.onLoggedIn(user);
    } catch (_) {
      _flashErrorState();
    } finally {
      if (mounted) {
        setState(() => _loggingIn = false);
      }
    }
  }

  void _flashErrorState() {
    _errorResetTimer?.cancel();
    setState(() => _loginErrorFlash = true);
    _errorResetTimer = Timer(const Duration(milliseconds: 900), () {
      if (!mounted) {
        return;
      }
      setState(() => _loginErrorFlash = false);
    });
  }

  Future<void> _openRegisterPage() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RegisterPage(
          authRepository: widget.authRepository,
          onRegistered: (user) {
            widget.onLoggedIn(user);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}
