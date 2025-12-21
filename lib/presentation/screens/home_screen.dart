import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:safe_track/presentation/screens/alert_history_screen.dart';
import 'package:safe_track/presentation/screens/settings_screen.dart';
import 'package:safe_track/services/shake_services.dart';
import 'package:safe_track/state/home_provider.dart';
import 'package:safe_track/state/profile_provider.dart';
import 'package:safe_track/state/sos_provider.dart';
import '../../state/sos_history_provider.dart';

// --- 1. New Wrapper for Global Shake Detection ---
class GlobalShakeHandler extends StatefulWidget {
  final Widget child;
  const GlobalShakeHandler({super.key, required this.child});

  @override
  State<GlobalShakeHandler> createState() => _GlobalShakeHandlerState();
}

class _GlobalShakeHandlerState extends State<GlobalShakeHandler> {
  late ShakeServices _shakeServices;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _shakeServices = ShakeServices();
  }

  @override
  void dispose() {
    _shakeServices.stopShakeListening();
    super.dispose();
  }

  void _handleShakeService(bool shouldListen) {
    if (shouldListen && !_isListening) {
      setState(() => _isListening = true);
      _shakeServices.startShakeListening(() async {
        await context.read<SosProvider>().triggerSos(
          context,
          trigger: 'shake',
        );
      });
    } else if (!shouldListen && _isListening) {
      setState(() => _isListening = false);
      _shakeServices.stopShakeListening();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to the provider to know if Shake is enabled/disabled
    final isShakeEnabled = context.select<HomeProvider, bool>(
          (provider) => provider.getShakeValue(),
    );

    // Manage service state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleShakeService(isShakeEnabled);
    });

    return widget.child;
  }
}

// --- 2. Refactored Home Screen ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Premium Color Palette
  static const primaryColor = Color(0xFF6366F1); // Indigo
  static const accentColor = Color(0xFF8B5CF6); // Purple
  static const textPrimaryColor = Color(0xFF1E293B); // Dark slate
  static const textSecondaryColor = Color(0xFF64748B); // Slate gray

  @override
  Widget build(BuildContext context) {
    // Wrap Scaffold with GlobalShakeHandler to keep logic alive on all screens
    return GlobalShakeHandler(
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Stack(
          children: [
            // Ambient background effects
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
                      primaryColor.withOpacity(0.06),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Main content
            SafeArea(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Custom AppBar
                  const SliverToBoxAdapter(
                    child: TopBar(),
                  ),
                  // Content
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: 24),
                        const Sos(),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  print("Clicked Safe Navigate..");
                                },
                                child: const SafeRoutes(),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  print("Clicked Share Location......");
                                },
                                child: const ShareLocation(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const ShakeDetection(),
                        const SizedBox(height: 20),
                        const RecentActivities(),
                        const SizedBox(height: 20),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.shield_rounded,
                label: "Home",
                isActive: true,
                onTap: () {},
              ),
              _buildNavItem(
                icon: Icons.map_outlined,
                label: "Map",
                isActive: false,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? primaryColor : textSecondaryColor,
              size: 24,
            ),
            if (isActive) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  static const primaryColor = Color(0xFF6366F1);
  static const textPrimaryColor = Color(0xFF1E293B);
  static const textSecondaryColor = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer<ProfileProvider>(
                  builder: (_, prd, __) {
                    final name = prd.nameController.text.split(' ').first;
                    return Text(
                      "Hi, $name! 👋",
                      style: const TextStyle(
                        color: textPrimaryColor,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                const Text(
                  "Stay safe, stay connected",
                  style: TextStyle(
                    color: textSecondaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withOpacity(0.1),
                  const Color(0xFF8B5CF6).withOpacity(0.08),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: primaryColor.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
              icon: const Icon(
                Icons.settings_outlined,
                color: primaryColor,
                size: 24,
              ),
              tooltip: "Settings",
            ),
          ),
        ],
      ),
    );
  }
}

class Sos extends StatelessWidget {
  const Sos({super.key});

  static const primaryColor = Color(0xFF6366F1);
  static const textSecondaryColor = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF4444).withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF16A34A),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  "System Active",
                  style: TextStyle(
                    color: Color(0xFF15803D),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // SOS Button
          Consumer<SosProvider>(
            builder: (ctx, provider, child) {
              return GestureDetector(
                onTap: provider.isSending
                    ? null
                    : () async {
                  debugPrint("SOS clicked");

                  bool? result = await provider.triggerSos(ctx);

                  if (!ctx.mounted) return;

                  if (result == null) return;

                  if (result == true) {
                    _showSnackBar(
                      ctx,
                      "Emergency alert sent successfully",
                      isError: false,
                    );
                  } else {
                    _showSnackBar(
                      ctx,
                      "Failed to send emergency alert",
                      isError: true,
                    );
                  }
                },
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: provider.isSending
                        ? LinearGradient(
                      colors: [
                        Colors.grey.shade300,
                        Colors.grey.shade400,
                      ],
                    )
                        : const LinearGradient(
                      colors: [
                        Color(0xFFEF4444), // Red
                        Color(0xFFDC2626), // Darker red
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: provider.isSending
                        ? []
                        : [
                      BoxShadow(
                        color: const Color(0xFFEF4444).withOpacity(0.4),
                        blurRadius: 40,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: provider.isSending
                      ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.crisis_alert_rounded,
                        color: Colors.white,
                        size: 80,
                      ),
                      SizedBox(height: 12),
                      Text(
                        "SOS",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          const Text(
            "Tap to send emergency alert",
            style: TextStyle(
              color: textSecondaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

class SafeRoutes extends StatelessWidget {
  const SafeRoutes({super.key});

  static const primaryColor = Color(0xFF6366F1);
  static const textPrimaryColor = Color(0xFF1E293B);
  static const textSecondaryColor = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withOpacity(0.15),
                  primaryColor.withOpacity(0.08),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.map_outlined,
                color: primaryColor,
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Safe Routes",
            style: TextStyle(
              color: textPrimaryColor,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Navigate safely",
            style: TextStyle(
              color: textSecondaryColor,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class ShareLocation extends StatelessWidget {
  const ShareLocation({super.key});

  static const textPrimaryColor = Color(0xFF1E293B);
  static const textSecondaryColor = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF10B981).withOpacity(0.15),
                  const Color(0xFF10B981).withOpacity(0.08),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.my_location_rounded,
                color: Color(0xFF10B981),
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Share Location",
            style: TextStyle(
              color: textPrimaryColor,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Live tracking",
            style: TextStyle(
              color: textSecondaryColor,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class ShakeDetection extends StatelessWidget {
  const ShakeDetection({super.key});

  static const primaryColor = Color(0xFF6366F1);
  static const accentColor = Color(0xFF8B5CF6);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            primaryColor,
            accentColor,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.vibration_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Shake Detection",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Shake phone to trigger SOS",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.9,
            child: Switch(
              value: context.watch<HomeProvider>().getShakeValue(),
              activeColor: const Color(0xFF10B981),
              activeTrackColor: Colors.white,
              inactiveThumbColor: Colors.white70,
              inactiveTrackColor: Colors.white.withOpacity(0.3),
              onChanged: (value) {
                // Just update provider. The GlobalShakeHandler will react automatically.
                context.read<HomeProvider>().updateShake(value);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class RecentActivities extends StatelessWidget {
  const RecentActivities({super.key});

  static const primaryColor = Color(0xFF6366F1);
  static const textPrimaryColor = Color(0xFF1E293B);
  static const textSecondaryColor = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Consumer<SosHistoryProvider>(
      builder: (_, historyProvider, __) {
        final list = historyProvider.history;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- CHANGED SECTION FOR OVERFLOW FIX ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Wrapped in Expanded to prevent pushing the button off
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.history_rounded,
                            size: 20,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Wrapped in Flexible to handle small screens
                        const Flexible(
                          child: Text(
                            "Recent Activity",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: textPrimaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (list.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AlertHistoryScreen(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      child: Row(
                        children: const [
                          Text(
                            "View All",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: primaryColor,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              // --- END CHANGED SECTION ---

              const SizedBox(height: 16),

              if (list.isEmpty)
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.history_toggle_off_rounded,
                            size: 48,
                            color: textSecondaryColor.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "No alerts yet",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textSecondaryColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Your emergency activity will appear here",
                          style: TextStyle(
                            fontSize: 13,
                            color: textSecondaryColor.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              ...list.take(3).map(
                    (item) => ActivityHistoryCard(
                  success: item.success,
                  trigger: item.trigger,
                  time: item.time,
                  location: item.address,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ActivityHistoryCard extends StatelessWidget {
  final bool success;
  final String trigger;
  final DateTime time;
  final String location;

  static const textPrimaryColor = Color(0xFF1E293B);
  static const textSecondaryColor = Color(0xFF64748B);

  const ActivityHistoryCard({
    super.key,
    required this.success,
    required this.trigger,
    required this.time,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: success
                  ? const Color(0xFFDCFCE7)
                  : const Color(0xFFFEE2E2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              success ? Icons.check_circle_rounded : Icons.error_rounded,
              color: success
                  ? const Color(0xFF16A34A)
                  : const Color(0xFFEF4444),
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trigger == 'shake' ? 'Shake Detection' : 'Manual SOS',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: textSecondaryColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatTime(time),
                      style: const TextStyle(
                        fontSize: 12,
                        color: textSecondaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 14,
                      color: textSecondaryColor,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        location,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: textSecondaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return "${hour == 0 ? 12 : hour}:${time.minute.toString().padLeft(2, '0')} $period • "
        "${time.day}/${time.month}/${time.year}";
  }
}