import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:habit_control/presentation/screens/lateral_menu.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Lista de hábitos
  final List<Habit> habits = [
    Habit('GYM', 'STREAK: 4 DAYS', true),
    Habit('READING', 'STREAK: 15 DAYS', true),
    Habit('MEDITATION', 'STREAK: 2 DAYS', false),
    Habit('SLEEP 8\nHOURS', 'STREAK: 5 DAYS', false),
    Habit('WATER', 'STREAK: 3 DAYS', true),
    Habit('RUNNING', 'STREAK: 1 DAY', false),
  ];

  // Función para marcar/desmarcar
  void toggleHabit(int index) {
    setState(() {
      habits[index].active = !habits[index].active;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. CÁLCULOS
    final int total = habits.length;
    final int completados = habits.where((h) => h.active).length;
    final double progresoDecimal = total == 0 ? 0.0 : (completados / total);
    final int porcentajeTexto = (progresoDecimal * 100).toInt();

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),

      drawer: const Drawer(
        backgroundColor: Color.fromARGB(34, 0, 70, 221),
        child: LateralMenu(),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // HEADER
                Row(
                  children: [
                    Builder(
                      builder: (context) {
                        return IconButton(
                          icon: const Icon(
                            Icons.menu,
                            color: Color(0xFFE5E7EB),
                          ),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        );
                      },
                    ),
                    const Spacer(),
                    const OnlineBadge(),
                  ],
                ),

                const SizedBox(height: 20),

                // RING
                Center(
                  child: CircularPercentIndicator(
                    radius: 105.0,
                    lineWidth: 14.0,
                    percent: progresoDecimal,

                    // --- AQUÍ ESTÁ EL ARREGLO ---
                    animation: true,
                    animateFromLastPercent:
                        true, // Esto evita que empiece de 0 cada vez
                    animationDuration:
                        600, // Un poco más rápido para que se sienta ágil
                    // ---------------------------
                    circularStrokeCap: CircularStrokeCap.round,
                    backgroundColor: const Color(0xFF1E293B),
                    progressColor: const Color(0xFF6CFAFF),
                    center: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$porcentajeTexto%',
                          style: const TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFE5E7EB),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'COMPLETED',
                          style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 2.0,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // WEATHER
                const WeatherCard(
                  city: 'MALAGA, ES',
                  temp: '18°C',
                  status: 'OPTIMAL',
                  hum: '45%',
                  wind: '12km/h',
                ),

                const SizedBox(height: 30),

                // LISTA DE HÁBITOS
                for (int i = 0; i < habits.length; i++) ...[
                  HabitTile(
                    title: habits[i].title,
                    streak: habits[i].streak,
                    active: habits[i].active,
                    // Color dinámico de la barrita y el borde
                    accent: habits[i].active
                        ? const Color(0xFF6CFAFF)
                        : const Color(0xFF93A3B8),
                    onTap: () => toggleHabit(i),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ------------------ MODELO SIMPLE ------------------ */

class Habit {
  final String title;
  final String streak;
  bool active;

  Habit(this.title, this.streak, this.active);
}

/* ------------------ WIDGETS UI ------------------ */

class OnlineBadge extends StatelessWidget {
  const OnlineBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Dot(color: Color(0xFF22C55E)),
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

class Dot extends StatelessWidget {
  final Color color;
  const Dot({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class WeatherCard extends StatelessWidget {
  final String city;
  final String temp;
  final String status;
  final String hum;
  final String wind;

  const WeatherCard({
    super.key,
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

class HabitTile extends StatelessWidget {
  final String title;
  final String streak;
  final bool active;
  final Color accent;
  final VoidCallback onTap;

  const HabitTile({
    super.key,
    required this.title,
    required this.streak,
    required this.active,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
      ),
    );
  }
}
