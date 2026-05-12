import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

abstract class AuthRepository {
  Future<AuthUserModel?> restoreRememberedUser();
  Future<AuthUserModel> login({
    required String username,
    required String password,
    required bool rememberMe,
  });
  Future<AuthUserModel> register({
    required String username,
    required String password,
  });
  Future<void> signOut();
}

class FirestoreAuthRepository implements AuthRepository {
  FirestoreAuthRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  static const String _rememberFlagKey = 'remember_me';
  static const String _rememberedUserDocIdKey = 'remembered_user_doc_id';

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  @override
  Future<AuthUserModel?> restoreRememberedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool(_rememberFlagKey) ?? false;
    if (!rememberMe) {
      return null;
    }

    final docId = prefs.getString(_rememberedUserDocIdKey);
    if (docId == null || docId.isEmpty) {
      await _clearRememberedUser();
      return null;
    }

    final snapshot = await _users.doc(docId).get();
    if (!snapshot.exists) {
      await _clearRememberedUser();
      return null;
    }

    return AuthUserModel.fromFirestore(snapshot);
  }

  @override
  Future<AuthUserModel> login({
    required String username,
    required String password,
    required bool rememberMe,
  }) async {
    final normalizedUsername = username.trim().toLowerCase();
    final querySnapshot = await _users
        .where('usernameKey', isEqualTo: normalizedUsername)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw StateError('Username atau password salah.');
    }

    final user = AuthUserModel.fromFirestore(querySnapshot.docs.first);
    if (user.password != password) {
      throw StateError('Username atau password salah.');
    }

    if (rememberMe) {
      await _saveRememberedUser(user.id);
    } else {
      await _clearRememberedUser();
    }

    return user;
  }

  @override
  Future<AuthUserModel> register({
    required String username,
    required String password,
  }) async {
    final cleanUsername = username.trim();
    final normalizedUsername = cleanUsername.toLowerCase();

    final existing = await _users
        .where('usernameKey', isEqualTo: normalizedUsername)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) {
      throw StateError('Username sudah digunakan.');
    }

    final latestUser = await _users
        .orderBy('userId', descending: true)
        .limit(1)
        .get();
    final latestUserId = latestUser.docs.isEmpty
        ? 0
        : ((latestUser.docs.first.data()['userId'] as num?)?.toInt() ?? 0);
    final nextUserId = latestUserId + 1;

    final docId = nextUserId.toString();
    final user = AuthUserModel(
      id: docId,
      userId: nextUserId,
      name: cleanUsername,
      email: '$normalizedUsername@tripify.local',
      password: password,
      role: 'user',
    );
    await _users.doc(docId).set(user.toMap());

    return user;
  }

  @override
  Future<void> signOut() {
    return _clearRememberedUser();
  }

  Future<void> _saveRememberedUser(String userDocId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberFlagKey, true);
    await prefs.setString(_rememberedUserDocIdKey, userDocId);
  }

  Future<void> _clearRememberedUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_rememberFlagKey);
    await prefs.remove(_rememberedUserDocIdKey);
  }
}
