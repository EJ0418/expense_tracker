import 'package:expense_tracker/providers/expense_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/consts.dart';
import '../models/expense.dart';

class ExpenseListScreen extends ConsumerWidget {
  const ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expenseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('零錢記帳'),
      ),
      body: expenses.isEmpty
          ? const Center(
              child: Text('尚未有零錢支出紀錄'),
            )
          : ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final expense = expenses[index];
                return ListTile(
                  title: Text(expense.title),
                  subtitle: Text("${expense.amount} 元 - ${expense.category}"),
                  trailing: IconButton(
                      onPressed: () {
                        ref
                            .read(expenseProvider.notifier)
                            .deleteExpense(expense.id);
                      },
                      icon: const Icon(Icons.delete, color: Colors.red)),
                );
              }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExpenseDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddExpenseDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String selectedCategory = Consts.catagoryList.first;

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("新增支出"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: '支出標題'),
                ),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(labelText: '金額'),
                  keyboardType: TextInputType.number,
                ),
                DropdownButton<String>(
                    value: selectedCategory,
                    items: Consts.catagoryList
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(c),
                            ))
                        .toList(),
                    onChanged: (value) => selectedCategory = value!)
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('取消')),
              TextButton(
                  onPressed: () {
                    final expense = Expense()
                      ..title = titleController.text
                      ..amount = double.parse(amountController.text)
                      ..category = selectedCategory
                      ..date = DateTime.now();
                    ref.read(expenseProvider.notifier).addExpense(expense);
                    Navigator.pop(context);
                  },
                  child: const Text('新增'))
            ],
          );
        });
  }
}
