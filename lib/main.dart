import 'package:expense_management_app/providers/expense_provider.dart';
import 'package:expense_management_app/screens/about_screen.dart';
import 'package:expense_management_app/screens/add_expense_screen.dart';
import 'package:expense_management_app/screens/category_management_screen.dart';
import 'package:expense_management_app/screens/home_screen.dart';
import 'package:expense_management_app/screens/splash_screen.dart';
import 'package:expense_management_app/screens/tag_management_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const ExpenseManager());
}

class ExpenseManager extends StatelessWidget {
  const ExpenseManager({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ExpenseProvider(),
      child: MaterialApp(
        title: "Expense Manager",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          scaffoldBackgroundColor: Colors.teal.shade100
        ),
        initialRoute: '/',
        routes: {
          '/': (_) => SplashScreen(),
          '/home': (_) => HomeScreen(),
          '/about': (_) => AboutScreen(),
          '/category': (_) => CategoryManagementScreen(),
          '/tag': (_) => TagManagementScreen(),
          '/expense_form': (_) => AddExpenseScreen(),
          '/manage_tags': (_) => TagManagementScreen(),
          '/manage_categories': (_) => CategoryManagementScreen()
        },
      ),
    );
  }
}
