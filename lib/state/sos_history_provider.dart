import 'package:flutter/foundation.dart';
import 'package:safe_track/presentation/model/sos_history.dart';
import 'package:safe_track/services/sos_history_storage_service.dart';

class SosHistoryProvider extends ChangeNotifier{

  final SosHistoryService _service = SosHistoryService();

  List<SosHistory> _history =[];
  bool _loaded = false;

  List<SosHistory> get history => _history;

  Future<void> loadHistory() async{
    if(_loaded) return;

    _history = await _service.getHistory();
    _loaded = true;
    notifyListeners();
  }

  Future<void> addHistory(SosHistory history) async {
    await _service.addHistory(history);
    _history.insert(0, history); // newest first
    notifyListeners();
  }

  Future<void> clearHistory() async{
    await _service.clearHistory();
    _history.clear();
    notifyListeners();
  }

}