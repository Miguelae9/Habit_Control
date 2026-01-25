class HabitModel {
  // 1. LOS DATOS (¿Qué tiene un hábito?)
  final String id;                  // El dni del hábito (para no confundirlos)
  final String title;               // El nombre (ej: "Ir al gym")
  final int currentStreak;          // La racha actual (ej: 5 días)
  final DateTime? lastCompletedDate; // ¿Cuándo se hizo por última vez? (Puede ser nulo si nunca se ha hecho)

  // 2. EL CONSTRUCTOR (¿Cómo se crea un hábito nuevo en la app?)
  HabitModel({
    required this.id,
    required this.title,
    this.currentStreak = 0, // Por defecto la racha empieza en 0
    this.lastCompletedDate, // Por defecto es nulo (nadie lo ha completado aun)
  });

  // 3. EL TRADUCTOR: DE FIREBASE A TU APP (fromMap)
  // Firebase nos da un "Map" (que es como una lista de variables sueltas).
  // Nosotros queremos convertir eso en un objeto HabitModel ordenado.
  factory HabitModel.fromMap(Map<String, dynamic> mapa, String idDelDocumento) {
    
    // Paso A: Sacar la fecha.
    // Firebase guarda las fechas como TEXTO, así que hay que convertirlas.
    DateTime? fechaProcesada;
    
    if (mapa['lastCompletedDate'] != null) {
      // Si hay fecha guardada, la convertimos de texto a fecha real
      fechaProcesada = DateTime.parse(mapa['lastCompletedDate']);
    } else {
      // Si no hay fecha, se queda en null
      fechaProcesada = null;
    }

    // Paso B: Crear el objeto final
    return HabitModel(
      id: idDelDocumento,
      title: mapa['title'], // Cogemos el título del mapa
      currentStreak: mapa['currentStreak'], // Cogemos la racha
      lastCompletedDate: fechaProcesada, // Usamos la fecha que calculamos arriba
    );
  }

  // 4. EL TRADUCTOR: DE TU APP A FIREBASE (toMap)
  // Firebase no entiende nuestros objetos. Quiere un "Map" simple.
  // Aquí convertimos nuestro Hábito en una lista simple de datos.
  Map<String, dynamic> toMap() {
    
    // Convertimos la fecha a texto para que Firebase la entienda
    String? fechaEnTexto;
    
    if (lastCompletedDate != null) {
      fechaEnTexto = lastCompletedDate!.toIso8601String(); // Convierte fecha a texto ISO
    } else {
      fechaEnTexto = null;
    }

    return {
      'title': title,
      'currentStreak': currentStreak,
      'lastCompletedDate': fechaEnTexto,
    };
  }

  // 5. UNA PREGUNTA ÚTIL (Lógica)
  // Esta función nos dice si el hábito ya se completó HOY.
  // Devuelve 'true' (verdadero) o 'false' (falso).
  bool isCompletedToday() {
    // Si nunca se ha completado, obviamente no se hizo hoy
    if (lastCompletedDate == null) {
      return false;
    }

    // Sacamos la fecha de HOY
    final fechaDeHoy = DateTime.now();

    // Comparamos: ¿El año, mes y día coinciden?
    if (lastCompletedDate!.year == fechaDeHoy.year &&
        lastCompletedDate!.month == fechaDeHoy.month &&
        lastCompletedDate!.day == fechaDeHoy.day) {
      return true; // Sí, se hizo hoy
    } else {
      return false; // No, se hizo otro día
    }
  }
}