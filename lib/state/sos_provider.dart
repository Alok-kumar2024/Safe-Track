import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:safe_track/presentation/model/sos_history.dart';
import 'package:safe_track/services/location_service.dart';
import 'package:safe_track/services/sms_service.dart';
import 'package:safe_track/services/sos_feedback_service.dart';
import 'package:safe_track/services/sos_history_storage_service.dart';
import 'package:safe_track/state/home_provider.dart';
import 'package:safe_track/state/profile_provider.dart';
import 'package:safe_track/state/sos_history_provider.dart';

import '../presentation/model/emergency_contact.dart';

class SosProvider extends ChangeNotifier {
  bool _sending = false;

  bool get isSending => _sending;

  final LocationService _locationService = LocationService();
  final SmsService _smsService = SmsService();
  final SosFeedBackService _feedbackService = SosFeedBackService();

  Future<bool?> triggerSos(BuildContext context,
      {String trigger = 'button'}) async {
    // 1. Prevent double triggers
    if (_sending) return null;
    _sending = true;
    notifyListeners();

    final homeProvider = context.read<HomeProvider>();

    // 2. Immediate Haptic Feedback (Vibration)
    // Confirms "Button Pressed" immediately to the user
    await _feedbackService.vibrate();

    bool success = false;
    String locationMessage = 'Location not available (GPS disabled or denied)';
    String address = 'Unknown location';

    try {
      // 3. Get Contacts
      final profileProvider = context.read<ProfileProvider>();
      final contacts = profileProvider.getEmergencyNumbers();

      if (contacts.isEmpty) {
        debugPrint('No contacts found');
        return false;
      }

      // 4. Get Location (Safe block)
      try {
        final position = await _locationService.getCurrentLocation();

        final String link = _locationService.getGoogleMapsLink(
            position.latitude,
            position.longitude
        );
        locationMessage = link;

        address = await _locationService.getAddressFromPosition(position);

      } catch (e) {
        // Location failed, but we continue with SMS
        debugPrint('Location failed: $e');
      }

      // 5. Prepare Message
      final sosMessage =
          '🚨 EMERGENCY ALERT 🚨\n\n'
          'I am in danger and need help immediately.\n\n'
          '📍 Location:\n$address\n\n'
          'My current location:\n$locationMessage';

      // 6. Send SMS
      await _smsService.sendSms(
          recipients: contacts,
          message: sosMessage
      );

      // 7. Play Sound ONLY on success
      // Moved here so it confirms the action worked.
      if(homeProvider.isSosSoundEnabled) {
        await _feedbackService.playAlertSound();
      }

      success = true;
      return true;

    } catch (e) {
      success = false;
      debugPrint('SOS failed: $e');
      return false;
    } finally {

      // 8. Save History
      // Added mounted check to be safe
      if (context.mounted) {
        final historyProvider = context.read<SosHistoryProvider>();

        await historyProvider.addHistory(SosHistory(
            time: DateTime.now(),
            locationText: locationMessage,
            address: address,
            success: success,
            trigger: trigger
        ));
      }

      _sending = false;
      notifyListeners();
    }
  }
}