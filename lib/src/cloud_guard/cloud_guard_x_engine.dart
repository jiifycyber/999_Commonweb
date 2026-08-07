import '../models.dart';
import 'cloud_guard_models.dart';

class CloudGuardXEngine {
  const CloudGuardXEngine();

  CloudGuardDecision evaluate({
    required MarketSnapshot market,
    required TitanSignal titan,
    double maxRiskScore = 0.65,
  }) {
    final confirmations = <String>[];
    final warnings = <String>[];

    final trendSeparation =
        ((market.ema20 - market.ema200).abs() / market.price).clamp(0.0, 1.0);
    final trendScore = (trendSeparation * 900).clamp(0.0, 1.0);
    final momentumScore = market.momentum.abs().clamp(0.0, 1.0);
    final activityScore = market.volumeStrength.clamp(0.0, 1.0);
    final volatilityQuality =
        (1.0 - ((market.volatility - 0.48).abs() / 0.48)).clamp(0.0, 1.0);

    final directionAligned =
        (titan.direction == SignalDirection.call && market.momentum > 0) ||
            (titan.direction == SignalDirection.put && market.momentum < 0);

    if (trendScore >= .60) confirmations.add('Trend separation confirmed');
    if (momentumScore >= .60) confirmations.add('Momentum confirmed');
    if (activityScore >= .55) confirmations.add('Market activity confirmed');
    if (volatilityQuality >= .55) confirmations.add('Volatility is suitable');
    if (directionAligned) confirmations.add('Titan direction is aligned');

    final riskScore = ((market.volatility > .78 ? .45 : .10) +
            (activityScore < .35 ? .25 : 0) +
            (titan.confidence < 75 ? .20 : 0))
        .clamp(0.0, 1.0);

    if (riskScore > .45) warnings.add('Risk conditions are elevated');
    if (titan.direction == SignalDirection.wait) {
      warnings.add('Titan Engine has not confirmed direction');
    }

    final titanScore = (titan.confidence / 100).clamp(0.0, 1.0);
    final entryQuality = (titanScore * .30 +
            trendScore * .20 +
            momentumScore * .20 +
            activityScore * .12 +
            volatilityQuality * .18)
        .clamp(0.0, 1.0);

    CloudGuardEntryStatus status;
    if (titan.direction == SignalDirection.wait || riskScore >= maxRiskScore) {
      status = CloudGuardEntryStatus.wait;
    } else if (entryQuality >= .88 &&
        titan.confidence >= 82 &&
        directionAligned) {
      status = CloudGuardEntryStatus.enterNow;
    } else if (entryQuality >= .70 && titan.confidence >= 72) {
      status = CloudGuardEntryStatus.armed;
    } else {
      status = CloudGuardEntryStatus.wait;
    }

    return CloudGuardDecision(
      symbol: market.symbol,
      direction: titan.direction,
      titanConfidence: titan.confidence,
      entryQuality: entryQuality,
      riskScore: riskScore,
      status: status,
      confirmations: confirmations,
      warnings: warnings,
      generatedAt: DateTime.now(),
    );
  }
}
