import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:safe_track/presentation/model/sos_history.dart';
import 'package:safe_track/services/location_service.dart';
import 'package:safe_track/services/sms_service.dart';
import 'package:safe_track/services/sos_feedback_service.dart';
import 'package:safe_track/state/home_provider.dart';
import 'package:safe_track/state/profile_provider.dart';
import 'package:safe_track/state/sos_history_provider.dart';
import '../services/emergency_call_service.dart';

class SosProvider extends ChangeNotifier {
  bool _sending = false;

  bool get isSending => _sending;

  final LocationService _locationService = LocationService();
  final SmsService _smsService = SmsService();
  final SosFeedBackService _feedbackService = SosFeedBackService();

  Future<bool?> triggerSos(
      BuildContext context, {
        String trigger = 'button',
      }) async {
    /// 1️⃣ Prevent double trigger
    if (_sending) return null;
    _sending = true;
    notifyListeners();

    final homeProvider = context.read<HomeProvider>();
    final profileProvider = context.read<ProfileProvider>();

    /// 2️⃣ Instant feedback (vibration)
    await _feedbackService.vibrate();

    bool success = false;
    String locationMessage =
        'Location not available (GPS disabled or permission denied)';
    String address = 'Unknown location';

    try {
      /// 3️⃣ Get SOS data
      final smsContacts = profileProvider.getEmergencyNumbers();
      final callNumber = profileProvider.emergencyCallNumber;

      /// ❌ Nothing configured → STOP
      if (smsContacts.isEmpty &&
          (callNumber == null || callNumber.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "No emergency contacts or call number set. Please configure SOS settings.",
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );

        success = false;
        return false;
      }

      /// 4️⃣ Try to get location (safe)
      try {
        final position = await _locationService.getCurrentLocation();

        locationMessage = _locationService.getGoogleMapsLink(
          position.latitude,
          position.longitude,
        );

        address = await _locationService.getAddressFromPosition(position);
      } catch (e) {
        debugPrint('Location failed: $e');
      }

      /// 5️⃣ Compose SOS message
      final sosMessage =
          '🚨 EMERGENCY ALERT 🚨\n\n'
          'I am in danger and need help immediately.\n\n'
          '📍 Location:\n$address\n\n'
          '🗺️ Live Location:\n$locationMessage';

      /// 6️⃣ Send SMS (ONLY if contacts exist)
      if (smsContacts.isNotEmpty) {
        await _smsService.sendSms(
          recipients: smsContacts,
          message: sosMessage,
        );
      }

      /// 7️⃣ Play siren (only if enabled)
      if (homeProvider.isSosSoundEnabled) {
        await _feedbackService.playAlertSound();
      }

      /// 8️⃣ Make emergency call (ONLY if number exists)
      if (callNumber != null && callNumber.isNotEmpty) {
        final callService = EmergencyCallService();
        await callService.call(callNumber);
      }

      success = true;
      return true;
    } catch (e) {
      debugPrint('SOS failed: $e');
      success = false;
      return false;
    } finally {
      /// 9️⃣ Save SOS history (always)
      if (context.mounted) {
        final historyProvider = context.read<SosHistoryProvider>();

        await historyProvider.addHistory(
          SosHistory(
            time: DateTime.now(),
            locationText: locationMessage,
            address: address,
            success: success,
            trigger: trigger,
          ),
        );
      }

      _sending = false;
      notifyListeners();
    }
  }
}
