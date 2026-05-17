import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class WeeklyBarChart extends StatelessWidget {
  final List<double> data;
  final List<String> labels;

  final Color accent;
  final Color gridColor;
  final Color borderColor;
  final Color axisTextColor;
  final Color labelTextColor;

  final double barWidth;
  final int labelStep;

  const WeeklyBarChart({
    super.key,
    required this.data,
    required this.labels,
    required this.accent,
    required this.gridColor,
    required this.borderColor,
    required this.axisTextColor,
    required this.labelTextColor,
    this.barWidth = 15,
    this.labelStep = 1,
  });

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        minY: 0,
        maxY: 1,
        alignment: BarChartAlignment.spaceAround,
        backgroundColor: Colors.transparent,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (double value) {
            return FlLine(color: gridColor, strokeWidth: 1);
          },
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: borderColor),
        ),
        titlesData: FlTitlesData(
          show: true,
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 0.25,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value != 0 &&
                    value != 0.25 &&
                    value != 0.5 &&
                    value != 0.75 &&
                    value != 1) {
                  return const SizedBox();
                }

                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 8,
                  child: Text(
                    '${(value * 100).toInt()}%',
                    style: TextStyle(
                      color: axisTextColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              getTitlesWidget: (double value, TitleMeta meta) {
                final int index = value.toInt();
                if (index < 0 || index >= labels.length) {
                  return const SizedBox();
                }

                final bool shouldShowLabel =
                    index == 0 ||
                    index == labels.length - 1 ||
                    index % labelStep == 0;

                if (!shouldShowLabel) return const SizedBox();

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const SizedBox(height: 8),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      labels[index],
                      style: TextStyle(
                        color: labelTextColor,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        barGroups: _buildGroups(),
      ),
    );
  }

  List<BarChartGroupData> _buildGroups() {
    final groups = <BarChartGroupData>[];

    for (int i = 0; i < data.length; i++) {
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: <BarChartRodData>[
            BarChartRodData(
              toY: data[i],
              color: accent,
              width: barWidth,
              borderRadius: BorderRadius.circular(2),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: 1,
                color: Colors.transparent,
              ),
            ),
          ],
        ),
      );
    }

    return groups;
  }
}
