import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'presentation/my_app.dart';

void main() async {
  // 1. Aseguramos que los motores nativos estén listos
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Inicializamos Firebase (Esto fallará hasta que lo configuremos, pero déjalo puesto)
  // await Firebase.initializeApp(); 
  // NOTA: He comentado la línea de Firebase para que la app arranque ahora mismo sin error.
  // La descomentaremos cuando configuremos el proyecto en la consola de Firebase.

  // 3. Arrancamos la App
  runApp(const MyApp());
}