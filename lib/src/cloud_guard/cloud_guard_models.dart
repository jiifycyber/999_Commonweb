import '../models.dart';

enum CloudGuardEntryStatus { wait, armed, enterNow, expired }

class CloudGuardDecision {
  final String symbol;
  final SignalDirection direction;
  final int titanConfidence;
  final double entryQuality;
  final double riskScore;
  final CloudGuardEntryStatus status;
  final List<String> confirmations;
  final List<String> warnings;
  final DateTime generatedAt;

  const CloudGuardDecision({
    required this.symbol,
    required this.direction,
    required this.titanConfidence,
    required this.entryQuality,
    required this.riskScore,
    required this.status,
    required this.confirmations,
    required this.warnings,
    required this.generatedAt,
  });

  bool get shouldAlert => status == CloudGuardEntryStatus.enterNow;

  String get statusLabel {
    switch (status) {
      case CloudGuardEntryStatus.wait:
        return 'WAIT';
      case CloudGuardEntryStatus.armed:
        return 'ARMED';
      case CloudGuardEntryStatus.enterNow:
        return 'ENTER NOW';
      case CloudGuardEntryStatus.expired:
        return 'EXPIRED';
    }
  }
}
