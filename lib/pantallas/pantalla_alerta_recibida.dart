import 'package:flutter/material.dart';

import '../tema/colores_app.dart';
import '../componentes/widgets_comunes.dart';
import '../componentes/barra_superior.dart';
import '../modelos/reporte_servicio.dart';
import 'pantalla_tiempos.dart';

/// Detalle de un servicio recibido para el perfil Campo.
class PantallaAlertaRecibida extends StatelessWidget {
  const PantallaAlertaRecibida({super.key, required this.reporte});

  final ReporteServicio reporte;

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
            ),
            Container(
              width: double.infinity,
              color: ColoresApp.rojo,
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Text(
                reporte.estado.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const EtiquetaRol.campo(),
                    const SizedBox(height: 18),
                    _CampoInfo(
                      'Servicio',
                      '${reporte.categoria} · ${reporte.subcategoria}',
                    ),
                    _CampoInfo('Ubicación', reporte.ubicacion),
                    _CampoInfo('Unidad asignada', reporte.unidadesTexto),
                    _CampoInfo('Folio C4', reporte.folioVisible),
                    _CampoInfo('Estado', reporte.estado),
                    const SizedBox(height: 12),
                    CajaInfo(
                      'Prioridad ${reporte.prioridad} · servicio en curso',
                      fondo: ColoresApp.azulClaro,
                      colorTexto: ColoresApp.azul,
                      alineacion: TextAlign.center,
                    ),
                    const SizedBox(height: 22),
                    BotonSire(
                      etiqueta: 'VER TIEMPOS DEL SERVICIO',
                      color: ColoresApp.verde,
                      alPresionar: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => PantallaTiempos(reporte: reporte),
                          ),
                        );
                      },
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

class _CampoInfo extends StatelessWidget {
  final String etiqueta;
  final String valor;

  const _CampoInfo(this.etiqueta, this.valor);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          etiqueta,
          style: const TextStyle(fontSize: 14, color: ColoresApp.atenuado),
        ),
        const SizedBox(height: 2),
        Text(
          valor,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: ColoresApp.tinta,
          ),
        ),
        const Divider(color: ColoresApp.linea, height: 22, thickness: 1.5),
      ],
    );
  }
}
