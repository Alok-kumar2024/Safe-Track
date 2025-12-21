import 'package:url_launcher/url_launcher.dart';

class MapService {
  Future<void> openMap(String locationText) async {
    if (!locationText.startsWith('http')) return;

    final uri = Uri.parse(locationText);

    if (!await canLaunchUrl(uri)) return;

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }
}
