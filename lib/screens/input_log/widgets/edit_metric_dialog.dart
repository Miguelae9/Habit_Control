import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:habit_control/screens/input_log/models/metric_definition.dart';
import 'package:habit_control/shared/state/daily_metrics_store.dart';

class EditMetricDialog extends StatefulWidget {
  final MetricDefinition definition;

  const EditMetricDialog({super.key, required this.definition});

  @override
  State<EditMetricDialog> createState() => _EditMetricDialogState();
}

class _EditMetricDialogState extends State<EditMetricDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _unitCtrl;

  late String _semanticCategory;
  late String _valueType;
  late String _interpretation;

  bool _saving = false;
  String? _error;

  final List<DropdownMenuItem<String>> _categoryItems =
      const <DropdownMenuItem<String>>[
        DropdownMenuItem(value: 'sleep', child: Text('Sleep')),
        DropdownMenuItem(value: 'energy', child: Text('Energy')),
        DropdownMenuItem(value: 'social', child: Text('Social')),
        DropdownMenuItem(value: 'mood', child: Text('Mood')),
        DropdownMenuItem(value: 'focus', child: Text('Focus')),
        DropdownMenuItem(value: 'nutrition', child: Text('Nutrition')),
        DropdownMenuItem(value: 'exercise', child: Text('Exercise')),
        DropdownMenuItem(value: 'custom', child: Text('Custom')),
      ];

  final List<DropdownMenuItem<String>> _valueTypeItems =
      const <DropdownMenuItem<String>>[
        DropdownMenuItem(value: 'int', child: Text('Integer')),
        DropdownMenuItem(value: 'double', child: Text('Decimal')),
      ];

  final List<DropdownMenuItem<String>>
  _interpretationItems = const <DropdownMenuItem<String>>[
    DropdownMenuItem(value: 'higher_better', child: Text('Higher is Better')),
    DropdownMenuItem(value: 'lower_better', child: Text('Lower is Better')),
    DropdownMenuItem(value: 'neutral', child: Text('Neutral')),
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.definition.name);
    _unitCtrl = TextEditingController(text: widget.definition.unit ?? '');
    _semanticCategory = widget.definition.semanticCategory;
    _valueType = widget.definition.valueType;
    _interpretation = widget.definition.interpretation;
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final unit = _unitCtrl.text.trim();

    if (name.isEmpty) {
      setState(() {
        _error = 'Please enter a name.';
      });
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await context.read<DailyMetricsStore>().updateMetricDefinition(
        id: widget.definition.id,
        name: name,
        semanticCategory: _semanticCategory,
        valueType: _valueType,
        interpretation: _interpretation,
        unit: unit.isEmpty ? null : unit,
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'Failed to update the metric.';
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _unitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Edit Metric'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Example: Motivation',
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _semanticCategory,
              items: _categoryItems,
              decoration: const InputDecoration(
                labelText: 'Semantic Category',
              ),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _semanticCategory = value;
                });
              },
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _valueType,
              items: _valueTypeItems,
              decoration: const InputDecoration(labelText: 'Value Type'),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _valueType = value;
                });
              },
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _unitCtrl,
              decoration: const InputDecoration(
                labelText: 'Unit (optional)',
                hintText: 'Example: h, /10, glasses',
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _interpretation,
              items: _interpretationItems,
              decoration: const InputDecoration(labelText: 'Interpretation'),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _interpretation = value;
                });
              },
            ),
            if (_error != null) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.redAccent,
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
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
