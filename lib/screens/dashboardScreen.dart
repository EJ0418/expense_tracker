import 'package:flutter/material.dart';
import '../widgets/line_chart_widget.dart';

class DashboardScreen extends StatelessWidget {
  final Map<String, double> categoryData = {
    "食物": 500,
    "交通": 300,
    "娛樂": 200,
  };

  final Map<String, double> monthlyData = {
    "1": 2000,
    "2": 2500,
    "3": 1800,
  };

  final Map<String, double> dailyData = {
    "1": 200,
    "2": 300,
    "3": 150,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("數據儀表板")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("類別支出分布", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            // SizedBox(height: 200, child: ExpensePieChart(categoryData: categoryData)),

            const SizedBox(height: 20),
            const Text("每月支出", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            // SizedBox(height: 200, child: ExpenseBarChart(monthlyData: monthlyData)),

            const SizedBox(height: 20),
            const Text("每日支出趨勢", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 200, child: ExpenseLineChart(dailyData: dailyData)),
          ],
        ),
      ),
    );
  }
}
