import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../widgets/universal_back_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late double balance;
  late double risk;
  late double lossLimit;
  late double confidence;
  late double maxTrades;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final app = context.read<TradeXAppState>();
    balance = app.accountBalance;
    risk = app.riskPercent;
    lossLimit = app.dailyLossLimitPercent;
    confidence = app.minimumConfidence.toDouble();
    maxTrades = app.maxTradesPerDay.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<TradeXAppState>();
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: const UniversalBackButton(),
          title: const Text('Risk Controls')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _slider('Account balance', balance, 100, 100000,
              (v) => setState(() => balance = v),
              valueText: '\$${balance.toStringAsFixed(0)}'),
          _slider(
              'Risk per trade', risk, .25, 3, (v) => setState(() => risk = v),
              valueText: '${risk.toStringAsFixed(2)}%'),
          _slider('Daily loss limit', lossLimit, 1, 10,
              (v) => setState(() => lossLimit = v),
              valueText: '${lossLimit.toStringAsFixed(1)}%'),
          _slider('Minimum confidence', confidence, 50, 95,
              (v) => setState(() => confidence = v),
              valueText: '${confidence.toStringAsFixed(0)}%'),
          _slider('Maximum trades per day', maxTrades, 1, 20,
              (v) => setState(() => maxTrades = v),
              valueText: maxTrades.toStringAsFixed(0)),
          SwitchListTile(
            value: app.demoMode,
            onChanged: (v) => app.updateSettings(demo: v),
            title: const Text('Demo mode'),
            subtitle:
                const Text('Live execution remains disabled in this starter.'),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              app.updateSettings(
                balance: balance,
                risk: risk,
                dailyLoss: lossLimit,
                confidence: confidence.round(),
                maxTrades: maxTrades.round(),
              );
              Navigator.pop(context);
            },
            child: const Text('Save Risk Settings'),
          ),
        ],
      ),
    );
  }

  Widget _slider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged, {
    required String valueText,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$label: $valueText'),
            Slider(value: value, min: min, max: max, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}
