import 'package:flutter/material.dart';

import '../data/models/user_model.dart';
import '../data/repositories/firestore_auth_repository.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({
    super.key,
    required this.authRepository,
    required this.onRegistered,
  });

  final AuthRepository authRepository;
  final ValueChanged<AuthUserModel> onRegistered;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _passwordMismatch = false;
  bool _registering = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final mismatch = _passwordMismatch;
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
                    padding: const EdgeInsets.fromLTRB(33, 53, 33, 28),
                    child: Column(
                      children: [
                        const Text(
                          'Register',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 36,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 35),
                        _buildInput(
                          controller: _usernameController,
                          hintText: 'Masukkan Username Anda',
                          trailingIcon: Icons.person_outline,
                        ),
                        const SizedBox(height: 10),
                        _buildInput(
                          controller: _passwordController,
                          hintText: 'Password',
                          obscureText: true,
                          hasError: mismatch,
                          trailingIcon: Icons.vpn_key_outlined,
                        ),
                        const SizedBox(height: 10),
                        _buildInput(
                          controller: _confirmPasswordController,
                          hintText: 'Verifikasi Password',
                          obscureText: true,
                          hasError: mismatch,
                          trailingIcon: Icons.vpn_key_outlined,
                        ),
                        if (mismatch) ...[
                          const SizedBox(height: 8),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Password tidak sama.',
                              style: TextStyle(
                                color: Color(0xFFD62828),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 35),
                        SizedBox(
                          width: 218,
                          child: ElevatedButton(
                            onPressed: _registering ? null : _onRegisterPressed,
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
                            child: _registering
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Daftar',
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
    bool hasError = false,
  }) {
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
      onChanged: (_) {
        if (!_passwordMismatch) {
          return;
        }
        final stillMismatch =
            _passwordController.text != _confirmPasswordController.text;
        if (!stillMismatch) {
          setState(() => _passwordMismatch = false);
        }
      },
    );
  }

  Future<void> _onRegisterPressed() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (username.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showError('Semua field wajib diisi.');
      return;
    }

    if (password != confirmPassword) {
      setState(() => _passwordMismatch = true);
      return;
    }

    setState(() {
      _passwordMismatch = false;
      _registering = true;
    });

    try {
      final user = await widget.authRepository.register(
        username: username,
        password: password,
      );
      if (!mounted) {
        return;
      }
      widget.onRegistered(user);
    } on StateError catch (error) {
      _showError(error.message);
    } catch (error) {
      _showError('Registrasi gagal: $error');
    } finally {
      if (mounted) {
        setState(() => _registering = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
