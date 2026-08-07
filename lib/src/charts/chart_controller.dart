import 'package:flutter/foundation.dart';
import 'chart_models.dart';

class InfinityChartController extends ChangeNotifier {
  ChartLayoutSettings settings = const ChartLayoutSettings();
  DrawingToolType drawingTool = DrawingToolType.cursor;

  void setTimeframe(String value) {
    settings = ChartLayoutSettings(
      chartType: settings.chartType,
      timeframe: value,
      ema20: settings.ema20,
      ema200: settings.ema200,
      bollinger: settings.bollinger,
      volume: settings.volume,
      rsi: settings.rsi,
      macd: settings.macd,
      stochastic: settings.stochastic,
    );
    notifyListeners();
  }

  void setDrawingTool(DrawingToolType value) {
    drawingTool = value;
    notifyListeners();
  }
}
