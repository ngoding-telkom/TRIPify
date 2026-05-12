import 'dart:async';

import 'package:flutter/material.dart';

import '../data/models/user_model.dart';
import '../data/repositories/firestore_auth_repository.dart';

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
    final topInset = MediaQuery.paddingOf(context).top;
    return Scaffold(
      backgroundColor: const Color(0xFF0E43B9),
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF3611AC),
                    Color(0xFF194FD7),
                    Color(0xFF0F43B9),
                  ],
                ),
              ),
            ),
          ),
                    Column(
            children: [
              SizedBox(height: topInset + 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        width: 27,
                        height: 26,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(63),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 38),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 84),
                child: Image.asset(
                  'assets/images/logo_big.png',
                  fit: BoxFit.fitWidth,
                ),
              ),
              const SizedBox(height: 26),
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(34, 47, 34, 28),
                    child: Column(
                      children: [
                        const Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 36,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 40),
                        _buildInput(
                          controller: _usernameController,
                          hintText: 'Masukkan Username Anda',
                          trailingIcon: Icons.person_outline,
                        ),
                        const SizedBox(height: 16),
                        _buildInput(
                          controller: _passwordController,
                          hintText: 'Password',
                          obscureText: true,
                          trailingIcon: Icons.vpn_key_outlined,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: Checkbox(
                                value: _rememberMe,
                                onChanged: _loggingIn
                                    ? null
                                    : (value) => setState(
                                        () => _rememberMe = value ?? false,
                                      ),
                                side: const BorderSide(
                                  color: Color(0xFFB3B3B3),
                                  width: 0.8,
                                ),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: const VisualDensity(
                                  horizontal: -4,
                                  vertical: -4,
                                ),
                                checkColor: Colors.black,
                                activeColor: const Color(0xFFFBD146),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Ingat Saya',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            const Text(
                              'Lupa password?',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 38),
                        SizedBox(
                          width: 218,
                          child: ElevatedButton(
                            onPressed: _loggingIn ? null : _onLoginPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFCD28),
                              foregroundColor: Colors.black,
                              disabledBackgroundColor: const Color(0xFFE9DCA0),
                              minimumSize: const Size.fromHeight(38),
                              elevation: 2,
                              shadowColor: Colors.black26,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: _loggingIn
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Masuk',
                                    style: TextStyle(
                                      fontSize: 25 * 0.57,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hintText,
    required IconData trailingIcon,
    bool obscureText = false,
  }) {
    final hasError = _loginErrorFlash;
    final borderColor = hasError
        ? const Color(0xFFFF5C5C)
        : const Color(0xFFD0D0D0);
    final textColor = hasError ? const Color(0xFFFF5C5C) : Colors.black;
    final hintColor = hasError
        ? const Color(0xCCFF9A9A)
        : const Color(0xFFB3B3B3);

    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: textColor, fontSize: 31 * 0.57),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: hintColor, fontSize: 31 * 0.57),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        suffixIcon: Icon(trailingIcon, size: 16, color: hintColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
      ),
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
}
