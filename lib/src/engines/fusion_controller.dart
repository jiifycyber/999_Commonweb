import '../models.dart';
import '../signal_engine.dart';
import '../cloud_guard/cloud_guard_x_engine.dart';
import 'fusion_models.dart';

class InfinityFusionController {
  final TitanSignalEngine titanEngine;
  final CloudGuardXEngine cloudGuardEngine;

  const InfinityFusionController({
    this.titanEngine = const TitanSignalEngine(),
    this.cloudGuardEngine = const CloudGuardXEngine(),
  });

  FusionDecision evaluate({
    required MarketSnapshot market,
    required double accountBalance,
    required double riskPercent,
    required int minimumConfidence,
  }) {
    final titan = titanEngine.evaluate(
      market: market,
      accountBalance: accountBalance,
      riskPercent: riskPercent,
      minimumConfidence: minimumConfidence,
    );

    final cloud = cloudGuardEngine.evaluate(
      market: market,
      titan: titan,
    );

    final reasons = <String>[
      ...titan.reasons,
      ...cloud.confirmations,
      ...cloud.warnings.map((w) => 'Warning: $w'),
    ];

    String finalAction = 'WAIT';
    if (cloud.shouldAlert) {
      finalAction = titan.direction == SignalDirection.call
          ? 'ENTER BUY/CALL'
          : titan.direction == SignalDirection.put
              ? 'ENTER SELL/PUT'
              : 'WAIT';
    } else if (cloud.statusLabel == 'ARMED') {
      finalAction = 'ARMED';
    }

    final fusionConfidence = (
      (titan.confidence / 100) * .48 +
      cloud.entryQuality * .42 +
      (1 - cloud.riskScore) * .10
    ).clamp(0.0, 1.0);

    return FusionDecision(
      titan: titan,
      cloudGuard: cloud,
      finalAction: finalAction,
      fusionConfidence: fusionConfidence,
      reasons: reasons,
    );
  }
}
