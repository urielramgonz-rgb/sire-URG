import 'package:flutter/material.dart';

import '../tema/colores_app.dart';
import '../componentes/widgets_comunes.dart';
import '../componentes/barra_superior.dart';
import '../modelos/reporte_servicio.dart';
import 'pantalla_formulario_servicio.dart';

/// S6 · Registro de tiempos para el reporte seleccionado.
class PantallaTiempos extends StatelessWidget {
  const PantallaTiempos({
    super.key,
    required this.reporte,
    this.etapaFormulario = 0,
  });

  final ReporteServicio reporte;
  final int etapaFormulario;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            BarraSuperiorSire(
              titulo: 'Servicio ${reporte.folioVisible}',
              mostrarAtras: true,
              widgetFinal: const ChipConexion(enLinea: false),
            ),
            PestanasServicio(
              indiceActivo: 0,
              alSeleccionar: (indice) {
                if (indice == 1) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => PantallaFormularioServicio(
                        reporte: reporte,
                        etapaInicial: etapaFormulario,
                      ),
                    ),
                  );
                }
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const EtiquetaRol.campo(),
                    const SizedBox(height: 16),
                    Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ColoresApp.fondo,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${reporte.categoria} · ${reporte.subcategoria}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: ColoresApp.tinta,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${reporte.unidadesTexto} · ${reporte.estado}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: ColoresApp.atenuado,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            reporte.ubicacion,
                            style: const TextStyle(
                              fontSize: 14,
                              color: ColoresApp.atenuado,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Personal: ${reporte.personalTexto.isEmpty ? 'No especificado' : reporte.personalTexto}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: ColoresApp.atenuado,
                            ),
                          ),
                        ],
                      ),
                    ),
                    for (final evento in reporte.cronologia)
                      if (evento.completado)
                        _FilaCompletada(evento.titulo, evento.hora)
                      else
                        _FilaPendiente(evento),
                    const SizedBox(height: 4),
                    CajaInfo(
                      'Estado del servicio: ${reporte.estado}.',
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

class _FilaCompletada extends StatelessWidget {
  final String titulo;
  final String hora;

  const _FilaCompletada(this.titulo, this.hora);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: ColoresApp.verdeClaro,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: ColoresApp.verde, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              titulo,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: ColoresApp.tinta,
              ),
            ),
          ),
          Text(
            hora,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: ColoresApp.verde,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilaPendiente extends StatelessWidget {
  final EventoCronologia evento;

  const _FilaPendiente(this.evento);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: ColoresApp.fondo,
        border: Border.all(color: ColoresApp.linea, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: ColoresApp.linea, width: 2.5),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  evento.titulo,
                  style: const TextStyle(
                    fontSize: 16,
                    color: ColoresApp.atenuado,
                  ),
                ),
                const Text(
                  'Pendiente',
                  style: TextStyle(fontSize: 12, color: ColoresApp.atenuado),
                ),
              ],
            ),
          ),
          Text(
            evento.hora,
            style: TextStyle(fontSize: 17, color: ColoresApp.atenuado),
          ),
        ],
      ),
    );
  }
}
