import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tag.dart';
import '../providers/expense_provider.dart';

class TagManagementScreen extends StatefulWidget {
  const TagManagementScreen({super.key});

  @override
  State<TagManagementScreen> createState() => _TagManagementScreenState();
}

class _TagManagementScreenState extends State<TagManagementScreen> {

  void _saveTag(String name, int? id) {
    if (name.isEmpty) return;

    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);

    final newTag = Tag(
      id: id ?? DateTime.now().millisecondsSinceEpoch,
      name: name,
    );

    if (id == null) {
      expenseProvider.addTag(newTag);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${newTag.name} tag added.')),
      );
    } else {
      expenseProvider.updateTag(newTag);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${newTag.name} tag updated.')),
      );
    }
  }

  Future<void> _confirmAndDeleteTag(BuildContext context, Tag tag) async {
    // Prevent deletion of default tag
    if (tag.id == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot delete the default "None" tag.')),
      );
      return;
    }

    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete the tag: "${tag.name}"? This will update associated expenses to "None".'),
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
      expenseProvider.deleteTag(tag.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${tag.name} tag deleted.')),
      );
    }
  }

  void _showTagForm({Tag? tag}) {
    // Prevent editing of default tag
    if (tag != null && tag.id == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot edit the default "None" tag.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _TagFormDialog(
          tag: tag,
          onSave: _saveTag,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Tags'),
        backgroundColor: Colors.grey.shade300,
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          final tags = provider.tags;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Manage your tags here. Add new tags, edit existing ones, or delete tags you no longer need.',
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
                child: tags.isEmpty
                    ? const Center(child: Text('No tags added yet.'))
                    : ListView.builder(
                  itemCount: tags.length,
                  itemBuilder: (context, index) {
                    final tag = tags[index];
                    final isDefault = tag.id == -1;

                    return ListTile(
                      leading: const Icon(Icons.label_outline, color: Colors.blueGrey),
                      title: Text(tag.name),
                      trailing: isDefault
                          ? const Chip(
                        label: Text('Default', style: TextStyle(fontSize: 10)),
                        backgroundColor: Colors.grey,
                      )
                          : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20, color: Colors.indigo),
                            onPressed: () => _showTagForm(tag: tag),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                            onPressed: () => _confirmAndDeleteTag(context, tag),
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
        onPressed: () => _showTagForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _TagFormDialog extends StatefulWidget {
  final Tag? tag;
  final Function(String name, int? id) onSave;

  const _TagFormDialog({
    this.tag,
    required this.onSave,
  });

  @override
  State<_TagFormDialog> createState() => _TagFormDialogState();
}

class _TagFormDialogState extends State<_TagFormDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.tag?.name ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.tag == null ? 'Add New Tag' : 'Edit ${widget.tag!.name}'),
      content: TextField(
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Tag Name'),
        controller: _controller,
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          onPressed: () {
            if (_controller.text.isNotEmpty) {
              widget.onSave(_controller.text, widget.tag?.id);
              Navigator.of(context).pop();
            }
          },
          child: Text(widget.tag == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }
}