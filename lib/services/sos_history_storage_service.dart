import 'package:hive/hive.dart';
import 'package:safe_track/presentation/model/sos_history.dart';

class SosHistoryService {
  static const String _boxname = 'sosHistoryBox';

  Future<Box> _openBox() async{
    return await Hive.openBox(_boxname);
  }

  Future<void> addHistory(SosHistory history) async{
    final box = await _openBox();
    await box.add(history.toMap());
  }

  Future<List<SosHistory>> getHistory() async {
    final box = await _openBox();

    return box.values
        .map((e) => SosHistory.fromMap(Map<String, dynamic>.from(e)))
        .toList()
        .reversed
        .toList();
  }

  Future<void> clearHistory() async {
    final box = await _openBox();
    await box.clear();
  }

}