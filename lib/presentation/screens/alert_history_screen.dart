import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/map_service.dart';
import '../../state/sos_history_provider.dart';
import '../model/sos_history.dart';

class AlertHistoryScreen extends StatelessWidget {
  const AlertHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final historyProvider = context.watch<SosHistoryProvider>();
    final history = historyProvider.history;

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
              // Header
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Alert History',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          'Your safety timeline',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Alert List
              Expanded(
                child: history.isEmpty
                    ? _EmptyHistory()
                    : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    return ActivityHistoryCard(
                      history: history[index],
                    );
                  },
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

class ActivityHistoryCard extends StatelessWidget {
  final SosHistory history;
  final MapService _mapService = MapService();

  ActivityHistoryCard({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    final bool success = history.success;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: success
                  ? const Color(0xFFDCFCE7)
                  : const Color(0xFFFEE2E2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.warning_rounded,
              size: 24,
              color: success
                  ? const Color(0xFF16A34A)
                  : const Color(0xFFEF4444),
            ),
          ),
          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      history.trigger == 'shake'
                          ? 'Shake Detection'
                          : 'Manual SOS',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: success
                            ? const Color(0xFFDCFCE7)
                            : const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        success ? 'Sent' : 'Failed',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: success
                              ? const Color(0xFF15803D)
                              : const Color(0xFFB91C1C),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Time
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 16,
                      color: Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatTime(history.time),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Location
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_pin,
                      size: 16,
                      color: Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        history.address,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                GestureDetector(
                  onTap: () async {
                    // TODO: open maps later
                    final url = history.locationText;
                    await _mapService.openMap(url);
                  },
                  child: const Text(
                    'View on Map →',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF9333EA),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return "${time.hour}:${time.minute.toString().padLeft(2, '0')} • "
        "${time.day}/${time.month}/${time.year}";
  }
}

class _EmptyHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.history, size: 64, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            "No alerts yet",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 6),
          Text(
            "Your SOS activity will appear here",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
