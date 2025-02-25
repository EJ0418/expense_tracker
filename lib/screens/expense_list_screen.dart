import 'package:expense_tracker/providers/expense_providers.dart';
import 'package:expense_tracker/widgets/BarChartWidget.dart';
import 'package:expense_tracker/widgets/pie_chart_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/consts.dart';
import '../models/expense.dart';

class ExpenseListScreen extends ConsumerStatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  ConsumerState<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends ConsumerState<ExpenseListScreen> {
  TextEditingController searchController = TextEditingController();
  String? selectedCategory;
  DateTime? startDate;
  DateTime? endDate;

  @override
  Widget build(BuildContext context) {
    final expenses = ref.watch(expenseProvider);

    Widget buildSearchBar() {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: searchController,
          decoration: InputDecoration(
              hintText: '搜尋支出...',
              prefixIcon: const Icon(Icons.search),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              filled: true,
              fillColor: Colors.white),
          onChanged: (value) {
            ref.read(expenseProvider.notifier).filterExpenses(keyword: value);
          },
        ),
      );
    }

    Widget buildExpenseList() {
      return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: expenses.isEmpty
              ? const Center(
                  child: Text('尚未有零錢支出紀錄'),
                )
              : ListView.builder(
                  key: ValueKey(expenses.length),
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: Dismissible(
                              key: ValueKey(expense.id.toString()),
                              // 修正：將 Id 轉換為 String
                              direction: DismissDirection.endToStart,
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 16),
                                child: const Icon(Icons.delete,
                                    color: Colors.white),
                              ),
                              onDismissed: (_) {
                                ref
                                    .read(expenseProvider.notifier)
                                    .deleteExpense(expense.id);
                              },
                              child: ListTile(
                                leading: Hero(
                                  tag: '支出：${expense.id}',
                                  child: CircleAvatar(
                                    backgroundColor:
                                        _getCategoryColor(expense.category),
                                    child: const Icon(
                                      Icons.monetization_on,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                title: Text(expense.title),
                                subtitle: Text(
                                    "${expense.amount} 元 - ${expense.category}"),
                                trailing: Text(
                                  _formatDate(expense.date),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            )));
                  },
                ));
    }

    Widget buildExpenseTab() {
      return Column(
        children: [buildSearchBar(), Expanded(child: buildExpenseList())],
      );
    }

    Widget buildAnalyticsTab() {
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

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("零錢記帳"),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(
                  child: Text(
                '記帳',
                style: TextStyle(color: Colors.white),
              )),
              Tab(
                child: Text(
                  '分析',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
                onPressed: () {
                  _showFilterDialog();
                },
                icon: const Icon(Icons.filter_list))
          ],
        ),
        body: TabBarView(
          children: [
            buildExpenseTab(),
            buildAnalyticsTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => showAddExpenseDialog(),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void showAddExpenseDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        String dialogSelectedCategory = Consts.catagoryList.first;
        return StatefulBuilder(
          builder: (context, setState) {
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
                        .map((c) => DropdownMenuItem(
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

  void _showFilterDialog() {
    // 創建臨時變數來存儲對話框中的選擇
    String? dialogSelectedCategory = selectedCategory;
    DateTime? dialogStartDate = startDate;
    DateTime? dialogEndDate = endDate;

    showDialog(
      context: context,
      builder: (context) {
        // 使用 StatefulBuilder 讓對話框內部可以有自己的狀態
        return StatefulBuilder(
          builder: (context, setState) {
            // 格式化日期顯示的輔助函數
            String formatDateForDisplay(DateTime? date) {
              if (date == null) return "";
              return '${date.year}/${date.month}/${date.day}';
            }

            return AlertDialog(
              title: const Text('篩選條件'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                      hint: const Text("選擇類別"),
                      value: dialogSelectedCategory,
                      items: [
                        // 添加一個「全部」選項
                        const DropdownMenuItem(value: null, child: Text("全部")),
                        ...Consts.catagoryList.map((c) {
                          return DropdownMenuItem(value: c, child: Text(c));
                        }).toList(),
                      ],
                      onChanged: (value) {
                        // 使用 StatefulBuilder 提供的 setState
                        setState(() {
                          dialogSelectedCategory = value;
                        });
                      }
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          dialogStartDate == null && dialogEndDate == null
                              ? "尚未選擇日期範圍"
                              : "日期範圍: ${formatDateForDisplay(dialogStartDate)} - ${formatDateForDisplay(dialogEndDate)}",
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ElevatedButton(
                      onPressed: () async {
                        DateTimeRange? picked = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2000, 1, 1),
                            lastDate: DateTime.now()
                        );
                        if (picked != null) {
                          // 使用 StatefulBuilder 提供的 setState
                          setState(() {
                            dialogStartDate = picked.start;
                            dialogEndDate = picked.end;
                          });
                        }
                      },
                      child: const Text("選擇日期範圍")
                  ),
                  if (dialogStartDate != null && dialogEndDate != null)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          dialogStartDate = null;
                          dialogEndDate = null;
                        });
                      },
                      child: const Text("清除日期選擇"),
                    ),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('取消')
                ),
                TextButton(
                    onPressed: () {
                      // 當確認按鈕被點擊時，更新主 widget 的狀態並過濾
                      setState(() {
                        selectedCategory = dialogSelectedCategory;
                        startDate = dialogStartDate;
                        endDate = dialogEndDate;
                      });

                      ref.read(expenseProvider.notifier).filterExpenses(
                          category: dialogSelectedCategory,
                          startDate: dialogStartDate,
                          endDate: dialogEndDate
                      );
                      Navigator.pop(context);
                    },
                    child: const Text('確定')
                )
              ],
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day}';
  }

  Color _getCategoryColor(String category) {
    switch (category) {
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
