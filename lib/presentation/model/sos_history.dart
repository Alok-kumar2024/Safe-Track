class SosHistory {
  final DateTime time;
  final String locationText;
  final bool success;
  final String trigger; // "button" or "shake"

  SosHistory({
    required this.time,
    required this.locationText,
    required this.success,
    required this.trigger,
  });

  Map<String, dynamic> toMap() {
    return {
      'time': time.toIso8601String(),
      'locationText': locationText,
      'success': success,
      'trigger': trigger,
    };
  }

  factory SosHistory.fromMap(Map<String, dynamic> map) {
    return SosHistory(
      time: DateTime.parse(map['time']),
      locationText: map['locationText'],
      success: map['success'],
      trigger: map['trigger'],
    );
  }
}
