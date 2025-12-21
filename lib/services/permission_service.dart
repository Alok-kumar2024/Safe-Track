import 'package:permission_handler/permission_handler.dart';

class PermissionService {

  Future<PermissionStatus> locationStatus() =>
      Permission.location.status;

  Future<PermissionStatus> smsStatus() =>
      Permission.sms.status;

  Future<PermissionStatus> callStatus() =>
      Permission.phone.status;

  Future<bool> requestLocation() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  Future<bool> requestSms() async {
    final status = await Permission.sms.request();
    return status.isGranted;
  }

  Future<bool> requestCall() async {
    final status = await Permission.phone.request();
    return status.isGranted;
  }

  Future<bool> allGranted() async {
    return await Permission.location.isGranted &&
        await Permission.sms.isGranted &&
        await Permission.phone.isGranted;
  }

  Future<void> openSettings() async {
    await openAppSettings();
  }
}
