import 'package:flutter/material.dart';

import 'pantallas/pantalla_login.dart';
import 'tema/colores_app.dart';

void main() => runApp(const AplicacionSire());

class AplicacionSire extends StatelessWidget {
  const AplicacionSire({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIRE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: ColoresApp.azulMarino),
      ),
      home: const PantallaLogin(),
    );
  }
}