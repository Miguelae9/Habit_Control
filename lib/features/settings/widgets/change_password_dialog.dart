import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:habit_control/features/habits/viewmodels/habit_catalog_view_model.dart';
import 'package:habit_control/features/habits/viewmodels/habit_day_view_model.dart';
import 'package:habit_control/features/input_log/viewmodels/metrics_view_model.dart';
import 'package:habit_control/features/settings/viewmodels/settings_view_model.dart';

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final TextEditingController _currentCtrl = TextEditingController();
  final TextEditingController _newCtrl = TextEditingController();
  final TextEditingController _confirmCtrl = TextEditingController();

  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving) return;

    final String current = _currentCtrl.text;
    final String next = _newCtrl.text;
    final String confirm = _confirmCtrl.text;

    if (current.isEmpty || next.isEmpty || confirm.isEmpty) {
      setState(() => _error = 'Complete all fields.');
      return;
    }

    if (next != confirm) {
      setState(() => _error = 'New passwords do not match.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    final viewModel = SettingsViewModel(
      habitCatalog: context.read<HabitCatalogViewModel>(),
      habitDay: context.read<HabitDayViewModel>(),
      metrics: context.read<MetricsViewModel>(),
    );

    final String? errorMessage = await viewModel.changePassword(
      currentPassword: current,
      newPassword: next,
    );

    if (!mounted) return;

    if (errorMessage != null) {
      setState(() {
        _saving = false;
        _error = errorMessage;
      });
      return;
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change password'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _currentCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Current password'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _newCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New password'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm new password',
              ),
            ),
            if (_error != null) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _submit,
          child: Text(_saving ? 'SAVING...' : 'SAVE'),
        ),
      ],
    );
  }
}
