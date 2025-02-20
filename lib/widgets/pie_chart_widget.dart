import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/expense.dart';

class PieChartWidget extends StatelessWidget{
  final List<Expense> expenses;

  const PieChartWidget({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    Map<String, double> categoryTotals = {};

    for(var e in expenses){
      categoryTotals[e.category] = (categoryTotals[e.category]??0) + e.amount;
    }

    List<PieChartSectionData> sections = categoryTotals.entries.map((entry){
      return PieChartSectionData(
        value: entry.value,
        title: '${entry.key}\n${entry.value.toStringAsFixed(0)}元',
        color: _getCategoryColor(entry.key),
        radius: 40,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 40,
        sectionsSpace: 2
      )
    );
  }

  Color _getCategoryColor(String category){
    switch(category){
      case '食物':
        return Colors.blue;
      case '交通':
        return Colors.red;
      case '娛樂':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

}