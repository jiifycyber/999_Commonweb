import '../models.dart';
import '../cloud_guard/cloud_guard_models.dart';

class FusionDecision {
  final TitanSignal titan;
  final CloudGuardDecision cloudGuard;
  final String finalAction;
  final double fusionConfidence;
  final List<String> reasons;

  const FusionDecision({
    required this.titan,
    required this.cloudGuard,
    required this.finalAction,
    required this.fusionConfidence,
    required this.reasons,
  });
}
