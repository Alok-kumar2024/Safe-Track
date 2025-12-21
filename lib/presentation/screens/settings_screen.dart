import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../state/home_provider.dart';
import '../../state/sos_history_provider.dart';
import '../screens/login_screen.dart';
import '../screens/emergency_contact_screen.dart';
import 'package:permission_handler/permission_handler.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFAF5FF), Color(0xFFFDF2F8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // HEADER
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back,
                          color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              ),

              // CONTENT
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _settingsCard(context),
                      const SizedBox(height: 24),
                      _appInfoCard(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= SETTINGS CARD =================

  Widget _settingsCard(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        children: [
          // Shake Detection
          // Consumer<HomeProvider>(
          //   builder: (_, home, __) {
          //     return SwitchListTile(
          //       title: const Text('Shake Detection'),
          //       subtitle: const Text('Trigger SOS by shaking phone'),
          //       value: home.getShakeValue(),
          //       onChanged: home.updateShake,
          //     );
          //   },
          // ),
          // _divider(),

          // SOS Sound
          Consumer<HomeProvider>(
            builder: (_, home, __) {
              return SwitchListTile(
                title: const Text('SOS Alert Sound'),
                subtitle: const Text('Play siren during SOS'),
                value: home.isSosSoundEnabled,
                onChanged: home.updateSosSound,
              );
            },
          ),
          _divider(),

          // Emergency Contacts
          _settingItem(
            icon: Icons.people,
            iconBg: const Color(0xFFF3E8FF),
            iconColor: const Color(0xFF9333EA),
            title: 'Emergency Contacts',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EmergencyContactsScreen(),
                ),
              );
            },
          ),
          _divider(),

          // Permissions
          _settingItem(
            icon: Icons.security,
            iconBg: const Color(0xFFE0F2FE),
            iconColor: const Color(0xFF0284C7),
            title: 'Permissions',
            onTap: () => openAppSettings(),
          ),
          _divider(),

          // Clear History
          _settingItem(
            icon: Icons.delete_outline,
            iconBg: const Color(0xFFFEE2E2),
            iconColor: const Color(0xFFDC2626),
            title: 'Clear Alert History',
            onTap: () => _confirmClearHistory(context),
          ),
          _divider(),

          // Privacy Policy
          _settingItem(
            icon: Icons.privacy_tip,
            iconBg: const Color(0xFFFED7AA),
            iconColor: const Color(0xFFF97316),
            title: 'Privacy Policy',
            onTap: () => _openLink(
              'https://your-privacy-policy-link.com',
            ),
          ),
          _divider(),

          // Terms
          _settingItem(
            icon: Icons.description,
            iconBg: const Color(0xFFDCFCE7),
            iconColor: const Color(0xFF16A34A),
            title: 'Terms & Conditions',
            onTap: () => _openLink(
              'https://your-terms-link.com',
            ),
          ),
          _divider(),

          // Logout
          _settingItem(
            icon: Icons.logout,
            iconBg: const Color(0xFFE0E7FF),
            iconColor: const Color(0xFF4338CA),
            title: 'Logout',
            showDivider: false,
            onTap: () => _confirmLogout(context),
          ),
        ],
      ),
    );
  }

  // ================= APP INFO =================

  Widget _appInfoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        children: const [
          Icon(Icons.shield, size: 48, color: Color(0xFF9333EA)),
          SizedBox(height: 12),
          Text(
            'SafeGuard v1.0.0',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            'Your safety companion',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // ================= HELPERS =================

  static BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static Widget _divider() {
    return const Divider(height: 1, color: Color(0xFFF3F4F6));
  }

  static Widget _settingItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title,
                  style: const TextStyle(fontWeight: FontWeight.w500)),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }

  // ================= ACTIONS =================

  static Future<void> _confirmClearHistory(BuildContext context) async {
    final history = context.read<SosHistoryProvider>();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Delete all SOS records permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await history.clearHistory();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('History cleared')),
              );
            },
            child:
            const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  static Future<void> _confirmLogout(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              context.read<HomeProvider>().reset();
              await context.read<SosHistoryProvider>().clearHistory();
              await FirebaseAuth.instance.signOut();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (_) => false,
              );
            },
            child:
            const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  static Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
