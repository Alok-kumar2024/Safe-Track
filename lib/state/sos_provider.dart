import 'package:flutter/widgets.dart';
import 'package:safe_track/services/location_service.dart';
import 'package:safe_track/services/sms_service.dart';

class SosProvider extends ChangeNotifier {
  bool _sending = false;

  bool get isSending => _sending;

  final LocationService _locationService = LocationService();
  final SmsService _smsService = SmsService();

  Future<void> triggerSos() async {
    if(_sending) return;
  }
}
