import 'package:url_launcher/url_launcher.dart';

class SmsService {


  Future<void> sendSms({
    required List<String> recipients,
    required String message,
  }) async {
    if (recipients.isEmpty) {
      throw Exception('No emergency contacts found');
    }

    final numbers = recipients.join(',');
    final uri = Uri.parse('sms:$numbers?body=${Uri.encodeComponent(message)}');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw Exception('Could not open SMS app');
    }
  }
}
