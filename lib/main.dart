import 'package:expense_management_app/providers/expense_provider.dart';
import 'package:expense_management_app/screens/about_screen.dart';
import 'package:expense_management_app/screens/add_expense_screen.dart';
import 'package:expense_management_app/screens/category_management_screen.dart';
import 'package:expense_management_app/screens/home_screen.dart';
import 'package:expense_management_app/screens/splash_screen.dart';
import 'package:expense_management_app/screens/tag_management_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations (optional - locks to portrait)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const ExpenseManager());
  });
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
          scaffoldBackgroundColor: Colors.teal.shade100,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            brightness: Brightness.light,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.grey.shade300,
            foregroundColor: Colors.black,
            elevation: 2,
            centerTitle: true,
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (_) => const SplashScreen(),
          '/home': (_) => const HomeScreen(),
          '/about': (_) => const AboutScreen(),
          '/expense_form': (_) => const AddExpenseScreen(),
          '/manage_tags': (_) => const TagManagementScreen(),
          '/manage_categories': (_) => const CategoryManagementScreen(),
        },
      ),
    );
  }
}