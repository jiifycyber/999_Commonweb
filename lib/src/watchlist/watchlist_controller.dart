import 'package:flutter/foundation.dart';

class WatchlistController extends ChangeNotifier {
  final Set<String> favorites = {
    'EUR/USD',
    'GBP/USD',
    'XAU/USD',
    'BTC/USD',
  };

  bool contains(String symbol) => favorites.contains(symbol);

  void toggle(String symbol) {
    if (!favorites.add(symbol)) {
      favorites.remove(symbol);
    }
    notifyListeners();
  }
}
