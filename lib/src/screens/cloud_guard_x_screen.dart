import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../cloud_guard/cloud_guard_x_engine.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/tradex_widgets.dart';

class CloudGuardXScreen extends StatelessWidget {
  const CloudGuardXScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<TradeXAppState>();
    final market = app.market;
    final titan = app.signal;

    if (market == null || titan == null) {
      return Center(
        child: XGlassPanel(
          padding: const EdgeInsets.all(20),
          child: Text(app.marketError ?? 'Waiting for market data...'),
        ),
      );
    }

    final cloud = const CloudGuardXEngine().evaluate(market: market, titan: titan);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        XGlassPanel(
          padding: const EdgeInsets.all(18),
          glowColor: cloud.shouldAlert ? TradeXColors.green : TradeXColors.violet,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('CLOUD GUARD X FUSION ENGINE', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              const Text('Second-engine entry intelligence', style: TextStyle(color: TradeXColors.muted)),
              const SizedBox(height: 18),
              Text(market.symbol, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              Text('Titan direction: ${_direction(titan.direction)}'),
              Text('Titan confidence: ${titan.confidence}%'),
              Text('Cloud Guard entry quality: ${(cloud.entryQuality * 100).toStringAsFixed(0)}%'),
              Text('Risk score: ${(cloud.riskScore * 100).toStringAsFixed(0)}%'),
              const SizedBox(height: 16),
              Text(
                cloud.statusLabel,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: cloud.shouldAlert ? TradeXColors.green : TradeXColors.cyan,
                ),
              ),
              const SizedBox(height: 6),
              Text(app.entryStatus),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text('Confirmations', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
        const SizedBox(height: 8),
        ...cloud.confirmations.map((x) => ListTile(
          leading: const Icon(Icons.check_circle_rounded, color: TradeXColors.green),
          title: Text(x),
        )),
        if (cloud.warnings.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Text('Warnings', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
          ...cloud.warnings.map((x) => ListTile(
            leading: const Icon(Icons.warning_amber_rounded, color: Colors.amber),
            title: Text(x),
          )),
        ],
      ],
    );
  }

  String _direction(SignalDirection d) {
    if (d == SignalDirection.call) return 'BUY/CALL';
    if (d == SignalDirection.put) return 'SELL/PUT';
    return 'WAIT';
  }
}
