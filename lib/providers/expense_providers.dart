import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../models/expense.dart';

// 建立一個provider來提供Isar實例
final isarInstanceProvider = Provider<Isar>((ref) {
  if (!Isar.instanceNames.contains('expense_db')) {
    throw StateError('Isar has not been initialized');
  }
  return Isar.getInstance('expense_db')!;
});

final expenseProvider =
    StateNotifierProvider<ExpenseNotifier, List<Expense>>((ref) {
  final isar = ref.watch(isarInstanceProvider);
  return ExpenseNotifier(isar);
});

class ExpenseNotifier extends StateNotifier<List<Expense>> {
  final Isar _isar;
  List<Expense> allExpenses = [];

  ExpenseNotifier(this._isar) : super([]) {
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    try {
      final expenses = await _isar.expenses.where().sortByDateDesc().findAll();
      state = expenses;
    } catch (e) {
      print('載入支出錯誤: $e');
      state = []; // 發生錯誤時設定為空列表
    }
  }

  Future<void> addExpense(Expense expense) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.expenses.put(expense);
      });
      await loadExpenses();
    } catch (e) {
      print('新增支出錯誤: $e');
    }
  }

  Future<void> deleteExpense(int id) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.expenses.delete(id);
      });
      await loadExpenses();
    } catch (e) {
      print('刪除支出錯誤: $e');
    }
  }

  void filterByCategory(String category) {
    if (category == "全部") {
      state = allExpenses;
    } else {
      state = allExpenses.where((e) => e.category == category).toList();
    }
  }

  void filterExpenses({String keyword = '', String? category, DateTime? startDate, DateTime? endDate}) async{
    final allExpenses = await _isar.expenses.where().findAll();

    state = allExpenses.where((e){
      bool matchesKeyword = keyword.isEmpty || e.title.toLowerCase().contains(keyword.toLowerCase());
      bool matchesCategory = category == null || e.category == category;
      bool matchesDate = (startDate == null || e.date.isAfter(startDate)) && (endDate == null || e.date.isBefore(endDate));
      return matchesKeyword && matchesCategory && matchesDate;
    }).toList();


  }
}
