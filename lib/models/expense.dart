import 'package:isar/isar.dart';

part 'expense.g.dart';

@Collection()
class Expense{
  ///自動產生的ID
  Id id = Isar.autoIncrement;
  ///支出標題
  late String title;
  ///金額
  late double amount;
  ///類別
  late String category;
  ///消費日期
  late DateTime date;
}