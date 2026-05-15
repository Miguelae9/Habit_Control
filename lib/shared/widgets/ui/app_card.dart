import 'package:flutter/material.dart';

/// Reusable app card based on the global theme.
///
/// Keeps visual sections consistent across screens.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin,
      child: Padding(padding: padding, child: child),
    );
  }
}
