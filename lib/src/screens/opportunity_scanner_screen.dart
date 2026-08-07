import 'package:flutter/material.dart';
import '../scanner/opportunity_scanner.dart';
import '../theme.dart';
import '../widgets/tradex_widgets.dart';
import 'professional_chart_screen.dart';

class OpportunityScannerScreen extends StatelessWidget {
  const OpportunityScannerScreen({super.key});

  static const values = [
    OpportunityScanResult(symbol: 'EUR/USD', entryQuality: .94, state: 'ARMED', direction: 'BUY'),
    OpportunityScanResult(symbol: 'XAU/USD', entryQuality: .93, state: 'ENTER NOW', direction: 'BUY'),
    OpportunityScanResult(symbol: 'BTC/USD', entryQuality: .89, state: 'ARMED', direction: 'BUY'),
    OpportunityScanResult(symbol: 'GBP/JPY', entryQuality: .81, state: 'WAIT', direction: 'SELL'),
    OpportunityScanResult(symbol: 'NAS100', entryQuality: .78, state: 'WAIT', direction: 'BUY'),
  ];

  @override
  Widget build(BuildContext context) {
    final results = const OpportunityScanner().rank(values);

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final r = results[i];
        return XGlassPanel(
          padding: EdgeInsets.zero,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: TradeXColors.cyan.withValues(alpha: .12),
              child: Text('${i + 1}'),
            ),
            title: Text(r.symbol, style: const TextStyle(fontWeight: FontWeight.w900)),
            subtitle: Text('${r.direction} • ${r.state}'),
            trailing: Text(
              '${(r.entryQuality * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                color: TradeXColors.green,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ProfessionalChartScreen(initialSymbol: r.symbol),
              ),
            ),
          ),
        );
      },
    );
  }
}
