import 'package:flutter/material.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0B0F14),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top bar + title right
              Row(
                children: [
                  Icon(Icons.menu, color: Color(0xFFE5E7EB)),
                  Spacer(),
                  Text(
                    'RENDIMIENTO SEMANAL',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.8,
                      color: Color(0xFFE5E7EB),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 14),

              // Chart (fake bars)
              _WeeklyBarChart(
                values: [0.80, 0.50, 0.32, 0.62, 0.54, 0.73, 0.45],
                labels: ['L', 'M', 'X', 'J', 'V', 'S', 'D'],
              ),

              SizedBox(height: 16),

              // Stats cards row
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'CONSISTENCIA',
                      value: '85%',
                      showUpArrow: true,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      title: 'RACHA ACTUAL',
                      value: '12 DÍAS',
                      showUpArrow: false,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 22),

              // Quote
              Text(
                '“LA EXCELENCIA ES\nUN HÁBITO,\nNO UN ACTO”',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                  letterSpacing: 1.2,
                  color: Color(0xFF7C8796),
                ),
              ),
              SizedBox(height: 18),
              Text(
                'ARISTÓTELES',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 2.0,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final bool showUpArrow;

  const _StatCard({
    required this.title,
    required this.value,
    required this.showUpArrow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0F14),
        border: Border.all(color: const Color(0xFF334155)),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
              color: Color(0xFFE5E7EB),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _WeeklyBarChart extends StatelessWidget {
  final List<double> values; // 0..1
  final List<String> labels;

  const _WeeklyBarChart({required this.values, required this.labels});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      padding: const EdgeInsets.fromLTRB(10, 14, 10, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0F14),
        border: Border.all(color: const Color(0xFF334155)),
        borderRadius: BorderRadius.circular(2),
      ),
      child: CustomPaint(
        painter: _BarsPainter(values: values),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(labels.length, (i) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF6CFAFF),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      labels[i],
                      style: const TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.4,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _BarsPainter extends CustomPainter {
  final List<double> values;

  _BarsPainter({required this.values});

  @override
  void paint(Canvas canvas, Size size) {
    const borderColor = Color(0xFF334155);
    const gridColor = Color(0xFF1F2937);
    const barColor = Color(0xFF6CFAFF);

    // Chart area (leave bottom for labels/dots)
    final bottomReserve = 44.0;
    final chartRect = Rect.fromLTWH(
      0,
      0,
      size.width,
      size.height - bottomReserve,
    );

    // Draw horizontal grid lines (0/25/50/75/100)
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final y = chartRect.top + (chartRect.height * i / 4);
      canvas.drawLine(
        Offset(chartRect.left, y),
        Offset(chartRect.right, y),
        gridPaint,
      );
    }

    // Left labels
    const labelStyle = TextStyle(color: Color(0xFF6B7280), fontSize: 10);
    const ticks = ['100%', '75%', '50%', '25%', '0%'];
    for (int i = 0; i < ticks.length; i++) {
      final tp = TextPainter(
        text: const TextSpan(style: labelStyle, text: ''),
        textDirection: TextDirection.ltr,
      );
      tp.text = TextSpan(style: labelStyle, text: ticks[i]);
      tp.layout();
      final y = chartRect.top + (chartRect.height * i / 4) - tp.height / 2;
      tp.paint(canvas, Offset(2, y));
    }

    // Bars
    final count = values.length;
    final usableWidth = chartRect.width;
    final gap = usableWidth * 0.06;
    final barW = (usableWidth - gap * (count + 1)) / count;

    final barPaint = Paint()..color = barColor;

    for (int i = 0; i < count; i++) {
      final v = values[i].clamp(0.0, 1.0);
      final x = gap + i * (barW + gap);
      final barH = chartRect.height * v;
      final barRect = Rect.fromLTWH(x, chartRect.bottom - barH, barW, barH);
      canvas.drawRect(barRect, barPaint);
    }

    // Frame (thin border)
    final framePaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRect(chartRect, framePaint);
  }

  @override
  bool shouldRepaint(covariant _BarsPainter oldDelegate) {
    return oldDelegate.values != values;
  }
}
