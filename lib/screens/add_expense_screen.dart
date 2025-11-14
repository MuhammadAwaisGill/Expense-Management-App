import 'package:expense_management_app/models/category.dart';
import 'package:expense_management_app/models/expense.dart';
import 'package:expense_management_app/models/tag.dart';
import 'package:expense_management_app/providers/expense_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  bool _isInitialized = false;
  bool _isEditMode = false;
  int? _editingExpenseId;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  DateTime _selectedDateTime = DateTime.now();
  Category? _selectedCategory;
  Tag? _selectedTag;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) {
        final provider = Provider.of<ExpenseProvider>(context, listen: false);
        setState(() {
          _selectedCategory = provider.defaultCategory;
          _selectedTag = provider.defaultTag;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final Expense? expense = ModalRoute.of(context)?.settings.arguments as Expense?;

    if (expense != null && !_isInitialized) {
      _isEditMode = true;
      _editingExpenseId = expense.id;

      _titleController.text = expense.title;
      _amountController.text = expense.amount.toString();
      _selectedCategory = expense.category;
      _selectedTag = expense.tag;

      try {
        final parts = expense.date.split('/');
        _selectedDateTime = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      } catch (e) {
        _selectedDateTime = DateTime.now();
      }

      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDateTime) {
      setState(() {
        _selectedDateTime = picked;
      });
    }
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategory == null || _selectedTag == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select category and tag')),
      );
      return;
    }

    final double amount = double.parse(_amountController.text);
    final String title = _titleController.text;
    final String dateString =
        "${_selectedDateTime.day.toString().padLeft(2, '0')}/${_selectedDateTime.month.toString().padLeft(2, '0')}/${_selectedDateTime.year.toString()}";

    if (_isEditMode && _editingExpenseId != null) {
      // Update existing expense
      final updatedExpense = Expense(
        id: _editingExpenseId!,
        amount: amount,
        title: title,
        date: dateString,
        category: _selectedCategory!,
        tag: _selectedTag!,
      );
      Provider.of<ExpenseProvider>(context, listen: false).updateExpense(updatedExpense);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense updated successfully!')),
      );
    } else {
      // Add new expense
      final int id = DateTime.now().millisecondsSinceEpoch;
      final newExpense = Expense(
        id: id,
        amount: amount,
        title: title,
        date: dateString,
        category: _selectedCategory!,
        tag: _selectedTag!,
      );
      Provider.of<ExpenseProvider>(context, listen: false).addExpense(newExpense);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense added successfully!')),
      );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final availableCategories = provider.categories;
    final availableTags = provider.tags;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Expense' : 'Add New Expense'),
        centerTitle: true,
        backgroundColor: Colors.grey.shade300,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('Amount', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Enter amount (e.g, 100)',
                  prefixIcon: Icon(Icons.monetization_on),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter an amount.';
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Please enter a valid positive amount.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              const Text('Title', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                maxLength: 100,
                decoration: const InputDecoration(
                  labelText: 'Title or brief note for the expense',
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter a title.';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              const Text('Category (Optional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<Category>(
                decoration: const InputDecoration(
                  labelText: 'Select Category',
                  border: OutlineInputBorder(),
                ),
                value: _selectedCategory != null
                    ? availableCategories.firstWhere(
                      (cat) => cat.id == _selectedCategory!.id,
                  orElse: () => availableCategories.first,
                )
                    : availableCategories.isNotEmpty ? availableCategories.first : null,
                isExpanded: true,
                items: availableCategories.map((category) {
                  return DropdownMenuItem<Category>(
                    value: category,
                    child: Row(
                      children: [
                        Icon(Icons.circle, color: Color(category.colorValue), size: 16),
                        const SizedBox(width: 8),
                        Text(category.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (Category? newValue) {
                  setState(() => _selectedCategory = newValue);
                },
              ),
              const SizedBox(height: 20),

              const Text('Tag (Optional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<Tag>(
                decoration: const InputDecoration(
                  labelText: 'Select Tag',
                  border: OutlineInputBorder(),
                ),
                value: _selectedTag != null
                    ? availableTags.firstWhere(
                      (tag) => tag.id == _selectedTag!.id,
                  orElse: () => availableTags.first,
                )
                    : availableTags.isNotEmpty ? availableTags.first : null,
                isExpanded: true,
                items: availableTags.map((tag) {
                  return DropdownMenuItem<Tag>(
                    value: tag,
                    child: Row(
                      children: [
                        const Icon(Icons.label_outline, color: Colors.blueGrey, size: 16),
                        const SizedBox(width: 8),
                        Text(tag.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (Tag? newValue) {
                  setState(() => _selectedTag = newValue);
                },
              ),
              const SizedBox(height: 20),

              const Text('Date', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Date: ${_selectedDateTime.day.toString().padLeft(2, '0')}/${_selectedDateTime.month.toString().padLeft(2, '0')}/${_selectedDateTime.year.toString()}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    TextButton(
                      onPressed: _selectDate,
                      child: const Text('CHANGE DATE'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submitForm,
                  icon: const Icon(Icons.save),
                  label: Text(
                    _isEditMode ? 'Update Expense' : 'Save Expense',
                    style: const TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}