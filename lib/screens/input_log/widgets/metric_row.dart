import 'package:flutter/material.dart';
import 'step_button.dart';

/// Fila de métrica con etiqueta, valor, acciones y botones +/-.
class MetricRow extends StatelessWidget {
  final String label;
  final String value;
  final String? suffix;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  final Color textColor;
  final Color valueColor;
  final Color accent;

  const MetricRow({
    super.key,
    required this.label,
    required this.value,
    required this.onMinus,
    required this.onPlus,
    required this.textColor,
    required this.valueColor,
    required this.accent,
    this.suffix,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final hasSuffix = suffix != null && suffix!.trim().isNotEmpty;

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 1.8,
                  color: textColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (onEdit != null)
              IconButton(
                icon: Icon(Icons.edit_outlined, color: textColor, size: 18),
                tooltip: 'Editar métrica',
                onPressed: onEdit,
              ),
            if (onDelete != null)
              IconButton(
                icon: Icon(Icons.delete_outline, color: textColor, size: 18),
                tooltip: 'Eliminar métrica',
                onPressed: onDelete,
              ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: <Widget>[
            StepButton(isPlus: false, onTap: onMinus, accent: accent),
            const SizedBox(width: 18),
            Expanded(
              child: Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: value,
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                          color: valueColor,
                        ),
                      ),
                      if (hasSuffix)
                        TextSpan(
                          text: ' ${suffix!}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                            color: textColor,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 18),
            StepButton(isPlus: true, onTap: onPlus, accent: accent),
          ],
        ),
      ],
    );
  }
}
