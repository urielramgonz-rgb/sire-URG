import 'package:flutter/material.dart';

import '../datos/autenticacion.dart';
import '../modelos/usuario.dart';
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
  final _usuarioController = TextEditingController();
  final _pinController = TextEditingController();

  @override
  void dispose() {
    _usuarioController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _iniciarSesion() {
    final resultado = Autenticacion.instancia.iniciarSesion(
      _usuarioController.text,
      _pinController.text,
    );
    // El PIN nunca se conserva en pantalla después de intentar acceder.
    _pinController.clear();

    final usuario = resultado.usuario;
    if (usuario == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(resultado.mensaje ?? 'No se pudo iniciar sesión.'),
            backgroundColor: ColoresApp.rojo,
          ),
        );
      return;
    }

    final Widget destino = usuario.rol == RolUsuario.central
        ? const PantallaPanelCentral()
        : const PantallaPanelCampo();
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => destino));
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
                    const _EtiquetaCampo('Identificador de empleado o NIF'),
                    const SizedBox(height: 8),
                    _CajaEntrada(controlador: _usuarioController),
                    const SizedBox(height: 22),
                    const _EtiquetaCampo('PIN'),
                    const SizedBox(height: 8),
                    _CajaEntrada(
                      controlador: _pinController,
                      ocultar: true,
                      alEnviar: _iniciarSesion,
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
  final VoidCallback? alEnviar;

  const _CajaEntrada({
    required this.controlador,
    this.ocultar = false,
    this.alEnviar,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controlador,
      obscureText: ocultar,
      autocorrect: false,
      enableSuggestions: !ocultar,
      keyboardType: ocultar ? TextInputType.number : TextInputType.text,
      onSubmitted: alEnviar == null ? null : (_) => alEnviar!(),
      style: const TextStyle(fontSize: 18, color: ColoresApp.tinta),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
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
