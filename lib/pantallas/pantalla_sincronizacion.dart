import 'package:flutter/material.dart';

import '../tema/colores_app.dart';
import '../componentes/widgets_comunes.dart';
import '../componentes/widgets_formulario.dart';
import '../componentes/barra_superior.dart';

/// S9 · Sincronización (todos los usuarios).
///
/// Sólo interfaz: los pendientes son de ejemplo y el botón está
/// deshabilitado (la app se muestra sin conexión).
class PantallaSincronizacion extends StatelessWidget {
  const PantallaSincronizacion({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            BarraSuperiorSire(
              titulo: 'Sincronización',
              mostrarAtras: true,
              widgetFinal: ChipConexion(enLinea: false),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    EtiquetaRol.todos(),
                    SizedBox(height: 16),
                    _TarjetaSinConexion(),
                    SizedBox(height: 22),
                    EtiquetaSeccion('PENDIENTES DE ENVÍO (3)'),
                    SizedBox(height: 10),
                    _FilaSincronizacion(titulo: '0154 · Tiempos (4)', pendiente: true),
                    SizedBox(height: 10),
                    _FilaSincronizacion(titulo: '0154 · Formulario', pendiente: true),
                    SizedBox(height: 10),
                    _FilaSincronizacion(titulo: '0154 · Reporte', pendiente: true),
                    SizedBox(height: 20),
                    EtiquetaSeccion('ENVIADOS'),
                    SizedBox(height: 10),
                    _FilaSincronizacion(
                      titulo: '0152 · Reporte',
                      pendiente: false,
                      enviadoA: 'Enviado 09:12',
                    ),
                    SizedBox(height: 28),
                    BotonSire(etiqueta: 'SINCRONIZAR AHORA', alPresionar: null),
                    SizedBox(height: 10),
                    Center(
                      child: Text(
                        'Se enviarán solos al recuperar la señal',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: ColoresApp.atenuado,
                        ),
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

class _TarjetaSinConexion extends StatelessWidget {
  const _TarjetaSinConexion();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ColoresApp.ambarClaro,
        border: Border.all(color: ColoresApp.ambar, width: 2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          Icon(Icons.cloud_off, size: 52, color: ColoresApp.ambarOscuro),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sin conexión',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ColoresApp.ambarOscuro,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Tus registros están guardados de forma segura en el '
                  'teléfono.',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: ColoresApp.ambarOscuro,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilaSincronizacion extends StatelessWidget {
  final String titulo;
  final bool pendiente;
  final String? enviadoA;

  const _FilaSincronizacion({required this.titulo, required this.pendiente, this.enviadoA});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: ColoresApp.fondo,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (pendiente)
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: ColoresApp.ambar,
                shape: BoxShape.circle,
              ),
            )
          else
            const Icon(Icons.check_circle, size: 20, color: ColoresApp.verde),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              titulo,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: ColoresApp.tinta,
              ),
            ),
          ),
          if (pendiente)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: ColoresApp.ambar, width: 1.5),
              ),
              child: const Text(
                'Pendiente',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: ColoresApp.ambarOscuro,
                ),
              ),
            )
          else
            Text(
              enviadoA ?? '',
              style: const TextStyle(fontSize: 13, color: ColoresApp.verde),
            ),
        ],
      ),
    );
  }
}