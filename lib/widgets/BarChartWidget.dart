import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/expense.dart';

class BarChartWidget extends StatelessWidget {
  final List<Expense> expenses;

  const BarChartWidget({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    Map<String, double> monthlyTotals = {};

    for (var e in expenses) {
      String month = DateFormat('yyyy-MM').format(e.date);
      monthlyTotals[month] = (monthlyTotals[month] ?? 0) + e.amount;
    }

    List<BarChartGroupData> barGroup = [];
    int index = 0;

    for (var entry in monthlyTotals.entries) {
      barGroup.add(BarChartGroupData(x: index, barRods: [
        BarChartRodData(
            toY: entry.value,
            color: Colors.blue,
            width: 16,
            borderRadius: BorderRadius.circular(4))
      ]));
      index++;
    }
    return BarChart(
        BarChartData(
            barGroups: barGroup,
            titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true)),
                bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            monthlyTotals.keys.elementAt(value.toInt()),
                            style: const TextStyle(fontSize: 12),
                          );
                        }
                    )
                )
            )
        )
    );
  }

}
