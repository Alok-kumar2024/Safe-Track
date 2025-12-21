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

class SosProvider extends ChangeNotifier {
  bool _sending = false;

  bool get isSending => _sending;

  final LocationService _locationService = LocationService();
  final SmsService _smsService = SmsService();
  final SosFeedBackService _feedbackService = SosFeedBackService();

  Future<bool?> triggerSos(BuildContext context,
  {String trigger ='button'}) async {
    if (_sending) return null;
    _sending = true;
    notifyListeners();

    final homeProvider = context.read<HomeProvider>();
    await _feedbackService.vibrate();

    if(homeProvider.isSosSoundEnabled)
      {
        await _feedbackService.playAlertSound();
      }

    bool success = false;

    String locationMessage = 'Location not available (GPS disabled or denied)';

    try {
      //Fetching Emergency contacts stored in Hive from profile provider....
      final profileProvider = context.read<ProfileProvider>();
      final contacts = profileProvider.getEmergencyNumbers();

      if (contacts.isEmpty) {
        debugPrint('No contacts found');
        return false; // Fail early if no contacts
      }

      try {
        // Attempt to get location
        final position = await _locationService.getCurrentLocation();

        // If successful, overwrite the default message with the link
        final String link = _locationService.getGoogleMapsLink(
            position.latitude,
            position.longitude
        );
        locationMessage = link;

      } catch (e) {
        // ❌ GPS FAILED: We catch the error here and do NOT stop the function.
        // We just print it for debugging, but the code continues to the SMS part.
        debugPrint('Location failed: $e');
      }

      //This is SOS Message..
      final sosMessage =
          '🚨 EMERGENCY ALERT 🚨\n\n'
          'I am in danger and need help immediately.\n\n'
          'My current location:\n$locationMessage';

      await _smsService.sendSms(
          recipients: contacts,
          message: sosMessage
      );

      success = true;
      return true;

    } catch (e) {
      success = false;
      debugPrint('SOS failed: $e');
      return false;
    }finally{

      final historyProvider = context.read<SosHistoryProvider>();

      await historyProvider.addHistory(SosHistory(
        time: DateTime.now(),
        locationText: locationMessage,
        success: success,
        trigger: trigger
      ));

      _sending = false;
      notifyListeners();
    }
  }
}
