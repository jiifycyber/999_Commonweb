class InfinityCandle {
  final DateTime time;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  const InfinityCandle({
    required this.time,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    this.volume = 0,
  });
}

enum InfinityChartType { candles, line, bars, heikinAshi }

enum DrawingToolType {
  cursor,
  trendLine,
  horizontalLine,
  verticalLine,
  rectangle,
  fibonacci,
  text,
  supportResistance,
}

class ChartLayoutSettings {
  final InfinityChartType chartType;
  final String timeframe;
  final bool ema20;
  final bool ema200;
  final bool bollinger;
  final bool volume;
  final bool rsi;
  final bool macd;
  final bool stochastic;

  const ChartLayoutSettings({
    this.chartType = InfinityChartType.candles,
    this.timeframe = '1m',
    this.ema20 = true,
    this.ema200 = true,
    this.bollinger = false,
    this.volume = true,
    this.rsi = true,
    this.macd = true,
    this.stochastic = false,
  });
}
