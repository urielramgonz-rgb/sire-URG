import 'package:flutter/material.dart';

import '../tema/colores_app.dart';
import '../componentes/widgets_comunes.dart';
import '../componentes/widgets_formulario.dart';
import '../componentes/barra_superior.dart';
import '../datos/autenticacion.dart';
import '../datos/repositorio_reportes.dart';
import '../modelos/reporte_servicio.dart';
import 'pantalla_sincronizacion.dart';
import 'pantalla_tiempos.dart';
import 'pantalla_seguridad.dart';

/// S2 · Panel de servicios (Perfil Campo / Bomberos y Paramédicos).
class PantallaPanelCampo extends StatelessWidget {
  const PantallaPanelCampo({super.key});

  void _abrir(BuildContext context, Widget pantalla) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => pantalla));
  }

  @override
  Widget build(BuildContext context) {
    final repositorio = ReportesRepositorio.instancia;
    final usuario = Autenticacion.instancia.usuarioActual;
    final unidad = usuario?.unidad;
    final puedeAtender = usuario != null && usuario.canTakeService();
    return Scaffold(
      backgroundColor: ColoresApp.fondo,
      body: SafeArea(
        child: Column(
          children: [
            BarraSuperiorSire(
              titulo: 'Mi Panel',
              widgetFinal: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ChipConexion(enLinea: true),
                  IconButton(
                    tooltip: 'Seguridad y sesión',
                    onPressed: () => _abrir(
                      context,
                      const PantallaSeguridad(sesionActiva: true),
                    ),
                    icon: const Icon(Icons.manage_accounts_outlined),
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    '${usuario?.nombre ?? 'Sin sesión'}'
                    '${unidad == null ? '' : ' · Unidad $unidad'}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ColoresApp.tinta,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Bomberos y Paramédicos SMA',
                    style: TextStyle(fontSize: 14, color: ColoresApp.atenuado),
                  ),
                  const SizedBox(height: 24),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      EtiquetaSeccion('SERVICIOS ASIGNADOS'),
                      ChipPanel(
                        texto: 'CAMPO',
                        colorTexto: ColoresApp.verdeAzulado,
                        colorFondo: ColoresApp.verdeAzuladoClaro,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AnimatedBuilder(
                    animation: repositorio,
                    builder: (context, _) {
                      if (!puedeAtender || unidad == null) {
                        return const Text(
                          'Tu cuenta no puede recibir ni atender servicios.',
                          style: TextStyle(color: ColoresApp.atenuado),
                        );
                      }
                      final asignados = repositorio.asignadosA(unidad);
                      final activos = asignados
                          .where((reporte) => !reporte.cerrado)
                          .toList();
                      final finalizados = asignados
                          .where((reporte) => reporte.cerrado)
                          .toList();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (activos.isEmpty)
                            Text(
                              'No hay servicios activos para $unidad.',
                              style: const TextStyle(
                                color: ColoresApp.atenuado,
                              ),
                            ),
                          for (final reporte in activos) ...[
                            _TarjetaReporteCampo(
                              reporte: reporte,
                              alAbrir: () => _abrir(
                                context,
                                PantallaTiempos(reporte: reporte),
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                          const SizedBox(height: 10),
                          const EtiquetaSeccion('HISTORIAL RECIENTE'),
                          const SizedBox(height: 10),
                          if (finalizados.isEmpty)
                            const Text(
                              'Aún no hay servicios finalizados.',
                              style: TextStyle(color: ColoresApp.atenuado),
                            ),
                          for (final reporte in finalizados) ...[
                            GestureDetector(
                              onTap: () => _abrir(
                                context,
                                PantallaTiempos(reporte: reporte),
                              ),
                              child: _FilaHistorial(
                                titulo:
                                    '${reporte.folioVisible} · ${reporte.subcategoria}',
                                subtitulo: reporte.categoria,
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            PestanasInferioresPanel(
              etiquetaActiva: 'Mi Servicio',
              colorActivo: ColoresApp.verdeAzulado,
              alSincronizar: () =>
                  _abrir(context, const PantallaSincronizacion()),
            ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaReporteCampo extends StatelessWidget {
  const _TarjetaReporteCampo({required this.reporte, required this.alAbrir});

  final ReporteServicio reporte;
  final VoidCallback alAbrir;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: alAbrir,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ColoresApp.rojoClaro,
          border: Border.all(color: ColoresApp.rojo, width: 2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${reporte.folioVisible} · ${reporte.subcategoria}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: ColoresApp.tinta,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: ColoresApp.rojo),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              reporte.ubicacion,
              style: const TextStyle(fontSize: 15, color: ColoresApp.tinta),
            ),
            const SizedBox(height: 10),
            Text(
              reporte.estado.etiqueta,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: ColoresApp.rojo,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilaHistorial extends StatelessWidget {
  final String titulo;
  final String subtitulo;

  const _FilaHistorial({required this.titulo, required this.subtitulo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: ColoresApp.verde, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: ColoresApp.tinta,
                ),
              ),
              Text(
                subtitulo,
                style: const TextStyle(
                  fontSize: 13,
                  color: ColoresApp.atenuado,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
