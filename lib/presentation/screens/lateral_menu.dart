import 'package:flutter/material.dart';

class LateralMenu extends StatelessWidget {
  const LateralMenu({super.key});

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0B0F14);
    const card = Color(0xFF141A22);
    const border = Color(0xFF1F2A37);
    const accent = Color(0xFF6CFAFF);
    const textMain = Color(0xFFE5E7EB);
    const textMuted = Color(0xFF9CA3AF);

    final currentRoute = ModalRoute.of(context)?.settings.name;

    Widget item({
      required String label,
      required VoidCallback onTap,
      bool selected = false,
    }) {
      return Container(
        height: 48,
        decoration: const BoxDecoration(
          color: card,
          border: Border(
            top: BorderSide(color: border),
            bottom: BorderSide(color: border),
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Text(
                  '>',
                  style: TextStyle(
                    color: selected ? accent : textMuted,
                    fontSize: 12,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? accent : textMuted,
                    fontSize: 12,
                    letterSpacing: 1.6,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      color: bg,
      child: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
              child: Column(
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/imgs/habit_control_logo.png',
                        width: 150,
                        height: 150,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    'HABIT\nCONTROL',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textMain,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                      letterSpacing: 1.8,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            // Separador fino
            Container(height: 1, color: border),

            // ITEMS (selected dinámico según ruta)
            item(
              label: 'DASHBOARD',
              selected: currentRoute == '/dashboard',
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/dashboard');
              },
            ),
            item(
              label: 'REGISTRO DE DATOS',
              selected: currentRoute == '/data_logging',
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/data_logging');
              },
            ),
            item(
              label: 'ANALÍTICAS',
              selected: currentRoute == '/analytics',
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/analytics');
              },
            ),
            item(
              label: 'ACERCA DE',
              selected: currentRoute == '/credits',
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/credits');
              },
            ),

            const Spacer(),

            item(
              label: 'CERRAR SESIÓN',
              selected: currentRoute == '/home',
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
          ],
        ),
      ),
    );
  }
}
