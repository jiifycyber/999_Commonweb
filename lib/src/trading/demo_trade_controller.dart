import 'package:flutter/foundation.dart';
import 'demo_trade_models.dart';

class DemoTradeController extends ChangeNotifier {
  double balance = 10000;
  final List<DemoPosition> positions = [];

  void open({
    required String symbol,
    required DemoTradeSide side,
    required double amount,
    required double entryPrice,
    required Duration duration,
  }) {
    if (amount <= 0 || amount > balance) return;
    balance -= amount;
    final now = DateTime.now();
    positions.insert(
      0,
      DemoPosition(
        id: now.microsecondsSinceEpoch.toString(),
        symbol: symbol,
        side: side,
        amount: amount,
        entryPrice: entryPrice,
        openedAt: now,
        expiresAt: now.add(duration),
      ),
    );
    notifyListeners();
  }
}
