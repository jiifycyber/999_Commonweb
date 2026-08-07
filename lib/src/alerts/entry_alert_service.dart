import 'package:flutter/foundation.dart';

enum EntryAlertLevel { none, wait, armed, enterNow, expired }

class EntryAlert {
  final String symbol;
  final EntryAlertLevel level;
  final String message;
  final DateTime time;

  const EntryAlert({
    required this.symbol,
    required this.level,
    required this.message,
    required this.time,
  });
}

class EntryAlertService extends ChangeNotifier {
  EntryAlert? latest;

  void publish({
    required String symbol,
    required EntryAlertLevel level,
    required String message,
  }) {
    latest = EntryAlert(
      symbol: symbol,
      level: level,
      message: message,
      time: DateTime.now(),
    );
    notifyListeners();
  }

  void clear() {
    latest = null;
    notifyListeners();
  }
}
