import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final bool showUpArrow;
  final Color textMain;
  final Color borderColor;
  final Color bg;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.showUpArrow,
    required this.textMain,
    required this.borderColor,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool compact = width < 380;

    return Container(
      constraints: const BoxConstraints(minHeight: 92),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 14,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: compact ? 9 : 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: textMain.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (showUpArrow) ...[
                Icon(
                  Icons.arrow_upward,
                  size: compact ? 13 : 15,
                  color: textMain,
                ),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: compact ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: textMain,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
