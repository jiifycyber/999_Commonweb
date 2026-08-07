import '../alerts/entry_alert_service.dart';
import '../engines/fusion_controller.dart';
import '../watchlist/watchlist_controller.dart';
import '../trading/demo_trade_controller.dart';

class InfinityServiceRegistry {
  final InfinityFusionController fusion = const InfinityFusionController();
  final EntryAlertService alerts = EntryAlertService();
  final WatchlistController watchlist = WatchlistController();
  final DemoTradeController demoTrading = DemoTradeController();

  InfinityServiceRegistry();
}
