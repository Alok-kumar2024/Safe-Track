import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../services/permission_service.dart';
import 'home_screen.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  final service = PermissionService();

  PermissionStatus? location;
  PermissionStatus? sms;
  PermissionStatus? call;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    location = await service.locationStatus();
    sms = await service.smsStatus();
    call = await service.callStatus();
    if (mounted) setState(() {});
  }

  // Widget _statusChip(PermissionStatus? status) {
  //   if (status == PermissionStatus.granted) {
  //     return const Chip(label: Text("Granted"), backgroundColor: Colors.green);
  //   }
  //   if (status == PermissionStatus.permanentlyDenied) {
  //     return const Chip(label: Text("Denied"), backgroundColor: Colors.red);
  //   }
  //   return const Chip(label: Text("Not allowed"));
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Permissions Required",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "These permissions are mandatory for SOS to work.",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),

              _PermissionTile(
                icon: Icons.location_on,
                title: "Location",
                subtitle: "Share your location during SOS",
                status: location,
                onTap: () async {
                  await service.requestLocation();
                  _loadStatus();
                },
              ),

              _PermissionTile(
                icon: Icons.sms,
                title: "SMS",
                subtitle: "Send alerts to emergency contacts",
                status: sms,
                onTap: () async {
                  await service.requestSms();
                  _loadStatus();
                },
              ),

              _PermissionTile(
                icon: Icons.call,
                title: "Phone Call",
                subtitle: "Call emergency numbers",
                status: call,
                onTap: () async {
                  await service.requestCall();
                  _loadStatus();
                },
              ),

              const Spacer(),

              if ([location, sms, call]
                  .any((s) => s == PermissionStatus.permanentlyDenied))
                TextButton(
                  onPressed: service.openSettings,
                  child: const Text("Open App Settings"),
                ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (location == PermissionStatus.granted &&
                      sms == PermissionStatus.granted
                      && call == PermissionStatus.granted
                  )
                      ? () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => HomeScreen()),
                    );
                  }
                      : null,
                  child: const Text("Continue"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _PermissionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final PermissionStatus? status;
  final VoidCallback onTap;

  const _PermissionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: status == PermissionStatus.granted
            ? const Icon(Icons.check_circle, color: Colors.green)
            : TextButton(onPressed: onTap, child: const Text("Allow")),
      ),
    );
  }
}
