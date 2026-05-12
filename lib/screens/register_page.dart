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
    final mismatch = _passwordMismatch;
    return Scaffold(
      backgroundColor: const Color(0xFF0451C4),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(16),
                child: const SizedBox(
                  width: 30,
                  height: 30,
                  child: Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
              const SizedBox(height: 34),
              const Text(
                'Buat Akun',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Daftar pakai username dan password.',
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
                hasError: mismatch,
              ),
              const SizedBox(height: 16),
              _buildInput(
                label: 'Konfirmasi Password',
                controller: _confirmPasswordController,
                hintText: 'Masukkan ulang password',
                obscureText: true,
                hasError: mismatch,
              ),
              if (mismatch) ...[
                const SizedBox(height: 8),
                const Text(
                  'Password tidak sama.',
                  style: TextStyle(
                    color: Color(0xFFFFD2D2),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 26),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _registering ? null : _onRegisterPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFBD146),
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: const Color(0xFFE9DCA0),
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _registering
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Daftar',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
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
    bool hasError = false,
  }) {
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
        ),
      ],
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
