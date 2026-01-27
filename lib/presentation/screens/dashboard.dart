import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
              // Top bar: menu + online
              Row(
                children: [
                  Icon(Icons.menu, color: Color(0xFFE5E7EB)),
                  Spacer(),
                  _OnlineBadge(),
                ],
              ),

              SizedBox(height: 16),

              // Circular % ring
              Center(
                child: _ProbabilityRing(
                  size: 210,
                  progress: 0.84,
                  valueText: '84%',
                  label: 'PROBABILIDAD',
                ),
              ),

              SizedBox(height: 18),

              // Weather card
              _WeatherCard(
                city: 'MÁLAGA, ES',
                temp: '18°C',
                status: 'ÓPTIMO',
                hum: '45%',
                wind: '12km/h',
              ),

              SizedBox(height: 14),

              // Habits list
              Expanded(
                child: Column(
                  children: [
                    _HabitTile(
                      title: 'GIMNASIO',
                      streak: 'RACHA: 4 DÍAS',
                      active: true,
                      accent: Color(0xFF6CFAFF),
                    ),
                    SizedBox(height: 10),
                    _HabitTile(
                      title: 'LECTURA',
                      streak: 'RACHA: 15 DÍAS',
                      active: true,
                      accent: Color(0xFF6CFAFF),
                    ),
                    SizedBox(height: 10),
                    _HabitTile(
                      title: 'MEDITACIÓN',
                      streak: 'RACHA: 2 DÍAS',
                      active: false,
                      accent: Color(0xFF93A3B8),
                    ),
                    SizedBox(height: 10),
                    _HabitTile(
                      title: 'DORMIR 8\nHORAS',
                      streak: 'RACHA: 5 DÍAS',
                      active: false,
                      accent: Color(0xFF93A3B8),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnlineBadge extends StatelessWidget {
  const _OnlineBadge();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        _Dot(color: Color(0xFF22C55E)),
        SizedBox(width: 6),
        Text(
          'ONLINE',
          style: TextStyle(
            color: Color(0xFFE5E7EB),
            fontSize: 11,
            letterSpacing: 1.6,
          ),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _ProbabilityRing extends StatelessWidget {
  final double size;
  final double progress; // 0..1
  final String valueText;
  final String label;

  const _ProbabilityRing({
    required this.size,
    required this.progress,
    required this.valueText,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          progress: progress,
          bg: const Color(0xFF1E293B),
          fg: const Color(0xFF6CFAFF),
          stroke: 14,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                valueText,
                style: const TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFE5E7EB),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  letterSpacing: 2.0,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color bg;
  final Color fg;
  final double stroke;

  _RingPainter({
    required this.progress,
    required this.bg,
    required this.fg,
    required this.stroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - stroke) / 2;

    final bgPaint = Paint()
      ..color = bg
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    final fgPaint = Paint()
      ..color = fg
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    // Start at top (12 o'clock)
    const start = -1.57079632679; // -pi/2
    final sweep = 6.28318530718 * progress; // 2*pi*progress

    canvas.drawCircle(center, radius, bgPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      sweep,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.bg != bg ||
        oldDelegate.fg != fg ||
        oldDelegate.stroke != stroke;
  }
}

class _WeatherCard extends StatelessWidget {
  final String city;
  final String temp;
  final String status;
  final String hum;
  final String wind;

  const _WeatherCard({
    required this.city,
    required this.temp,
    required this.status,
    required this.hum,
    required this.wind,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF141A22),
        border: Border.all(color: const Color(0xFF334155)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          // Left: icon + city + temp/status
          const Icon(
            Icons.wb_sunny_outlined,
            color: Color(0xFF6CFAFF),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  city,
                  style: const TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.4,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$temp // $status',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: Color(0xFFE5E7EB),
                  ),
                ),
              ],
            ),
          ),

          // Right: hum/wind
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'HUM: $hum',
                style: const TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.2,
                  color: Color(0xFF9CA3AF),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'WIND: $wind',
                style: const TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.2,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HabitTile extends StatelessWidget {
  final String title;
  final String streak;
  final bool active;
  final Color accent;

  const _HabitTile({
    required this.title,
    required this.streak,
    required this.active,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74,
      decoration: BoxDecoration(
        color: const Color(0xFF1B2430),
        border: Border.all(color: const Color(0xFF0F172A)),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        children: [
          Container(width: 4, color: accent),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.6,
                    color: Color(0xFFE5E7EB),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  streak,
                  style: const TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.4,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 18,
            height: 18,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              border: Border.all(color: accent, width: 1.5),
              color: active ? const Color(0xFF6CFAFF) : Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}
