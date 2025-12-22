import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:safe_track/presentation/screens/login_screen.dart';
import 'package:safe_track/presentation/screens/permission_screen.dart';
import 'package:safe_track/presentation/screens/profile_setup_screen.dart';
import '../../services/permission_service.dart';
import '../../state/home_provider.dart';
import '../../state/profile_provider.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // The next screen to navigate to
  Widget? _nextScreen;
  bool _fadeOut = false;

  @override
  void initState() {
    super.initState();

    // 1. Setup Animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    // 2. Start Animation & Logic
    _animationController.forward();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Run minimum timer and data loading in parallel
    // This ensures splash stays for at least 2.5s, but also waits for data if it takes longer
    await Future.wait([
      Future.delayed(const Duration(milliseconds: 2500)),
      _prepareData(),
    ]);

    if (!mounted) return;

    // Start Exit Transition
    setState(() => _fadeOut = true);
    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;

    // Navigate
    if (_nextScreen != null) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => _nextScreen!,
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  /// Handles all the async logic to determine where to go next
  Future<void> _prepareData() async {
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;

    // 1. Check Login
    if (user == null) {
      _nextScreen = const LoginScreen();
      return;
    }

    // 2. Initialize Providers (Restore Data)
    final profileProvider = context.read<ProfileProvider>();
    final homeProvider = context.read<HomeProvider>();

    try {
      await profileProvider.init();
      await homeProvider.init();
    } catch (e) {
      debugPrint("Error initializing providers: $e");
      // Handle error or continue safe
    }

    // 3. Check if Profile is set up
    if (!profileProvider.isProfileSet) {
      _nextScreen = const ProfileSetUpScreen();
      return;
    }

    // 4. Check Permissions
    final permissionService = PermissionService();
    final granted = await permissionService.allGranted();

    if (!granted) {
      _nextScreen = const PermissionScreen();
    } else {
      _nextScreen = const HomeScreen();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedOpacity(
        duration: const Duration(milliseconds: 400),
        opacity: _fadeOut ? 0.0 : 1.0,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF6366F1), // Indigo
                Color(0xFF8B5CF6), // Purple
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // Ambient Background Circles
              Positioned(
                top: -100,
                left: -100,
                child: _buildAmbientCircle(),
              ),
              Positioned(
                bottom: -100,
                right: -100,
                child: _buildAmbientCircle(),
              ),

              // Main Content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),

                    // Animated Logo
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: SvgPicture.asset(
                          'assets/images/shield.svg',
                          width: 80,
                          height: 80,
                          // Use the primary color for the logo tint
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF6366F1),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Animated Text
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            const Text(
                              "SafeGuard",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 42,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1.0,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                "Your Safety, Our Priority",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Loader
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: const Padding(
                        padding: EdgeInsets.only(bottom: 60),
                        child: SpinKitPulse(
                          color: Colors.white,
                          size: 60,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmbientCircle() {
    return Container(
      width: 400,
      height: 400,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.05),
      ),
    );
  }
}