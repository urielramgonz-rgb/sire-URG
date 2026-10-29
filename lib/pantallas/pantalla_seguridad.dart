import 'package:flutter/material.dart';

import '../componentes/barra_superior.dart';
import '../tema/colores_app.dart';
import 'pantalla_splash.dart';

/// Interfaz demostrativa de cambio de PIN y administración de sesiones.
/// No valida identidad contra un servicio ni almacena credenciales.
class PantallaSeguridad extends StatefulWidget {
  const PantallaSeguridad({super.key, this.sesionActiva = false});

  final bool sesionActiva;

  @override
  State<PantallaSeguridad> createState() => _PantallaSeguridadState();
}

class _PantallaSeguridadState extends State<PantallaSeguridad> {
  final _usuarioController = TextEditingController();
  final _pinActualController = TextEditingController();
  final _pinNuevoController = TextEditingController();
  final _confirmarPinController = TextEditingController();
  bool _identidadVerificada = false;
  bool _otraSesionActiva = true;

  @override
  void dispose() {
    _usuarioController.dispose();
    _pinActualController.dispose();
    _pinNuevoController.dispose();
    _confirmarPinController.dispose();
    super.dispose();
  }

  void _verificarIdentidad() {
    if (_usuarioController.text.trim().isEmpty ||
        _pinActualController.text.trim().length < 4) {
      _mensaje('Ingresa tu usuario y PIN actual para continuar.');
      return;
    }
    setState(() => _identidadVerificada = true);
  }

  void _guardarPin() {
    final nuevo = _pinNuevoController.text.trim();
    final confirmacion = _confirmarPinController.text.trim();
    if (nuevo.length < 4) {
      _mensaje('El nuevo PIN debe tener al menos 4 dígitos.');
      return;
    }
    if (nuevo != confirmacion) {
      _mensaje('Los PIN no coinciden.');
      return;
    }
    _mensaje('Interfaz lista: el cambio se guardará al conectar el servicio.');
  }

  void _mensaje(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }

  void _cerrarSesionActual() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const PantallaSplash()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.fondo,
      body: SafeArea(
        child: Column(
          children: [
            const BarraSuperiorSire(titulo: 'Seguridad', mostrarAtras: true),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _SeccionSeguridad(
                    icono: Icons.password_outlined,
                    titulo: 'Cambiar PIN',
                    descripcion: _identidadVerificada
                        ? 'Elige un PIN nuevo para tu cuenta.'
                        : 'Verifica tu identidad antes de cambiarlo.',
                    child: _identidadVerificada
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _CampoPin(
                                etiqueta: 'Nuevo PIN',
                                controlador: _pinNuevoController,
                              ),
                              const SizedBox(height: 12),
                              _CampoPin(
                                etiqueta: 'Confirmar nuevo PIN',
                                controlador: _confirmarPinController,
                              ),
                              const SizedBox(height: 16),
                              _BotonPrincipal(
                                etiqueta: 'GUARDAR NUEVO PIN',
                                alPresionar: _guardarPin,
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _CampoTexto(
                                etiqueta: 'Usuario',
                                controlador: _usuarioController,
                              ),
                              const SizedBox(height: 12),
                              _CampoPin(
                                etiqueta: 'PIN actual',
                                controlador: _pinActualController,
                              ),
                              const SizedBox(height: 16),
                              _BotonPrincipal(
                                etiqueta: 'VERIFICAR IDENTIDAD',
                                alPresionar: _verificarIdentidad,
                              ),
                            ],
                          ),
                  ),
                  if (widget.sesionActiva) ...[
                    const SizedBox(height: 22),
                    _SeccionSeguridad(
                      icono: Icons.devices_outlined,
                      titulo: 'Sesiones por dispositivo',
                      descripcion: 'Consulta y cierra sesiones individualmente.',
                      child: Column(
                        children: [
                          _FilaDispositivo(
                            icono: Icons.phone_android,
                            nombre: 'Este dispositivo',
                            detalle: 'Sesión actual · Activa',
                            actual: true,
                            alCerrar: _cerrarSesionActual,
                          ),
                          if (_otraSesionActiva) ...[
                            const Divider(height: 22),
                            _FilaDispositivo(
                              icono: Icons.computer_outlined,
                              nombre: 'Navegador web',
                              detalle: 'Otra sesión · Activa',
                              actual: false,
                              alCerrar: () => setState(
                                () => _otraSesionActiva = false,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  if (widget.sesionActiva) ...[
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: _cerrarSesionActual,
                      icon: const Icon(Icons.logout),
                      label: const Text('CERRAR SESIÓN EN ESTE DISPOSITIVO'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ColoresApp.rojo,
                        side: const BorderSide(color: ColoresApp.rojo),
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeccionSeguridad extends StatelessWidget {
  const _SeccionSeguridad({
    required this.icono,
    required this.titulo,
    required this.descripcion,
    required this.child,
  });

  final IconData icono;
  final String titulo;
  final String descripcion;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColoresApp.linea),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, color: ColoresApp.azulMarino),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    color: ColoresApp.tinta,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            descripcion,
            style: const TextStyle(color: ColoresApp.atenuado, fontSize: 13),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _CampoTexto extends StatelessWidget {
  const _CampoTexto({required this.etiqueta, required this.controlador});

  final String etiqueta;
  final TextEditingController controlador;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controlador,
    textInputAction: TextInputAction.next,
    decoration: InputDecoration(
      labelText: etiqueta,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}

class _CampoPin extends StatelessWidget {
  const _CampoPin({required this.etiqueta, required this.controlador});

  final String etiqueta;
  final TextEditingController controlador;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controlador,
    obscureText: true,
    keyboardType: TextInputType.number,
    maxLength: 8,
    decoration: InputDecoration(
      labelText: etiqueta,
      counterText: '',
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}

class _BotonPrincipal extends StatelessWidget {
  const _BotonPrincipal({required this.etiqueta, required this.alPresionar});

  final String etiqueta;
  final VoidCallback alPresionar;

  @override
  Widget build(BuildContext context) => ElevatedButton(
    onPressed: alPresionar,
    style: ElevatedButton.styleFrom(
      backgroundColor: ColoresApp.azulMarino,
      foregroundColor: Colors.white,
      minimumSize: const Size.fromHeight(50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
    ),
    child: Text(
      etiqueta,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
    ),
  );
}

class _FilaDispositivo extends StatelessWidget {
  const _FilaDispositivo({
    required this.icono,
    required this.nombre,
    required this.detalle,
    required this.actual,
    required this.alCerrar,
  });

  final IconData icono;
  final String nombre;
  final String detalle;
  final bool actual;
  final VoidCallback alCerrar;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icono, color: ColoresApp.azulMarino, size: 25),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nombre,
              style: const TextStyle(
                color: ColoresApp.tinta,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              detalle,
              style: const TextStyle(
                color: ColoresApp.atenuado,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      TextButton(
        onPressed: alCerrar,
        child: Text(actual ? 'Salir' : 'Cerrar'),
      ),
    ],
  );
}
