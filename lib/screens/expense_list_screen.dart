import 'package:expense_tracker/providers/expense_providers.dart';
import 'package:expense_tracker/widgets/BarChartWidget.dart';
import 'package:expense_tracker/widgets/pie_chart_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/consts.dart';
import '../models/expense.dart';

final selectedCategoryProvider = StateProvider<String>((ref) => '全部');

class ExpenseListScreen extends ConsumerWidget {
  const ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expenseProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    Widget buildFilterAndSearchBar() {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: selectedCategory,
              items: ['全部', '食物', '交通', '娛樂', '其他']
                  .map((c) =>
                  DropdownMenuItem(
                    value: c,
                    child: Text(c),
                  ))
                  .toList(),
              onChanged: (value) {
                ref
                    .read(selectedCategoryProvider.notifier)
                    .state = value!;
                ref.read(expenseProvider.notifier).filterByCategory(value);
              },
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                hintText: '搜尋支出...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (query) {
                ref.read(expenseProvider.notifier).searchExpenses(query);
              },
            ),
          ],
        ),
      );
    }

    Widget buildExpenseList() {
      return Expanded(
        child: expenses.isEmpty
            ? const Center(
          child: Text('尚未有零錢支出紀錄'),
        )
            : ListView.builder(
          itemCount: expenses.length,
          itemBuilder: (context, index) {
            final expense = expenses[index];
            return Dismissible(
              key: ValueKey(expense.id.toString()),
              // 修正：將 Id 轉換為 String
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 16),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) {
                ref
                    .read(expenseProvider.notifier)
                    .deleteExpense(expense.id);
              },
              child: ListTile(
                title: Text(expense.title),
                subtitle:
                Text("${expense.amount} 元 - ${expense.category}"),
                trailing: Text(
                  _formatDate(expense.date),
                  style: Theme
                      .of(context)
                      .textTheme
                      .bodySmall,
                ),
              ),
            );
          },
        ),
      );
    }

    Widget buildAnalytics() {
      return SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            const Text(
              '類別比例',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 200,
              child: PieChartWidget(expenses: expenses),
            ),
            const Text(
              '每月支出',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 200,
              child: BarChartWidget(expenses: expenses),
            ),
          ],
        ),
      );
    }

    void showAddExpenseDialog() {
      final titleController = TextEditingController();
      final amountController = TextEditingController();

      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              String dialogSelectedCategory = Consts.catagoryList.first;

              return AlertDialog(
                title: const Text("新增支出"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: '支出標題'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: amountController,
                      decoration: const InputDecoration(labelText: '金額'),
                      keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: dialogSelectedCategory,
                      items: Consts.catagoryList
                          .map((c) =>
                          DropdownMenuItem(
                            value: c,
                            child: Text(c),
                          ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          dialogSelectedCategory = value!;
                        });
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('取消'),
                  ),
                  TextButton(
                    onPressed: () {
                      if (titleController.text.isEmpty ||
                          amountController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('請填寫所有欄位')),
                        );
                        return;
                      }

                      final amount = double.tryParse(amountController.text);
                      if (amount == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('請輸入有效的金額')),
                        );
                        return;
                      }

                      final expense = Expense()
                        ..title = titleController.text
                        ..amount = amount
                        ..category = dialogSelectedCategory
                        ..date = DateTime.now();

                      ref.read(expenseProvider.notifier).addExpense(expense);
                      Navigator.pop(context);
                    },
                    child: const Text('新增'),
                  ),
                ],
              );
            },
          );
        },
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("零錢記帳"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "記帳"),
              Tab(text: "分析"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            buildExpenseList(),
            buildAnalytics(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => showAddExpenseDialog(),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day}';
  }
}
