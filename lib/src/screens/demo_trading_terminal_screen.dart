import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/tradex_widgets.dart';

class DemoTradingTerminalScreen extends StatefulWidget {
  const DemoTradingTerminalScreen({super.key});

  @override
  State<DemoTradingTerminalScreen> createState() =>
      _DemoTradingTerminalScreenState();
}

class _DemoTradingTerminalScreenState extends State<DemoTradingTerminalScreen> {
  double amount = 25;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<TradeXAppState>();
    final market = app.market;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        XGlassPanel(
          padding: const EdgeInsets.all(18),
          glowColor: TradeXColors.cyan,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('DEMO TRADING TERMINAL',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              Text(app.selectedSymbol,
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.w900)),
              Text(
                market == null
                    ? 'Waiting for market data'
                    : 'Price ${market.price}',
                style: const TextStyle(color: TradeXColors.muted),
              ),
              const SizedBox(height: 16),
              Text('Amount \$${amount.toStringAsFixed(0)}'),
              Slider(
                value: amount,
                min: 5,
                max: 500,
                divisions: 99,
                onChanged: (v) => setState(() => amount = v),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: app.canTrade ? app.approveSignal : null,
                      icon: const Icon(Icons.arrow_upward_rounded),
                      label: const Text('CALL / BUY'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: app.canTrade ? app.approveSignal : null,
                      icon: const Icon(Icons.arrow_downward_rounded),
                      label: const Text('PUT / SELL'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                app.entryStatus,
                style: const TextStyle(
                  color: TradeXColors.cyan,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Text('Recent Demo Trades',
            style: TextStyle(fontWeight: FontWeight.w900)),
        ...app.trades.take(12).map(
              (t) => ListTile(
                leading: Icon(
                  t.direction == SignalDirection.call
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                ),
                title: Text(t.symbol),
                subtitle:
                    Text('\$${t.amount.toStringAsFixed(2)} • ${t.payout}%'),
                trailing: Text(
                  t.won == null
                      ? 'OPEN'
                      : t.won!
                          ? 'WIN'
                          : 'LOSS',
                ),
              ),
            ),
      ],
    );
  }
}
