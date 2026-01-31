import 'package:flutter/material.dart';
import 'package:habit_control/presentation/screens/lateral_menu.dart';

// CAMBIO: Ahora es Stateful para poder modificar los números
class InputLogScreen extends StatefulWidget {
  const InputLogScreen({super.key});

  @override
  State<InputLogScreen> createState() => _InputLogScreenState();
}

class _InputLogScreenState extends State<InputLogScreen> {
  // VARIABLES DE ESTADO (Los datos que cambian)
  double horasSueno = 7.5; // 7.5 = 7 horas y media
  int energia = 85; // Porcentaje
  double horasRRSS = 4.5; // Horas
  double litrosAgua = 1.5; // NUEVA MÉTRICA

  // FUNCIONES DE AYUDA
  // Formatea 7.5 a "7h 30m"
  String formatearHoras(double valor) {
    int h = valor.floor();
    int m = ((valor - h) * 60).round();
    return '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),

      drawer: const Drawer(
        backgroundColor: Color.fromARGB(34, 0, 70, 221),
        child: LateralMenu(),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          // CAMBIO: Añadido Scroll por si la pantalla es pequeña al añadir más métricas
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // HEADER
                Row(
                  children: [
                    Builder(
                      builder: (context) {
                        return IconButton(
                          icon: const Icon(
                            Icons.menu,
                            color: Color(0xFFE5E7EB),
                          ),
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },
                        );
                      },
                    ),
                    const Spacer(),
                    const _OnlineBadge(),
                  ],
                ),

                const SizedBox(height: 26),

                // TÍTULOS
                const Text(
                  'DAILY METRICS',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    color: Color(0xFFE5E7EB),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'ENTER DATA FOR CALCULATION',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 2,
                    color: Color(0xFF9CA3AF),
                  ),
                ),

                const SizedBox(height: 28),

                // --- FILA 1: SUEÑO ---
                _MetricRow(
                  label: '> SLEEP HOURS',
                  value: formatearHoras(horasSueno),
                  onMinus: () {
                    setState(() {
                      if (horasSueno > 0) horasSueno -= 0.5; // Resta 30 min
                    });
                  },
                  onPlus: () {
                    setState(() {
                      if (horasSueno < 24) horasSueno += 0.5; // Suma 30 min
                    });
                  },
                ),
                const SizedBox(height: 22),

                // --- FILA 2: ENERGÍA ---
                _MetricRow(
                  label: '> ENERGY LEVEL',
                  value: '$energia%',
                  onMinus: () {
                    setState(() {
                      if (energia > 0) energia -= 5;
                    });
                  },
                  onPlus: () {
                    setState(() {
                      if (energia < 100) energia += 5;
                    });
                  },
                ),
                const SizedBox(height: 22),

                // --- FILA 3: REDES SOCIALES ---
                _MetricRow(
                  label: '> SOCIAL MEDIA TIME',
                  value: formatearHoras(horasRRSS),
                  onMinus: () {
                    setState(() {
                      if (horasRRSS > 0) horasRRSS -= 0.25; // Resta 15 min
                    });
                  },
                  onPlus: () {
                    setState(() {
                      horasRRSS += 0.25; // Suma 15 min
                    });
                  },
                ),

                const SizedBox(height: 22),

                // --- FILA 4: AGUA (NUEVA) ---
                _MetricRow(
                  label: '> WATER (LITERS)',
                  value: '${litrosAgua}L', // Muestra "1.5L"
                  onMinus: () {
                    setState(() {
                      if (litrosAgua > 0) litrosAgua -= 0.25; // Resta un vaso
                    });
                  },
                  onPlus: () {
                    setState(() {
                      litrosAgua += 0.25; // Suma un vaso
                    });
                  },
                ),

                const SizedBox(height: 40), // Espacio extra antes del botón
                // BOTÓN GUARDAR
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      // MOSTRAR AVISO (SnackBar)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'RECORD SAVED SUCCESSFULLY',
                            style: TextStyle(
                              color: Color(0xFF0B0F14),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: Color(0xFF6CFAFF),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6CFAFF),
                      foregroundColor: const Color(0xFF0B0F14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: const Text(
                      'SAVE RECORD',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ------------------ WIDGETS AUXILIARES ------------------ */

class _OnlineBadge extends StatelessWidget {
  const _OnlineBadge();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        _Dot(color: Color(0xFF22C55E)),
        SizedBox(width: 6),
        Text(
          'ONLINE',
          style: TextStyle(
            color: Color(0xFFE5E7EB),
            fontSize: 11,
            letterSpacing: 1.6,
          ),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

// CAMBIO: Ahora recibe funciones onMinus y onPlus
class _MetricRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onMinus; // Función al pulsar menos
  final VoidCallback onPlus; // Función al pulsar más

  const _MetricRow({
    required this.label,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            letterSpacing: 1.8,
            color: Color(0xFFE5E7EB),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            // Pasamos la función al botón
            _StepButton(kind: _StepKind.minus, onTap: onMinus),
            const SizedBox(width: 18),
            Expanded(
              child: Center(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    color: Color(0xFF7C8796),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 18),
            _StepButton(kind: _StepKind.plus, onTap: onPlus),
          ],
        ),
      ],
    );
  }
}

enum _StepKind { minus, plus }

class _StepButton extends StatelessWidget {
  final _StepKind kind;
  final VoidCallback onTap; // Necesitamos recibir el click aquí

  const _StepButton({required this.kind, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF6CFAFF);
    final isPlus = kind == _StepKind.plus;

    return SizedBox(
      width: 54,
      height: 54,
      child: OutlinedButton(
        onPressed: onTap, // Conectamos el click
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: isPlus ? accent : const Color(0xFF64748B)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          padding: EdgeInsets.zero,
        ),
        child: Icon(
          isPlus ? Icons.add : Icons.remove,
          color: isPlus ? accent : const Color(0xFF9CA3AF),
          size: 22,
        ),
      ),
    );
  }
}
