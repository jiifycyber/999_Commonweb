import 'models.dart';

class TitanSignalEngine {
  TitanSignal evaluate({
    required MarketSnapshot market,
    required double accountBalance,
    required double riskPercent,
    required int minimumConfidence,
  }) {
    int score = 0;
    final reasons = <String>[];

    final trendUp = market.ema20 > market.ema200;
    final trendDown = market.ema20 < market.ema200;

    if ((market.ema20 - market.ema200).abs() / market.price > 0.00015) {
      score += 24;
      reasons.add('EMA 20/200 trend separation confirmed');
    }

    if (market.momentum.abs() >= 0.55) {
      score += 20;
      reasons.add('Momentum is strong');
    }

    if (market.volumeStrength >= 0.60) {
      score += 18;
      reasons.add('Volume confirmation passed');
    }

    if (market.volatility >= 0.25 && market.volatility <= 0.75) {
      score += 16;
      reasons.add('Volatility is inside the preferred range');
    }

    if (market.payout >= 80) {
      score += 12;
      reasons.add('Payout is acceptable');
    }

    if ((trendUp && market.momentum > 0) ||
        (trendDown && market.momentum < 0)) {
      score += 10;
      reasons.add('Trend and momentum agree');
    }

    SignalDirection direction = SignalDirection.wait;
    if (score >= minimumConfidence) {
      if (trendUp && market.momentum > 0) {
        direction = SignalDirection.call;
      } else if (trendDown && market.momentum < 0) {
        direction = SignalDirection.put;
      }
    }

    final riskAmount = accountBalance * riskPercent / 100;

    return TitanSignal(
      symbol: market.symbol,
      direction: direction,
      confidence: score.clamp(0, 100),
      expirationMinutes: market.volatility > 0.60 ? 1 : 3,
      suggestedAmount: riskAmount,
      reasons: reasons,
      generatedAt: DateTime.now(),
    );
  }
}
