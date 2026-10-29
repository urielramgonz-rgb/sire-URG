import 'package:flutter/material.dart';

import '../tema/colores_app.dart';
import 'pantalla_panel_central.dart';
import 'pantalla_panel_campo.dart';
import 'pantalla_seguridad.dart';

class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  late TextEditingController _usuarioController;
  late TextEditingController _pinController;

  @override
  void initState() {
    super.initState();
    // Valores por defecto exactos para facilitar pruebas
    _usuarioController = TextEditingController(text: 'Uriel Ramírez');
    _pinController = TextEditingController(text: '1234');
  }

  @override
  void dispose() {
    _usuarioController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _iniciarSesion() {
    // Se lee el texto tal cual, sin convertir a minúsculas
    final usuario = _usuarioController.text.trim();
    final pin = _pinController.text.trim();

    // Validación exacta para el perfil de Central
    if (usuario == 'Uriel Ramírez' && pin == '1234') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const PantallaPanelCentral()),
      );
    } 
    // Validación exacta para el perfil de Campo
    else if (usuario == 'Juan González' && pin == '5678') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const PantallaPanelCampo()),
      );
    } 
    // Credenciales incorrectas
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuario o PIN incorrecto. Revisa mayúsculas y acentos.'),
          backgroundColor: ColoresApp.rojo,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const _Encabezado(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _EtiquetaCampo('Usuario'),
                    const SizedBox(height: 8),
                    _CajaEntrada(
                      controlador: _usuarioController,
                    ),
                    const SizedBox(height: 22),
                    const _EtiquetaCampo('PIN'),
                    const SizedBox(height: 8),
                    _CajaEntrada(
                      controlador: _pinController,
                      ocultar: true,
                    ),
                    const SizedBox(height: 28),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColoresApp.azulMarino,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(58),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _iniciarSesion,
                      child: const Text(
                        'INGRESAR',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PantallaSeguridad(),
                        ),
                      ),
                      icon: const Icon(Icons.lock_reset_outlined),
                      label: const Text('Cambiar PIN'),
                      style: TextButton.styleFrom(
                        foregroundColor: ColoresApp.azulMarino,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(32, 40, 32, 36),
      color: ColoresApp.azulMarino,
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: ColoresApp.rojo, size: 44),
          ),
          const SizedBox(height: 14),
          const Text(
            'SIRE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Sistema de Registro de Emergencias',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFFD7E4EC), fontSize: 15),
          ),
          const SizedBox(height: 4),
          const Text(
            'Bomberos y Paramédicos SMA',
            style: TextStyle(
              color: Color(0xFF8FC5E8),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _EtiquetaCampo extends StatelessWidget {
  final String texto;
  const _EtiquetaCampo(this.texto);

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: ColoresApp.atenuado,
      ),
    );
  }
}

class _CajaEntrada extends StatelessWidget {
  final TextEditingController controlador;
  final bool ocultar;

  const _CajaEntrada({
    required this.controlador,
    this.ocultar = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controlador,
      obscureText: ocultar,
      style: const TextStyle(fontSize: 18, color: ColoresApp.tinta),
      decoration: InputDecoration(
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: ColoresApp.linea, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: ColoresApp.azulMarino, width: 2),
        ),
      ),
    );
  }
}
