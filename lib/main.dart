import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/screens/expense_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // 確保關閉所有現有實例
    for (final name in Isar.instanceNames) {
      await Isar.getInstance(name)?.close();
    }

    // 初始化 Isar
    final dir = await getApplicationDocumentsDirectory();
    await Isar.open(
      [ExpenseSchema],
      directory: dir.path,
      name: 'expense_db',
    );

    // 確認 Isar 已經成功初始化
    assert(Isar.getInstance('expense_db') != null, 'Failed to initialize Isar');

    runApp(const ProviderScope(child: MyApp()));
  } catch (e) {
    print('初始化錯誤: $e');
    // 這裡可以添加更多錯誤處理邏輯
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '記帳小程式',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueGrey,
          elevation: 2,
          titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.blueGrey
        )
      ),
      home: const ExpenseListScreen(),
    );
  }
}
