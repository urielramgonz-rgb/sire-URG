import 'package:flutter/material.dart';

import '../tema/colores_app.dart';
import '../componentes/widgets_comunes.dart';
import '../componentes/widgets_formulario.dart';
import '../componentes/barra_superior.dart';
import 'pantalla_reporte.dart';

/// S4 · Bitácora en tiempo real (perfil Central).
///
/// Sólo interfaz: la cronología es fija. El botón "Reporte" abre S8.
class PantallaBitacora extends StatelessWidget {
  const PantallaBitacora({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            BarraSuperiorSire(
              titulo: 'Bitácora · 0154',
              mostrarAtras: true,
              widgetFinal: BotonBarraSuperior(
                etiqueta: 'Reporte',
                alPresionar: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PantallaReporte(esCentral: true)), 
                  );
                },
              ),
            ),
            const Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    EtiquetaRol.central(),
                    SizedBox(height: 16),
                    _TarjetaResumen(),
                    SizedBox(height: 20),
                    EtiquetaSeccion('CRONOLOGÍA (tiempo real)'),
                    SizedBox(height: 14),
                    _ItemCronologia(
                      hora: '14:32',
                      titulo: 'Alerta enviada',
                      subtitulo: 'Central',
                      completado: true,
                    ),
                    _ItemCronologia(
                      hora: '14:34',
                      titulo: 'Salida de base',
                      subtitulo: 'Unidad A-03',
                      completado: true,
                    ),
                    _ItemCronologia(
                      hora: '14:47',
                      titulo: 'Llegada al lugar',
                      subtitulo: 'Unidad A-03',
                      completado: true,
                    ),
                    _ItemCronologia(
                      hora: '14:50',
                      titulo: 'Inicio de atención',
                      subtitulo: 'Unidad A-03',
                      completado: true,
                    ),
                    _ItemCronologia(
                      hora: '--:--',
                      titulo: 'Salida del lugar / traslado',
                      subtitulo: 'Pendiente',
                      completado: false,
                    ),
                    _ItemCronologia(
                      hora: '--:--',
                      titulo: 'Fin del servicio',
                      subtitulo: 'Pendiente',
                      completado: false,
                      esUltimo: true,
                    ),
                    SizedBox(height: 8),
                    CajaInfo(
                      'Los tiempos llegan solos desde la unidad: ya no se '
                      'transcriben de la radio.',
                      fondo: ColoresApp.azulClaro,
                      colorTexto: ColoresApp.azul,
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

class _TarjetaResumen extends StatelessWidget {
  const _TarjetaResumen();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColoresApp.fondo,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Accidente vehicular',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ColoresApp.tinta,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Unidad A-03 · Carr. SMA–Dolores km 12',
            style: TextStyle(fontSize: 14, color: ColoresApp.atenuado),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: ColoresApp.ambarClaro,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: ColoresApp.ambar, width: 1.5),
                ),
                child: const Text(
                  'EN ATENCIÓN',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: ColoresApp.ambarOscuro,
                  ),
                ),
              ),
              const Text(
                'Sincronizado 14:50',
                style: TextStyle(fontSize: 13, color: ColoresApp.atenuado),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ItemCronologia extends StatelessWidget {
  final String hora;
  final String titulo;
  final String subtitulo;
  final bool completado;
  final bool esUltimo;

  const _ItemCronologia({
    required this.hora,
    required this.titulo,
    required this.subtitulo,
    required this.completado,
    this.esUltimo = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 26,
            child: Column(
              children: [
                if (completado)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: ColoresApp.verde,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 15,
                      color: Colors.white,
                    ),
                  )
                else
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: ColoresApp.linea, width: 2.5),
                    ),
                  ),
                if (!esUltimo)
                  Expanded(
                    child: Container(width: 2.5, color: ColoresApp.linea),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 64,
                    child: Text(
                      hora,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight:
                            completado ? FontWeight.bold : FontWeight.normal,
                        color: completado ? ColoresApp.tinta : ColoresApp.atenuado,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titulo,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                completado ? FontWeight.bold : FontWeight.normal,
                            color: completado ? ColoresApp.tinta : ColoresApp.atenuado,
                          ),
                        ),
                        Text(
                          subtitulo,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: ColoresApp.atenuado,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}