import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../market_data/twelve_data_service.dart';
import '../cloud_guard/cloud_guard_models.dart';
import '../cloud_guard/cloud_guard_x_engine.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/tradex_widgets.dart';

class ProfessionalChartScreen extends StatefulWidget {
  final String? initialSymbol;
  const ProfessionalChartScreen({super.key, this.initialSymbol});

  @override
  State<ProfessionalChartScreen> createState() =>
      _ProfessionalChartScreenState();
}

class _ProfessionalChartScreenState extends State<ProfessionalChartScreen> {
  String timeframe = '1m';
  bool showEma = true;
  bool showEntryZone = true;

  // Interactive chart controls
  double _chartZoom = 1.0;
  double _zoomAtGestureStart = 1.0;
  int _panCandles = 0;
  double _panAccumulator = 0.0;

  void _zoomIn() {
    setState(() {
      _chartZoom = (_chartZoom * 1.25).clamp(1.0, 6.0);
    });
  }

  void _zoomOut() {
    setState(() {
      _chartZoom = (_chartZoom / 1.25).clamp(1.0, 6.0);
    });
  }

  void _resetChartView() {
    setState(() {
      _chartZoom = 1.0;
      _panCandles = 0;
      _panAccumulator = 0;
    });
  }

  @override
  void initState() {
    super.initState();
    final initial = widget.initialSymbol;
    if (initial != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final app = context.read<TradeXAppState>();
        if (app.selectedSymbol != initial) app.setSymbol(initial);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<TradeXAppState>();
    final market = app.market;
    final titan = app.signal;

    CloudGuardDecision? cloud;
    if (market != null && titan != null) {
      cloud = const CloudGuardXEngine().evaluate(market: market, titan: titan);
    }

    return Material(
      color: Colors.transparent,
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Material(
                color: Colors.transparent,
                child: DropdownButton<String>(
                  value: app.symbols.contains(app.selectedSymbol)
                      ? app.selectedSymbol
                      : app.symbols.first,
                  items: app.symbols
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) app.setSymbol(v);
                  },
                ),
              ),
              ...['1m', '3m', '5m', '15m', '30m', '1h', '4h', '1D'].map(
                (t) => ChoiceChip(
                  label: Text(t),
                  selected: timeframe == t,
                  onSelected: (_) => setState(() => timeframe = t),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          XGlassPanel(
            padding: EdgeInsets.zero,
            glowColor: TradeXColors.cyan,
            child: SizedBox(
              height: 430,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,

                      // Pinch zoom + horizontal drag
                      onScaleStart: (details) {
                        _zoomAtGestureStart = _chartZoom;
                        _panAccumulator = 0;
                      },

                      onScaleUpdate: (details) {
                        setState(() {
                          // PINCH TO ZOOM
                          if (details.pointerCount > 1) {
                            _chartZoom = (_zoomAtGestureStart * details.scale)
                                .clamp(1.0, 6.0);
                          }

                          // DRAG LEFT / RIGHT
                          if (details.pointerCount == 1) {
                            _panAccumulator += details.focalPointDelta.dx;

                            // Roughly one candle every 9 pixels dragged.
                            if (_panAccumulator.abs() >= 9) {
                              final move = (_panAccumulator / 9).truncate();

                              // Drag right = look farther back in history.
                              _panCandles = (_panCandles + move).clamp(
                                0,
                                app.liveCandles.length > 10
                                    ? app.liveCandles.length - 10
                                    : 0,
                              );

                              _panAccumulator -= move * 9;
                            }
                          }
                        });
                      },

                      onDoubleTap: _resetChartView,

                      child: CustomPaint(
                        painter: _InfinityChartPainter(
                          candles: app.liveCandles,
                          showEma: showEma,
                          zoom: _chartZoom,
                          panCandles: _panCandles,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 12,
                    top: 12,
                    child: Material(
                      color: Colors.transparent,
                      child: Row(
                        children: [
                          IconButton(
                            tooltip: 'Zoom out',
                            onPressed: _zoomOut,
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: TradeXColors.cyan,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Reset chart',
                            onPressed: _resetChartView,
                            icon: const Icon(
                              Icons.fit_screen_rounded,
                              color: TradeXColors.cyan,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Zoom in',
                            onPressed: _zoomIn,
                            icon: const Icon(
                              Icons.add_circle_outline,
                              color: TradeXColors.cyan,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 18,
                    top: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(app.selectedSymbol,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w900)),
                        Text('$timeframe • ${app.dataSource}',
                            style: const TextStyle(
                                color: TradeXColors.muted, fontSize: 11)),
                      ],
                    ),
                  ),
                  if (showEntryZone)
                    const Positioned(
                      left: 72,
                      right: 70,
                      bottom: 98,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Color(0x2211D8A0),
                          border: Border.fromBorderSide(
                              BorderSide(color: TradeXColors.green)),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Center(
                            child: Text(
                              'CLOUD GUARD ENTRY ZONE',
                              style: TextStyle(
                                  color: TradeXColors.green,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (cloud?.shouldAlert == true)
                    const Positioned(
                      right: 24,
                      bottom: 140,
                      child: Column(
                        children: [
                          Icon(Icons.arrow_upward_rounded,
                              color: TradeXColors.green, size: 38),
                          Text('ENTER NOW',
                              style: TextStyle(
                                  color: TradeXColors.green,
                                  fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                  label: const Text('EMA 20/200'),
                  selected: showEma,
                  onSelected: (v) => setState(() => showEma = v)),
              FilterChip(
                  label: const Text('Entry Zone'),
                  selected: showEntryZone,
                  onSelected: (v) => setState(() => showEntryZone = v)),
              const Chip(label: Text('RSI')),
              const Chip(label: Text('MACD')),
              const Chip(label: Text('Bollinger')),
              const Chip(label: Text('Volume')),
            ],
          ),
          const SizedBox(height: 12),
          XGlassPanel(
            padding: const EdgeInsets.all(14),
            glowColor: cloud?.shouldAlert == true
                ? TradeXColors.green
                : TradeXColors.violet,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('DUAL ENGINE STATUS',
                    style: TextStyle(
                        fontWeight: FontWeight.w900, letterSpacing: 1)),
                const SizedBox(height: 10),
                Text(
                    'Titan Signal Engine: ${_direction(titan?.direction)} • ${titan?.confidence ?? 0}%'),
                Text('Cloud Guard X: ${cloud?.statusLabel ?? 'WAIT'}'),
                Text(
                    'Entry Quality: ${((cloud?.entryQuality ?? 0) * 100).toStringAsFixed(0)}%'),
                Text(
                    'Risk Score: ${((cloud?.riskScore ?? 0) * 100).toStringAsFixed(0)}%'),
                const SizedBox(height: 8),
                Text(app.entryStatus,
                    style: const TextStyle(
                        color: TradeXColors.cyan, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _direction(SignalDirection? d) {
    if (d == SignalDirection.call) return 'BUY/CALL';
    if (d == SignalDirection.put) return 'SELL/PUT';
    return 'WAIT';
  }
}

class _InfinityChartPainter extends CustomPainter {
  final List<LiveCandle> candles;
  final bool showEma;
  final double zoom;
  final int panCandles;

  const _InfinityChartPainter({
    required this.candles,
    required this.showEma,
    required this.zoom,
    required this.panCandles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = const Color(0xFF213147)
      ..strokeWidth = .8;

    for (var i = 1; i < 6; i++) {
      final y = size.height * i / 6;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    for (var i = 1; i < 9; i++) {
      final x = size.width * i / 9;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }

    if (candles.isEmpty) {
      final tp = TextPainter(
        text: const TextSpan(
          text: 'WAITING FOR TWELVE DATA...',
          style: TextStyle(
            color: TradeXColors.muted,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(
        canvas,
        Offset(
          (size.width - tp.width) / 2,
          (size.height - tp.height) / 2,
        ),
      );
      return;
    }

    // Interactive visible candle window.
    //
    // Zoom 1x = about 60 candles.
    // Zoom 6x = about 10 candles.
    final desiredCount = (60 / zoom).round().clamp(10, 60);

    var endIndex = candles.length - panCandles;

    if (endIndex > candles.length) {
      endIndex = candles.length;
    }

    if (endIndex < 1) {
      endIndex = 1;
    }

    var startIndex = endIndex - desiredCount;

    if (startIndex < 0) {
      startIndex = 0;
    }

    final visible = candles.sublist(startIndex, endIndex);

    double minPrice = visible.first.low;
    double maxPrice = visible.first.high;

    for (final c in visible) {
      if (c.low < minPrice) minPrice = c.low;
      if (c.high > maxPrice) maxPrice = c.high;
    }

    var range = maxPrice - minPrice;
    if (range <= 0) range = 1;

    const leftPad = 18.0;
    const rightPad = 18.0;
    const topPad = 55.0;
    const bottomPad = 45.0;

    final chartWidth = size.width - leftPad - rightPad;
    final chartHeight = size.height - topPad - bottomPad;
    final step = chartWidth / visible.length;

    double priceY(double price) {
      return topPad + ((maxPrice - price) / range) * chartHeight;
    }

    for (var i = 0; i < visible.length; i++) {
      final c = visible[i];
      final x = leftPad + (i + .5) * step;

      final openY = priceY(c.open);
      final closeY = priceY(c.close);
      final highY = priceY(c.high);
      final lowY = priceY(c.low);

      final bullish = c.close >= c.open;

      final paint = Paint()
        ..color = bullish ? TradeXColors.green : const Color(0xFFFF5263)
        ..strokeWidth = 1.4;

      canvas.drawLine(
        Offset(x, highY),
        Offset(x, lowY),
        paint,
      );

      final top = openY < closeY ? openY : closeY;
      final bodyHeight = (openY - closeY).abs().clamp(2.0, chartHeight);

      canvas.drawRect(
        Rect.fromLTWH(
          x - step * .28,
          top,
          step * .56,
          bodyHeight,
        ),
        paint,
      );
    }

    if (showEma && visible.length >= 20) {
      final closes = visible.map((e) => e.close).toList();

      final emaPaint = Paint()
        ..color = TradeXColors.cyan
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke;

      final path = Path();
      double? previousEma;
      const period = 20;
      const multiplier = 2 / (period + 1);

      for (var i = 0; i < closes.length; i++) {
        if (previousEma == null) {
          previousEma = closes[i];
        } else {
          previousEma = (closes[i] - previousEma) * multiplier + previousEma;
        }

        final x = leftPad + (i + .5) * step;
        final y = priceY(previousEma!);

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      canvas.drawPath(path, emaPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _InfinityChartPainter oldDelegate) {
    return oldDelegate.candles != candles ||
        oldDelegate.showEma != showEma ||
        oldDelegate.zoom != zoom ||
        oldDelegate.panCandles != panCandles;
  }
}
