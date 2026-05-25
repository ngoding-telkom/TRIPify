import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../data/models/user_model.dart';
import '../data/repositories/firestore_auth_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.currentUser,
    required this.authRepository,
    required this.onLogout,
    required this.onProfileUpdated,
  });

  final AuthUserModel currentUser;
  final AuthRepository authRepository;
  final VoidCallback onLogout;
  final ValueChanged<AuthUserModel> onProfileUpdated;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _imgbbApiKey = '1bccec72e508ed53c5bec980b5a9c30e';
  final ImagePicker _imagePicker = ImagePicker();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _currentPasswordController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _verifyPasswordController;
  String _profileName = '';
  String _profileEmail = '';
  String _profilePassword = '';
  String? _profilePhotoUrl;
  String? _draftPhotoUrl;
  bool _editingProfile = false;
  bool _passwordStepConfirmed = false;
  bool _passwordMismatch = false;
  bool _savingProfile = false;
  bool _uploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    _profileName = widget.currentUser.name;
    _profileEmail = widget.currentUser.email;
    _profilePassword = widget.currentUser.password;
    _profilePhotoUrl = widget.currentUser.photoUrl;
    _draftPhotoUrl = _profilePhotoUrl;
    _nameController = TextEditingController(text: _profileName);
    _emailController = TextEditingController(text: _profileEmail);
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _verifyPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _verifyPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = _editingProfile ? _draftPhotoUrl : _profilePhotoUrl;
    return SizedBox.expand(
      child: ColoredBox(
        color: const Color(0xFFF4F1F1),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.only(bottom: 110 + bottomInset),
                  child: Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            height: 210,
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF2F1398), Color(0xFF0451C4)],
                              ),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(28),
                                bottomRight: Radius.circular(28),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Profile',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Image.asset(
                                      'assets/images/logo_small.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: -44,
                            child: Center(
                              child: Stack(
                                children: [
                                  GestureDetector(
                                    onTap: _editingProfile && !_uploadingAvatar
                                        ? _pickAvatar
                                        : null,
                                    child: Container(
                                      width: 96,
                                      height: 96,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 4,
                                        ),
                                        image:
                                            avatarUrl == null ||
                                                avatarUrl.isEmpty
                                            ? null
                                            : DecorationImage(
                                                image: NetworkImage(avatarUrl),
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                      child:
                                          avatarUrl == null || avatarUrl.isEmpty
                                          ? const Icon(
                                              Icons.person,
                                              size: 48,
                                              color: Color(0xFF9A9A9A),
                                            )
                                          : null,
                                    ),
                                  ),
                                  if (_editingProfile)
                                    Positioned(
                                      right: 2,
                                      bottom: 2,
                                      child: Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: const Color(0xFF0451C4),
                                          ),
                                        ),
                                        child: _uploadingAvatar
                                            ? const Padding(
                                                padding: EdgeInsets.all(6),
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                            : const Icon(
                                                Icons.camera_alt,
                                                size: 14,
                                                color: Color(0xFF0451C4),
                                              ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 64),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            _editingProfile
                                ? _buildProfileEditCard()
                                : _buildProfileInfoCard(),
                            const SizedBox(height: 18),
                            _editingProfile
                                ? _buildProfileEditActions()
                                : _buildProfileActions(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Akun',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          _buildProfileRow('Nama', _profileName),
          const SizedBox(height: 12),
          _buildProfileRow(
            'Email',
            _profileEmail.isEmpty ? '-' : _profileEmail,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileEditCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Edit Profile',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Nama',
              hintText: 'Masukkan nama',
              filled: true,
              fillColor: const Color(0xFFF6F6F6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'Masukkan email',
              filled: true,
              fillColor: const Color(0xFFF6F6F6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Password',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          if (!_passwordStepConfirmed) ...[
            TextField(
              controller: _currentPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password Saat Ini',
                hintText: 'Masukkan password saat ini',
                filled: true,
                fillColor: const Color(0xFFF6F6F6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _confirmCurrentPassword,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF333333),
                  side: const BorderSide(color: Color(0xFFCDD2E6)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Konfirmasi Password'),
              ),
            ),
          ] else ...[
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              onChanged: (_) => _checkPasswordMatch(),
              decoration: InputDecoration(
                labelText: 'Password Baru',
                hintText: 'Masukkan password baru',
                filled: true,
                fillColor: const Color(0xFFF6F6F6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _verifyPasswordController,
              obscureText: true,
              onChanged: (_) => _checkPasswordMatch(),
              decoration: InputDecoration(
                labelText: 'Verifikasi Password',
                hintText: 'Masukkan ulang password',
                filled: true,
                fillColor: const Color(0xFFF6F6F6),
                errorText: _passwordMismatch ? 'Password tidak sama.' : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _enterEditProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFCD28),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Edit Profile',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: widget.onLogout,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF333333),
              side: const BorderSide(color: Color(0xFFCDD2E6)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Logout'),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileEditActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _savingProfile ? null : _cancelEditProfile,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF333333),
              side: const BorderSide(color: Color(0xFFCDD2E6)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Batal'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _savingProfile ? null : _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFCD28),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _savingProfile
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Simpan',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: const TextStyle(color: Color(0xFF7A7A7A), fontSize: 12),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF242424),
            ),
          ),
        ),
      ],
    );
  }

  void _enterEditProfile() {
    setState(() {
      _editingProfile = true;
      _passwordStepConfirmed = false;
      _passwordMismatch = false;
      _nameController.text = _profileName;
      _emailController.text = _profileEmail;
      _draftPhotoUrl = _profilePhotoUrl;
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _verifyPasswordController.clear();
    });
  }

  void _cancelEditProfile() {
    setState(() {
      _editingProfile = false;
      _passwordStepConfirmed = false;
      _passwordMismatch = false;
      _nameController.text = _profileName;
      _emailController.text = _profileEmail;
      _draftPhotoUrl = _profilePhotoUrl;
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _verifyPasswordController.clear();
    });
  }

  void _confirmCurrentPassword() {
    final current = _currentPasswordController.text;
    if (current.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan password saat ini.')),
      );
      return;
    }
    if (current != _profilePassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Password saat ini salah.')));
      return;
    }
    setState(() {
      _passwordStepConfirmed = true;
      _passwordMismatch = false;
      _newPasswordController.clear();
      _verifyPasswordController.clear();
    });
  }

  void _checkPasswordMatch() {
    if (!_passwordStepConfirmed) {
      return;
    }
    final newPassword = _newPasswordController.text;
    final verify = _verifyPasswordController.text;
    setState(() {
      _passwordMismatch = verify.isNotEmpty && newPassword != verify;
    });
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nama wajib diisi.')));
      return;
    }
    if (email.isNotEmpty && !email.contains('@')) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Email tidak valid.')));
      return;
    }

    String? newPassword;
    if (_passwordStepConfirmed) {
      newPassword = _newPasswordController.text;
      final verify = _verifyPasswordController.text;
      if (newPassword.isEmpty || verify.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password baru wajib diisi.')),
        );
        return;
      }
      if (newPassword != verify) {
        setState(() => _passwordMismatch = true);
        return;
      }
    }

    setState(() => _savingProfile = true);
    try {
      await widget.authRepository.updateProfile(
        userDocId: widget.currentUser.id,
        name: name,
        email: email,
        password: newPassword,
        photoUrl: _draftPhotoUrl,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _profileName = name;
        _profileEmail = email;
        if (newPassword != null) {
          _profilePassword = newPassword;
        }
        _profilePhotoUrl = _draftPhotoUrl;
        _editingProfile = false;
        _passwordStepConfirmed = false;
        _passwordMismatch = false;
      });
      widget.onProfileUpdated(
        AuthUserModel(
          id: widget.currentUser.id,
          userId: widget.currentUser.userId,
          name: name,
          email: email,
          password: newPassword ?? _profilePassword,
          role: widget.currentUser.role,
          photoUrl: _draftPhotoUrl,
        ),
      );
    } on FirebaseException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal simpan profil: ${error.message ?? error.code}'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _savingProfile = false);
      }
    }
  }

  Future<void> _pickAvatar() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 900,
      maxHeight: 900,
      imageQuality: 88,
    );
    if (image == null) {
      return;
    }

    setState(() => _uploadingAvatar = true);
    try {
      final bytes = await image.readAsBytes();
      final response = await http.post(
        Uri.parse('https://api.imgbb.com/1/upload?key=$_imgbbApiKey'),
        body: {'image': base64Encode(bytes)},
      );
      if (response.statusCode != 200) {
        throw StateError('Upload gagal: ${response.statusCode}');
      }
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final success = json['success'] == true;
      if (!success) {
        throw StateError('Upload gagal.');
      }
      final data = json['data'] as Map<String, dynamic>?;
      final url = (data?['url'] ?? data?['display_url']) as String?;
      if (url == null || url.isEmpty) {
        throw StateError('Upload gagal.');
      }
      if (!mounted) {
        return;
      }
      final fixedUrl = url.replaceFirst(
        'https://i.ibb.co/',
        'https://i.ibb.co.com/',
      );
      setState(() => _draftPhotoUrl = fixedUrl);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal upload foto: $error')));
    } finally {
      if (mounted) {
        setState(() => _uploadingAvatar = false);
      }
    }
  }
}
