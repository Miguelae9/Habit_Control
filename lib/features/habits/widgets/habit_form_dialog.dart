import 'package:flutter/material.dart';

import 'package:habit_control/features/habits/models/habit.dart';
import 'package:habit_control/features/habits/models/habit_category.dart';

class HabitDialogResult {
  const HabitDialogResult({required this.title, required this.category});

  final String title;
  final String category;
}

class HabitFormDialog extends StatefulWidget {
  const HabitFormDialog({super.key, this.habit});

  final Habit? habit;

  @override
  State<HabitFormDialog> createState() => _HabitFormDialogState();
}

class _HabitFormDialogState extends State<HabitFormDialog> {
  late final TextEditingController _titleCtrl;
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.habit?.title ?? '');
    _selectedCategory = widget.habit?.category ?? HabitCategory.custom;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.habit == null ? 'Create habit' : 'Edit habit'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(
              labelText: 'Name',
              hintText: 'Example: Read',
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedCategory,
            decoration: const InputDecoration(labelText: 'Category'),
            items: HabitCategory.values.map((String category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(HabitCategory.labelOf(category)),
              );
            }).toList(),
            onChanged: (String? value) {
              if (value == null) {
                return;
              }
              setState(() {
                _selectedCategory = value;
              });
            },
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }

  void _save() {
    final String title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      return;
    }

    Navigator.of(
      context,
    ).pop(HabitDialogResult(title: title, category: _selectedCategory));
  }
}
