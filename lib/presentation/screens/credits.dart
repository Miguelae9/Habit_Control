import 'package:flutter/material.dart';
import 'package:habit_control/presentation/screens/lateral_menu.dart';

class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: const Color(0xFF0B0F14)),
      drawer: const Drawer(
        backgroundColor: Color.fromARGB(34, 0, 70, 221),
        child: LateralMenu(),
      ),

      backgroundColor: const Color(0xFF0B0F14),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 24),

              const Text(
                'ARQUITECTURA DEL\nSISTEMA',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                  height: 1.2,
                  color: Color(0xFFE5E7EB),
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'CODE: [Miguel Ángel Pérez García]',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 1.2,
                  color: Color(0xFF9CA3AF),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'BUILD: v1.0.2',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 1.2,
                  color: Color(0xFF9CA3AF),
                ),
              ),

              const SizedBox(height: 32),

              const Text(
                'TECNOLOGÍAS',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  color: Color(0xFFE5E7EB),
                ),
              ),

              const SizedBox(height: 20),

              const _TechItem(text: 'FLUTTER FRAMEWORK'),
              const SizedBox(height: 12),
              const _TechItem(text: 'FIREBASE BACKEND'),
              const SizedBox(height: 12),
              const _TechItem(text: 'FL_CHART LIBRARY'),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6CFAFF),
                    foregroundColor: const Color(0xFF0B0F14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text(
                    'VOLVER',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                      fontSize: 12,
                    ),
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

class _TechItem extends StatelessWidget {
  final String text;
  const _TechItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 12,
        letterSpacing: 1.6,
        color: Color(0xFF9CA3AF),
      ),
    );
  }
}
