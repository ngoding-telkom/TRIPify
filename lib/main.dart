import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'data/models/user_model.dart';
import 'data/repositories/firestore_auth_repository.dart';
import 'data/repositories/firestore_booking_repository.dart';
import 'firebase_options.dart';
import 'screens/auth_choice_page.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_page.dart';
import 'screens/orders_page.dart';
import 'screens/profile_screen.dart';
import 'screens/register_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AppRoot();
  }
}

class _AppRoot extends StatefulWidget {
  const _AppRoot();

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  late final AuthRepository _authRepository = FirestoreAuthRepository(
    firestore: FirebaseFirestore.instance,
  );
  late final Future<AuthUserModel?> _restoredUserFuture = _authRepository
      .restoreRememberedUser();
  AuthUserModel? _signedInUser;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tripify',
      theme: ThemeData(useMaterial3: true, primarySwatch: Colors.blue),
      home: FutureBuilder<AuthUserModel?>(
        future: _restoredUserFuture,
        builder: (context, snapshot) {
          if (_signedInUser != null) {
            return HomeScreen(
              currentUser: _signedInUser!,
              authRepository: _authRepository,
              onLogout: _onLogoutPressed,
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final restoredUser = snapshot.data;
          if (restoredUser != null) {
            return HomeScreen(
              currentUser: restoredUser,
              authRepository: _authRepository,
              onLogout: _onLogoutPressed,
            );
          }

          return AuthChoicePage(
            onLoginPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => LoginPage(
                  authRepository: _authRepository,
                  onLoggedIn: (user) {
                    setState(() => _signedInUser = user);
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ),
              ),
            ),
            onRegisterPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => RegisterPage(
                  authRepository: _authRepository,
                  onRegistered: (_) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => LoginPage(
                          authRepository: _authRepository,
                          onLoggedIn: (user) {
                            setState(() => _signedInUser = user);
                            Navigator.of(
                              context,
                            ).popUntil((route) => route.isFirst);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _onLogoutPressed() async {
    await _authRepository.signOut();
    if (!mounted) {
      return;
    }
    setState(() => _signedInUser = null);
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.currentUser,
    required this.authRepository,
    required this.onLogout,
  });

  final AuthUserModel currentUser;
  final AuthRepository authRepository;
  final Future<void> Function() onLogout;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedNavIndex = 0;
  late AuthUserModel _currentUser;
  final BookingRepository _bookingRepository = FirestoreBookingRepository(
    firestore: FirebaseFirestore.instance,
  );

  @override
  void initState() {
    super.initState();
    _currentUser = widget.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final Widget content;
    if (_selectedNavIndex == 1) {
      content = OrdersPage(
        bookingRepository: _bookingRepository,
        userId: _currentUser.id,
        onBackToHome: () => setState(() => _selectedNavIndex = 0),
      );
    } else if (_selectedNavIndex == 2) {
      content = ProfileScreen(
        currentUser: _currentUser,
        authRepository: widget.authRepository,
        onLogout: widget.onLogout,
        onProfileUpdated: (updated) => setState(() => _currentUser = updated),
      );
    } else {
      content = _currentUser.role == 'admin'
          ? AdminDashboardScreen(
              currentUser: _currentUser,
              authRepository: widget.authRepository,
              bookingRepository: _bookingRepository,
            )
          : DashboardScreen(
              displayName: _currentUser.name,
              userId: _currentUser.id,
              bookingRepository: _bookingRepository,
            );
    }

    return Scaffold(
      body: Stack(children: [content, _buildBottomNavBar(bottomInset)]),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedNavIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedNavIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected
                ? Colors.black
                : Colors.black.withValues(alpha: 0.7),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isSelected
                  ? Colors.black
                  : Colors.black.withValues(alpha: 0.7),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(double bottomInset) {
    return Positioned(
      bottom: 16 + bottomInset,
      left: 24,
      right: 24,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(0, Icons.home_outlined, 'Beranda'),
                if (_currentUser.role != 'admin')
                  _buildNavItem(1, Icons.bookmark_outline, 'Orders'),
                _buildNavItem(2, Icons.person_outline, 'You'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
