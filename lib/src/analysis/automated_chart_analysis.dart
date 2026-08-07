import '../models.dart';

class AutomatedChartAnalysis {
  final String trend;
  final double trendStrength;
  final bool breakoutPossible;
  final bool supportNearby;
  final bool resistanceNearby;
  final List<String> patterns;

  const AutomatedChartAnalysis({
    required this.trend,
    required this.trendStrength,
    required this.breakoutPossible,
    required this.supportNearby,
    required this.resistanceNearby,
    required this.patterns,
  });
}

class AutomatedChartAnalyzer {
  const AutomatedChartAnalyzer();

  AutomatedChartAnalysis analyze(MarketSnapshot market) {
    final bullish = market.ema20 > market.ema200 && market.momentum > 0;
    final bearish = market.ema20 < market.ema200 && market.momentum < 0;
    final separation =
        ((market.ema20 - market.ema200).abs() / market.price * 100)
            .clamp(0.0, 1.0);

    return AutomatedChartAnalysis(
      trend: bullish ? 'BULLISH' : bearish ? 'BEARISH' : 'RANGING',
      trendStrength: (separation + market.momentum.abs() * .45)
          .clamp(0.0, 1.0),
      breakoutPossible:
          market.volatility > .62 && market.volumeStrength > .65,
      supportNearby: market.momentum < -.35,
      resistanceNearby: market.momentum > .35,
      patterns: [
        if (bullish) 'Trend continuation candidate',
        if (bearish) 'Bearish continuation candidate',
        if (market.volatility > .72) 'Volatility expansion',
        if (market.volumeStrength > .75) 'High activity confirmation',
      ],
    );
  }
}
