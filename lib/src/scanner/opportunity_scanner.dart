class OpportunityScanResult {
  final String symbol;
  final double entryQuality;
  final String state;
  final String direction;

  const OpportunityScanResult({
    required this.symbol,
    required this.entryQuality,
    required this.state,
    required this.direction,
  });
}

class OpportunityScanner {
  const OpportunityScanner();

  List<OpportunityScanResult> rank(
    List<OpportunityScanResult> values,
  ) {
    final copy = [...values];
    copy.sort((a, b) => b.entryQuality.compareTo(a.entryQuality));
    return copy;
  }
}
