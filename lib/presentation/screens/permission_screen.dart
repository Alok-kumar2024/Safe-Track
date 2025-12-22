import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/permission_service.dart';
import 'home_screen.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen>
    with SingleTickerProviderStateMixin {
  final service = PermissionService();
  late AnimationController _animationController;

  PermissionStatus? location;
  PermissionStatus? sms;
  PermissionStatus? call;

  // Premium Color Palette
  static const primaryColor = Color(0xFF6366F1); // Indigo
  static const accentColor = Color(0xFF8B5CF6); // Purple
  static const textPrimaryColor = Color(0xFF1E293B); // Dark slate
  static const textSecondaryColor = Color(0xFF64748B); // Slate gray

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _loadStatus();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadStatus() async {
    location = await service.locationStatus();
    sms = await service.smsStatus();
    call = await service.callStatus();
    if (mounted) setState(() {});
  }

  bool get _allGranted =>
      location == PermissionStatus.granted &&
          sms == PermissionStatus.granted &&
          call == PermissionStatus.granted;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF8FAFC), // Soft white
              Color(0xFFF1F5F9), // Light gray
              Color(0xFFE0E7FF), // Light indigo tint
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Ambient background effect
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      primaryColor.withOpacity(0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(24),
                      child: FadeTransition(
                        opacity: _animationController,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.1),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _animationController,
                            curve: Curves.easeOut,
                          )),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              _buildHeader(),
                              const SizedBox(height: 40),
                              _buildPermissionList(),
                              const SizedBox(height: 20),
                              if ([location, sms, call].any(
                                      (s) => s == PermissionStatus.permanentlyDenied))
                                _buildSettingsHint(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  _buildBottomBar(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                primaryColor.withOpacity(0.15),
                accentColor.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Icon(
            Icons.verified_user_rounded,
            size: 48,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          "Required Permissions",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: textPrimaryColor,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "To ensure your safety, we need access to the following permissions for SOS alerts.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: textSecondaryColor,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionList() {
    return Column(
      children: [
        _PermissionTile(
          icon: Icons.location_on_rounded,
          title: "Location Access",
          subtitle: "To share your live location",
          status: location,
          onTap: () async {
            await service.requestLocation();
            _loadStatus();
          },
        ),
        const SizedBox(height: 16),
        _PermissionTile(
          icon: Icons.sms_rounded,
          title: "SMS Permission",
          subtitle: "To send emergency alerts",
          status: sms,
          onTap: () async {
            await service.requestSms();
            _loadStatus();
          },
        ),
        const SizedBox(height: 16),
        _PermissionTile(
          icon: Icons.phone_rounded,
          title: "Phone Call",
          subtitle: "To dial emergency numbers",
          status: call,
          onTap: () async {
            await service.requestCall();
            _loadStatus();
          },
        ),
      ],
    );
  }

  Widget _buildSettingsHint() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              color: Color(0xFFEF4444), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Permission Denied",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF991B1B),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  "Please enable permissions in settings.",
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFB91C1C),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: service.openSettings,
            child: const Text(
              "Settings",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFEF4444),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _allGranted
                ? () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => HomeScreen()),
              );
            }
                : null,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              shadowColor: Colors.transparent,
              // Disable default disabled styling to use our own opacity
              disabledBackgroundColor: Colors.transparent,
            ),
            child: Ink(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _allGranted
                      ? [primaryColor, accentColor]
                      : [
                    const Color(0xFFCBD5E1),
                    const Color(0xFF94A3B8)
                  ], // Grey when disabled
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  _allGranted ? "Continue to App" : "Allow All to Continue",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final PermissionStatus? status;
  final VoidCallback onTap;

  const _PermissionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isGranted = status == PermissionStatus.granted;
    final isPermanentlyDenied = status == PermissionStatus.permanentlyDenied;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isGranted
              ? const Color(0xFF10B981).withOpacity(0.3) // Green border
              : const Color(0xFFE2E8F0), // Grey border
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon Container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isGranted
                  ? const Color(0xFF10B981).withOpacity(0.1)
                  : const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: isGranted ? const Color(0xFF10B981) : const Color(0xFF6366F1),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Action Button/Status
          if (isGranted)
            const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF10B981),
              size: 28,
            )
          else if (isPermanentlyDenied)
            const Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFEF4444),
              size: 28,
            )
          else
            TextButton(
              onPressed: onTap,
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1).withOpacity(0.1),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Allow",
                style: TextStyle(
                  color: Color(0xFF6366F1),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
    );
  }
}