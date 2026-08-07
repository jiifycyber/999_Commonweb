import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../analysis/automated_chart_analysis.dart';
import '../app_state.dart';
import '../theme.dart';
import '../widgets/tradex_widgets.dart';

class AutomatedAnalysisScreen extends StatelessWidget {
  const AutomatedAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<TradeXAppState>();
    final market = app.market;

    if (market == null) {
      return Center(child: Text(app.marketError ?? 'Waiting for market data'));
    }

    final analysis = const AutomatedChartAnalyzer().analyze(market);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        XGlassPanel(
          padding: const EdgeInsets.all(18),
          glowColor: TradeXColors.violet,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AUTOMATED CHART INTELLIGENCE',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
              ),
              const SizedBox(height: 12),
              Text('Trend: ${analysis.trend}'),
              Text(
                'Trend strength: ${(analysis.trendStrength * 100).toStringAsFixed(0)}%',
              ),
              Text('Breakout possible: ${analysis.breakoutPossible ? 'YES' : 'NO'}'),
              Text('Support nearby: ${analysis.supportNearby ? 'YES' : 'NO'}'),
              Text('Resistance nearby: ${analysis.resistanceNearby ? 'YES' : 'NO'}'),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Text('Detected Conditions',
            style: TextStyle(fontWeight: FontWeight.w900)),
        ...analysis.patterns.map(
          (x) => ListTile(
            leading: const Icon(Icons.auto_graph, color: TradeXColors.cyan),
            title: Text(x),
          ),
        ),
      ],
    );
  }
}
