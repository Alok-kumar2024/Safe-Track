import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../state/home_provider.dart';
import '../../state/sos_history_provider.dart';
import '../screens/login_screen.dart';

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
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF6B7280),
                      ),
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
                      // SETTINGS CARD
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // SHAKE DETECTION TOGGLE
                            Consumer<HomeProvider>(
                              builder: (_, home, __) {
                                return SwitchListTile(
                                  title: const Text(
                                    'Shake Detection',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: const Text(
                                    'Trigger SOS by shaking phone',
                                  ),
                                  value: home.getShakeValue(),
                                  onChanged: home.updateShake,
                                );
                              },
                            ),
                            _divider(),

                            // SOS SOUND TOGGLE
                            Consumer<HomeProvider>(
                              builder: (_, home, __) {
                                return SwitchListTile(
                                  title: const Text(
                                    'SOS Alert Sound',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: const Text(
                                    'Play siren sound during SOS',
                                  ),
                                  value: home.isSosSoundEnabled,
                                  onChanged: home.updateSosSound,
                                );
                              },
                            ),
                            _divider(),

                            // CLEAR HISTORY
                            _settingItem(
                              icon: Icons.delete_outline,
                              iconBg: const Color(0xFFFEE2E2),
                              iconColor: const Color(0xFFDC2626),
                              title: 'Clear Alert History',
                              onTap: () => _confirmClearHistory(context),
                            ),
                            _divider(),

                            // LOGOUT
                            _settingItem(
                              icon: Icons.logout,
                              iconBg: const Color(0xFFE0E7FF),
                              iconColor: const Color(0xFF4338CA),
                              title: 'Logout',
                              showDivider: false,
                              onTap: () async {
                                final historyProvider = context.read<SosHistoryProvider>();
                                await historyProvider.clearHistory();
                                context.read<HomeProvider>().reset();

                                await FirebaseAuth.instance.signOut();

                                if (!context.mounted) return;

                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => LoginScreen(),
                                  ),
                                  (_) => false,
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // APP INFO
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: const [
                            Icon(
                              Icons.shield,
                              size: 48,
                              color: Color(0xFF9333EA),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'SafeGuard v1.0.0',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Your safety companion',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
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

  static Widget _divider() {
    return Container(height: 1, color: Color(0xFFF3F4F6));
  }

  static Widget _settingItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    bool showDivider = true,
    required VoidCallback onTap,
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
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }

  static Future<void> _confirmClearHistory(BuildContext context) async {
    final historyProvider = context.read<SosHistoryProvider>();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('This will permanently delete all SOS records.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await historyProvider.clearHistory();
              if (context.mounted){
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Alert history cleared")),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
