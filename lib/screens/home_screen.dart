import 'package:expense_management_app/models/category.dart';
import 'package:expense_management_app/models/tag.dart';
import 'package:expense_management_app/models/expense.dart';
import 'package:expense_management_app/providers/expense_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedMonth = 'All';
  int _selectedYear = DateTime.now().year;
  String _searchTerm = '';
  Category? _selectedCategory;
  Tag? _selectedTag;
  bool _showFilters = false;

  List<int> _getYearList() {
    final currentYear = DateTime.now().year;
    return List.generate(10, (index) => currentYear - index);
  }

  List<Expense> _getFilteredExpenses(List<Expense> allExpenses) {
    List<Expense> filtered = allExpenses;

    if (_selectedMonth != 'All') {
      final monthIndex = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ].indexOf(_selectedMonth) + 1;

      filtered = filtered.where((e) {
        try {
          final parts = e.date.split('/');
          final expenseMonth = int.parse(parts[1]);
          final expenseYear = int.parse(parts[2]);
          return expenseMonth == monthIndex && expenseYear == _selectedYear;
        } catch (e) {
          return false;
        }
      }).toList();
    }

    if (_searchTerm.isNotEmpty) {
      final lowerCaseSearch = _searchTerm.toLowerCase();
      filtered = filtered.where((e) => e.title.toLowerCase().contains(lowerCaseSearch)).toList();
    }

    if (_selectedCategory != null) {
      filtered = filtered.where((e) => e.category.id == _selectedCategory!.id).toList();
    }

    if (_selectedTag != null) {
      filtered = filtered.where((e) => e.tag.id == _selectedTag!.id).toList();
    }

    return filtered;
  }

  void _showMonthYearPicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'Select Month & Year',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Year',
                      ),
                      value: _selectedYear,
                      items: _getYearList()
                          .map((y) => DropdownMenuItem(value: y, child: Text(y.toString())))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedYear = v);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Month',
                      ),
                      value: _selectedMonth,
                      items: [
                        'All', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                      ].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedMonth = v);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Apply'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final List<Expense> displayExpenses = _getFilteredExpenses(provider.expenses);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Expense Manager"),
        centerTitle: true,
        backgroundColor: Colors.grey.shade300,
        elevation: 2,
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/about'),
            icon: const Icon(Icons.info),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/manage_tags'),
            icon: const Icon(Icons.label_outline),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/manage_categories'),
            icon: const Icon(Icons.category_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Card(
              color: Colors.grey.shade200,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Total Spent",
                          style: TextStyle(fontSize: 14, color: Colors.black),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          displayExpenses.fold<double>(0, (sum, e) => sum + e.amount).toStringAsFixed(2),
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedMonth == 'All'
                              ? "All Time"
                              : "$_selectedMonth $_selectedYear",
                          style: const TextStyle(fontSize: 12, color: Colors.black),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        IconButton(
                          onPressed: _showMonthYearPicker,
                          icon: const Icon(Icons.calendar_month, size: 32),
                          tooltip: 'Select Month/Year',
                        ),
                        const Text('Filter', style: TextStyle(fontSize: 10, color: Colors.black)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() => _showFilters = !_showFilters);
                    },
                    icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
                    label: Text(_showFilters ? 'Hide Filters' : 'Show Filters'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                if (_selectedCategory != null || _selectedTag != null || _searchTerm.isNotEmpty)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _selectedCategory = null;
                        _selectedTag = null;
                        _searchTerm = '';
                      });
                    },
                    icon: const Icon(Icons.clear_all),
                    tooltip: 'Clear All Filters',
                  ),
              ],
            ),
          ),

          if (_showFilters)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
              child: Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search Expense',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    ),
                    onChanged: (s) => setState(() => _searchTerm = s),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<Category?>(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Category',
                            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          ),
                          value: _selectedCategory,
                          items: [
                            const DropdownMenuItem(value: null, child: Text('All')),
                            ...provider.categories.map((c) => DropdownMenuItem(value: c, child: Text(c.name))),
                          ],
                          onChanged: (c) => setState(() => _selectedCategory = c),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<Tag?>(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Tag',
                            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          ),
                          value: _selectedTag,
                          items: [
                            const DropdownMenuItem(value: null, child: Text('All')),
                            ...provider.tags.map((t) => DropdownMenuItem(value: t, child: Text(t.name))),
                          ],
                          onChanged: (t) => setState(() => _selectedTag = t),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          Expanded(
            child: ExpenseList(expenses: displayExpenses),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/expense_form'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ExpenseList extends StatelessWidget {
  final List<Expense> expenses;
  const ExpenseList({super.key, required this.expenses});

  void _navigateToEdit(BuildContext context, Expense expense) {
    Navigator.pushNamed(context, '/expense_form', arguments: expense);
  }

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return const Center(child: Text('No matching expenses found.'));
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.grey.shade300,
          child: const Row(
            children: [
              Icon(Icons.swipe_left, size: 18, color: Colors.grey),
              SizedBox(width: 8),
              Text(
                'Swipe left to delete an expense',
                style: TextStyle(fontSize: 12, color: Colors.black),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final expense = expenses[index];

              return Column(
                children: [
                  Dismissible(
                    key: ValueKey(expense.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (direction) async {
                      final bool? shouldDelete = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Confirm Deletion'),
                            content: Text('Are you sure you want to delete the expense: "${expense.title}"?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text('Delete', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          );
                        },
                      );
                      return shouldDelete;
                    },
                    onDismissed: (direction) {
                      Provider.of<ExpenseProvider>(context, listen: false).deleteExpense(expense.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${expense.title} deleted.')),
                      );
                    },
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Color(expense.category.colorValue),
                        child: Text(
                          expense.title[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(expense.title, style: TextStyle(fontWeight: FontWeight.bold),),
                      subtitle: Text('${expense.category.name} | Tag: ${expense.tag.name}'),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            expense.amount.toStringAsFixed(2),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(expense.date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      onTap: () => _navigateToEdit(context, expense),
                    ),
                  ),
                  const Divider(height: 1),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}