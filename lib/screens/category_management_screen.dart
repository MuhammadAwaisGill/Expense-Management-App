import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../providers/expense_provider.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {

  void _saveCategory(String name, int colorValue, int? id) {
    if (name.isEmpty) return;

    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);

    final newCategory = Category(
      id: id ?? DateTime.now().millisecondsSinceEpoch,
      name: name,
      colorValue: colorValue,
    );

    if (id == null) {
      expenseProvider.addCategory(newCategory);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${newCategory.name} category added.')),
      );
    } else {
      expenseProvider.updateCategory(newCategory);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${newCategory.name} category updated.')),
      );
    }
  }

  Future<void> _confirmAndDeleteCategory(BuildContext context, Category category) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete the category: "${category.name}"? This will move associated expenses to "Uncategorized".'),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
      expenseProvider.deleteCategory(category.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${category.name} category deleted.')),
      );
    }
  }

  void _showCategoryForm({Category? category}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _CategoryFormDialog(
          category: category,
          onSave: _saveCategory,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
        backgroundColor: Colors.grey.shade300,
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          final categories = provider.categories;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Manage your categories here. Add new categories, edit existing ones, or delete categories you no longer need.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const Divider(height: 1),

              Expanded(
                child: categories.isEmpty
                    ? const Center(child: Text('No categories added yet.'))
                    : ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Color(category.colorValue),
                        radius: 12,
                      ),
                      title: Text(category.name),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20, color: Colors.indigo),
                            onPressed: () => _showCategoryForm(category: category),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                            onPressed: () => _confirmAndDeleteCategory(context, category),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CategoryFormDialog extends StatefulWidget {
  final Category? category;
  final Function(String name, int colorValue, int? id) onSave;

  const _CategoryFormDialog({
    this.category,
    required this.onSave,
  });

  @override
  State<_CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<_CategoryFormDialog> {
  late TextEditingController _controller;
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.category?.name ?? '');
    _selectedColor = Color(widget.category?.colorValue ?? Colors.grey.value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.category == null ? 'Add New Category' : 'Edit ${widget.category!.name}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Category Name'),
            controller: _controller,
          ),
          const SizedBox(height: 20),

          const Text('Select Color:'),
          const SizedBox(height: 8),
          SizedBox(
            width: 300,
            height: 200,
            child: BlockPicker(
              pickerColor: _selectedColor,
              onColorChanged: (color) {
                setState(() {
                  _selectedColor = color;
                });
              },
              availableColors: const [
                Colors.red, Colors.pink, Colors.purple, Colors.deepPurple,
                Colors.indigo, Colors.blue, Colors.lightBlue, Colors.cyan,
                Colors.teal, Colors.green, Colors.lightGreen, Colors.lime,
                Colors.yellow, Colors.amber, Colors.orange, Colors.deepOrange,
                Colors.brown, Colors.grey, Colors.blueGrey, Colors.black,
              ],
              layoutBuilder: (context, colors, child) => GridView.count(
                crossAxisCount: 5,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [for (Color color in colors) child(color)],
              ),
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          onPressed: () {
            if (_controller.text.isNotEmpty) {
              widget.onSave(_controller.text, _selectedColor.value, widget.category?.id);
              Navigator.of(context).pop();
            }
          },
          child: Text(widget.category == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }
}