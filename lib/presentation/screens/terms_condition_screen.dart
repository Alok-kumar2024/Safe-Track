import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatefulWidget {
  const TermsConditionsScreen({super.key});

  @override
  State<TermsConditionsScreen> createState() => _TermsConditionsScreenState();
}

class _TermsConditionsScreenState extends State<TermsConditionsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
                  _buildHeader(context),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      child: FadeTransition(
                        opacity: _animationController,
                        child: Column(
                          children: [
                            _buildIntroCard(),
                            const SizedBox(height: 20),
                            _buildSection(
                              title: 'Purpose of App',
                              icon: Icons.track_changes_rounded,
                              content: const Text(
                                'SafeTrack assists users during emergencies by sending SOS alerts and sharing live location. It is a tool for safety but does not replace police, ambulance, or other official emergency services.',
                                style: TextStyle(
                                  color: textSecondaryColor,
                                  height: 1.5,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            _buildSection(
                              title: 'User Responsibilities',
                              icon: Icons.person_outline_rounded,
                              content: _buildBulletList([
                                'Provide accurate personal information',
                                'Use SOS features responsibly',
                                'Avoid misuse or false alerts',
                                'Maintain active emergency contacts',
                              ]),
                            ),
                            _buildSection(
                              title: 'Limitations & Liability',
                              icon: Icons.warning_amber_rounded,
                              isWarning: true,
                              content: _buildBulletList([
                                'SafeTrack is not liable for failures due to network issues.',
                                'Device battery or GPS limitations may affect accuracy.',
                                'We are not responsible for incorrect contact details.',
                              ]),
                            ),
                            _buildSection(
                              title: 'Account Termination',
                              icon: Icons.block_flipped,
                              content: const Text(
                                'We reserve the right to suspend or terminate access to the application immediately if we detect any misuse, false reporting, or violation of these terms.',
                                style: TextStyle(
                                  color: textSecondaryColor,
                                  height: 1.5,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            _buildSection(
                              title: 'Governing Law',
                              icon: Icons.gavel_rounded,
                              content: const Text(
                                'These terms shall be governed by and construed in accordance with the laws of India.',
                                style: TextStyle(
                                  color: textSecondaryColor,
                                  height: 1.5,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            _buildFooter(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: textPrimaryColor,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Terms & Conditions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: textPrimaryColor,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Usage guidelines',
                  style: TextStyle(
                    fontSize: 13,
                    color: textSecondaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primaryColor, accentColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.gavel_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Agreement',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'By using SafeTrack, you agree to these terms. Please read them carefully to understand your rights and obligations.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget content,
    bool isWarning = false,
  }) {
    final color = isWarning ? const Color(0xFFEF4444) : primaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isWarning
              ? const Color(0xFFFECACA)
              : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isWarning ? color : textPrimaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _buildBulletList(List<String> items) {
    return Column(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item,
                  style: const TextStyle(
                    fontSize: 14,
                    color: textSecondaryColor,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Icon(
          Icons.handshake_rounded,
          size: 32,
          color: textSecondaryColor.withOpacity(0.3),
        ),
        const SizedBox(height: 8),
        Text(
          'Last Updated: Dec 2024',
          style: TextStyle(
            fontSize: 12,
            color: textSecondaryColor.withOpacity(0.6),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}