import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ExpenseLineChart extends StatelessWidget {
  final Map<String, double> dailyData;

  const ExpenseLineChart({super.key, required this.dailyData});

  @override
  Widget build(BuildContext context) {
    List<FlSpot> spots = dailyData.entries.map((entry) {
      return FlSpot(double.parse(entry.key), entry.value);
    }).toList();

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blue,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: Colors.blue),
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text("${value.toInt()}日", style: const TextStyle(fontSize: 12));
              },
            ),
          ),
        ),
      ),
    );
  }
}
