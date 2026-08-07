import 'package:flutter/material.dart';
import '../demo_market/demo_market_assets.dart';
import '../theme.dart';
import '../widgets/tradex_widgets.dart';
import 'professional_chart_screen.dart';

class DemoMarketScreen extends StatefulWidget {
  const DemoMarketScreen({super.key});

  @override
  State<DemoMarketScreen> createState() => _DemoMarketScreenState();
}

class _DemoMarketScreenState extends State<DemoMarketScreen> {
  String query = '';
  String category = 'All';

  @override
  Widget build(BuildContext context) {
    final categories = <String>['All', ...{for (final a in demoMarketAssets) a.category}];
    final q = query.toLowerCase().trim();
    final visible = demoMarketAssets.where((a) {
      final c = category == 'All' || a.category == category;
      final s = q.isEmpty || a.symbol.toLowerCase().contains(q) || a.name.toLowerCase().contains(q);
      return c && s;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
          child: TextField(
            onChanged: (v) => setState(() => query = v),
            decoration: InputDecoration(
              hintText: 'Search demo markets',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: TradeXColors.panel,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            children: categories.map((c) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: ChoiceChip(
                label: Text(c),
                selected: category == c,
                onSelected: (_) => setState(() => category = c),
              ),
            )).toList(),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: visible.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final asset = visible[i];
              return XGlassPanel(
                padding: EdgeInsets.zero,
                child: ListTile(
                  leading: const Icon(Icons.candlestick_chart_rounded, color: TradeXColors.cyan),
                  title: Text(asset.symbol, style: const TextStyle(fontWeight: FontWeight.w900)),
                  subtitle: Text('${asset.category} • ${asset.name}'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ProfessionalChartScreen(initialSymbol: asset.symbol)),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
