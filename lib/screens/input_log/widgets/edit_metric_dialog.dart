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
        DropdownMenuItem(value: 'sleep', child: Text('Sueño')),
        DropdownMenuItem(value: 'energy', child: Text('Energía')),
        DropdownMenuItem(value: 'social', child: Text('Social')),
        DropdownMenuItem(value: 'mood', child: Text('Estado de ánimo')),
        DropdownMenuItem(value: 'focus', child: Text('Concentración')),
        DropdownMenuItem(value: 'nutrition', child: Text('Nutrición')),
        DropdownMenuItem(value: 'exercise', child: Text('Ejercicio')),
        DropdownMenuItem(value: 'custom', child: Text('Personalizada')),
      ];

  final List<DropdownMenuItem<String>> _valueTypeItems =
      const <DropdownMenuItem<String>>[
        DropdownMenuItem(value: 'int', child: Text('Entero')),
        DropdownMenuItem(value: 'double', child: Text('Decimal')),
      ];

  final List<DropdownMenuItem<String>>
  _interpretationItems = const <DropdownMenuItem<String>>[
    DropdownMenuItem(value: 'higher_better', child: Text('Más alto = mejor')),
    DropdownMenuItem(value: 'lower_better', child: Text('Más bajo = mejor')),
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
        _error = 'Introduce un nombre.';
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
        _error = 'No se pudo actualizar la métrica.';
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
      title: const Text('Editar métrica'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                hintText: 'Ej: Motivación',
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _semanticCategory,
              items: _categoryItems,
              decoration: const InputDecoration(
                labelText: 'Categoría semántica',
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
              decoration: const InputDecoration(labelText: 'Tipo de valor'),
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
                labelText: 'Unidad (opcional)',
                hintText: 'Ej: h, /10, vasos',
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _interpretation,
              items: _interpretationItems,
              decoration: const InputDecoration(labelText: 'Interpretación'),
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
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Guardar'),
        ),
      ],
    );
  }
}
