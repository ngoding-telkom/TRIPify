import 'package:flutter/material.dart';

import '../data/models/user_model.dart';
import '../data/repositories/firestore_auth_repository.dart';
import '../data/repositories/firestore_booking_repository.dart';
import 'debug_tools.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({
    super.key,
    required this.currentUser,
    required this.authRepository,
    required this.bookingRepository,
  });

  final AuthUserModel currentUser;
  final AuthRepository authRepository;
  final BookingRepository bookingRepository;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 140),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Admin Dashboard',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          _buildDebugActions(context),
          const SizedBox(height: 24),
          _BookingCodeActionSection(bookingRepository: bookingRepository),
          const SizedBox(height: 24),
          _UserManagementSection(
            currentUser: currentUser,
            authRepository: authRepository,
          ),
        ],
      ),
    );
  }

  Widget _buildDebugActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Admin Tools',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () =>
                    _openDebugScreen(context, DebugSection.booking),
                icon: const Icon(Icons.bookmark_outline),
                label: const Text('Booking Debug'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _openDebugScreen(context, DebugSection.ticket),
                icon: const Icon(Icons.train_outlined),
                label: const Text('Ticket Debug'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _openDebugScreen(
    BuildContext context,
    DebugSection section,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DebugToolsScreen(
          bookingRepository: bookingRepository,
          initialSection: section,
        ),
      ),
    );
  }
}

class _UserManagementSection extends StatelessWidget {
  const _UserManagementSection({
    required this.currentUser,
    required this.authRepository,
  });

  final AuthUserModel currentUser;
  final AuthRepository authRepository;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'User Management',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<AuthUserModel>>(
          stream: authRepository.watchUsers(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text(
                'Gagal memuat user: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: CircularProgressIndicator(),
              );
            }
            final users = snapshot.data ?? const <AuthUserModel>[];
            if (users.isEmpty) {
              return const Text('Belum ada user terdaftar.');
            }

            return Column(
              children: users
                  .map(
                    (user) => _UserCard(
                      user: user,
                      currentUser: currentUser,
                      authRepository: authRepository,
                    ),
                  )
                  .toList(growable: false),
            );
          },
        ),
      ],
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.user,
    required this.currentUser,
    required this.authRepository,
  });

  final AuthUserModel user;
  final AuthUserModel currentUser;
  final AuthRepository authRepository;

  @override
  Widget build(BuildContext context) {
    final isSelf = user.id == currentUser.id;
    return Card(
      child: ListTile(
        title: Text(user.name.isEmpty ? 'Unknown' : user.name),
        subtitle: Text(
          'ID: ${user.userId}\nEmail: ${user.email.isEmpty ? '-' : user.email}',
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<String>(
              value: user.role,
              items: const [
                DropdownMenuItem(value: 'user', child: Text('user')),
                DropdownMenuItem(value: 'admin', child: Text('admin')),
              ],
              onChanged: isSelf
                  ? null
                  : (value) async {
                      if (value == null || value == user.role) {
                        return;
                      }
                      await authRepository.updateUserRole(
                        userDocId: user.id,
                        role: value,
                      );
                    },
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: isSelf ? 'Tidak bisa hapus diri sendiri' : 'Hapus user',
              onPressed: isSelf
                  ? null
                  : () => _confirmDelete(context, user, authRepository),
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    AuthUserModel user,
    AuthRepository authRepository,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus user?'),
        content: Text('Hapus ${user.name.isEmpty ? 'user ini' : user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    await authRepository.deleteUser(userDocId: user.id);
  }
}

class _BookingCodeActionSection extends StatefulWidget {
  const _BookingCodeActionSection({required this.bookingRepository});

  final BookingRepository bookingRepository;

  @override
  State<_BookingCodeActionSection> createState() =>
      _BookingCodeActionSectionState();
}

class _BookingCodeActionSectionState extends State<_BookingCodeActionSection> {
  final TextEditingController _codeController = TextEditingController();
  String? _message;
  bool _error = false;
  bool _processing = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Konfirmasi / Batalkan Booking',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _codeController,
          decoration: const InputDecoration(
            labelText: 'Kode tiket (contoh: TRP-xxxxx)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _processing
                    ? null
                    : () => _updateStatus('confirmed'),
                child: const Text('Konfirmasi'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: _processing
                    ? null
                    : () => _updateStatus('cancelled'),
                child: const Text('Batalkan'),
              ),
            ),
          ],
        ),
        if (_message != null) ...[
          const SizedBox(height: 10),
          Text(
            _message!,
            style: TextStyle(
              color: _error ? Colors.red : Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _updateStatus(String status) async {
    setState(() {
      _processing = true;
      _message = null;
      _error = false;
    });
    try {
      final updated = await widget.bookingRepository.updateBookingStatusByCode(
        code: _codeController.text,
        status: status,
      );
      setState(() {
        _message = 'Berhasil update $updated booking.';
        _error = false;
      });
    } catch (error) {
      setState(() {
        _message = 'Gagal update booking: $error';
        _error = true;
      });
    } finally {
      if (mounted) {
        setState(() => _processing = false);
      }
    }
  }
}
