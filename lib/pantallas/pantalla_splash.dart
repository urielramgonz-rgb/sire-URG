import 'package:flutter/material.dart';

import '../tema/colores_app.dart';
import 'pantalla_login.dart';

/// Pantalla de inicio demostrativa. Los estados de conexión y sincronización
/// son estáticos porque esta interfaz aún no está conectada a servicios reales.
class PantallaSplash extends StatelessWidget {
  const PantallaSplash({super.key});

  void _continuar(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const PantallaLogin()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 92,
                              height: 92,
                              decoration: BoxDecoration(
                                color: ColoresApp.azulMarino,
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x260F4761),
                                    blurRadius: 22,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 68,
                                  ),
                                  Icon(
                                    Icons.add,
                                    color: ColoresApp.rojo,
                                    size: 42,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'SIRE',
                              style: TextStyle(
                                color: ColoresApp.azulMarino,
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 3,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Sistema de Registro de Emergencias',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: ColoresApp.atenuado,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 32),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
                              decoration: BoxDecoration(
                                color: ColoresApp.fondo,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: ColoresApp.linea),
                              ),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ESTADO DEL SISTEMA',
                                    style: TextStyle(
                                      color: ColoresApp.atenuado,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  _EstadoVerificacion(
                                    icono: Icons.person_outline,
                                    titulo: 'Sesión',
                                    detalle: 'Inicia sesión para continuar',
                                    color: ColoresApp.azul,
                                  ),
                                  _EstadoVerificacion(
                                    icono: Icons.cloud_off_outlined,
                                    titulo: 'Conexión',
                                    detalle: 'Sin conexión',
                                    color: ColoresApp.ambarOscuro,
                                  ),
                                  _EstadoVerificacion(
                                    icono: Icons.sync_outlined,
                                    titulo: 'Sincronización',
                                    detalle: '3 registros pendientes',
                                    color: ColoresApp.ambarOscuro,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _continuar(context),
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('CONTINUAR SIN CONEXIÓN'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColoresApp.azulMarino,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: .5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Bomberos y Paramédicos SMA',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: ColoresApp.atenuado,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EstadoVerificacion extends StatelessWidget {
  const _EstadoVerificacion({
    required this.icono,
    required this.titulo,
    required this.detalle,
    required this.color,
  });

  final IconData icono;
  final String titulo;
  final String detalle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icono, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: ColoresApp.tinta,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
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
          Icon(Icons.check_circle, color: color, size: 19),
        ],
      ),
    );
  }
}
