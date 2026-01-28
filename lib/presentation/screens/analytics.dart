import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:habit_control/presentation/screens/lateral_menu.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),

      drawer: const Drawer(
        backgroundColor: Color.fromARGB(34, 0, 70, 221),
        child: LateralMenu(),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // TOP BAR
              Row(
                children: [
                  Builder(
                    builder: (context) {
                      return IconButton(
                        icon: const Icon(Icons.menu, color: Color(0xFFE5E7EB)),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      );
                    },
                  ),
                  const Spacer(),
                  const Text(
                    'RENDIMIENTO SEMANAL',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.8,
                      color: Color(0xFFE5E7EB),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // GRÁFICA
              const SizedBox(
                height: 320,
                child: _WeeklyBarChart(),
              ),

              const SizedBox(height: 20),

              // ESTADÍSTICAS
              const Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'CONSISTENCIA',
                      value: '85%',
                      isGood: true,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      title: 'RACHA ACTUAL',
                      value: '12 DÍAS',
                      isGood: null,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // QUOTE
              const Text(
                '“LA EXCELENCIA ES\nUN HÁBITO,\nNO UN ACTO”',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                  letterSpacing: 1.2,
                  color: Color(0xFF7C8796),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'ARISTÓTELES',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 2.0,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/* ------------------ WIDGETS DE LA GRÁFICA ------------------ */

class _WeeklyBarChart extends StatelessWidget {
  const _WeeklyBarChart();

  @override
  Widget build(BuildContext context) {
    final List<double> weeklyData = [0.80, 0.50, 0.32, 0.60, 0.53, 0.73, 0.45];
    final List<String> days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

    return BarChart(
      BarChartData(
        minY: 0,
        maxY: 1,
        alignment: BarChartAlignment.spaceAround,
        backgroundColor: Colors.transparent,
        
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => const FlLine(
            color: Color(0xFF1F2937),
            strokeWidth: 1,
          ),
        ),

        borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xFF334155)),
        ),

        titlesData: FlTitlesData(
          show: true,
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          
          // EJE IZQUIERDO (Porcentajes)
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40, // 40px a la izquierda
              interval: 0.25,
              getTitlesWidget: (value, meta) {
                // Solo mostramos 0, 50 y 100 para más limpieza
                if (value == 0 || value == 0.5 || value == 1) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 8,
                    child: Text(
                      '${(value * 100).toInt()}%',
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),

          // EJE DERECHO (Niveles cualitativos)
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40, // 40px a la derecha -> SIMETRÍA PERFECTA
              interval: 0.5,    // Solo queremos marcas principales
              getTitlesWidget: (value, meta) {
                String text = '';
                // Definimos las etiquetas
                if (value == 1) text = 'MÁX';
                else if (value == 0.5) text = 'MED';
                else if (value == 0) text = 'MIN';
                
                if (text.isEmpty) return const SizedBox();

                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 8,
                  child: Text(
                    text,
                    style: TextStyle(
                      // Un poco más oscuro que la izquierda para que sea sutil
                      color: const Color(0xFF6B7280).withOpacity(0.7),
                      fontSize: 9, // Un pelín más pequeño (tipo técnico)
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),

          // EJE INFERIOR (Días)
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42, 
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= days.length) return const SizedBox();
                
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
                      days[index],
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),

        barGroups: weeklyData.asMap().entries.map((entry) {
          final index = entry.key;
          final value = entry.value;
          
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: value,
                color: const Color(0xFF6CFAFF),
                width: 10,
                borderRadius: BorderRadius.circular(2),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: 1,
                  color: Colors.transparent,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final bool? isGood; 

  const _StatCard({
    required this.title,
    required this.value,
    required this.isGood,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0F14),
        border: Border.all(color: const Color(0xFF334155)),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: Color(0xFFE5E7EB),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                  color: Color(0xFFF3F4F6),
                ),
              ),
              if (isGood != null) ...[
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_drop_up,
                  size: 24,
                  color: Color(0xFF22C55E),
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }
}