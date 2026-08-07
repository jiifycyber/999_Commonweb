enum DemoTradeSide { call, put }

class DemoPosition {
  final String id;
  final String symbol;
  final DemoTradeSide side;
  final double amount;
  final double entryPrice;
  final DateTime openedAt;
  final DateTime expiresAt;
  final bool? won;

  const DemoPosition({
    required this.id,
    required this.symbol,
    required this.side,
    required this.amount,
    required this.entryPrice,
    required this.openedAt,
    required this.expiresAt,
    this.won,
  });
}
