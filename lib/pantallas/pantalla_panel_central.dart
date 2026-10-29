import 'package:flutter/material.dart';

import '../tema/colores_app.dart';
import '../componentes/widgets_comunes.dart';
import '../componentes/widgets_formulario.dart';
import '../componentes/barra_superior.dart';
import '../datos/repositorio_reportes.dart';
import '../modelos/reporte_servicio.dart';
import 'pantalla_nueva_alerta.dart';
import 'pantalla_sincronizacion.dart';
import 'pantalla_bitacora.dart';
import 'pantalla_seguridad.dart';

/// S2 · Panel de servicios (Perfil Central / Radio-operador).
class PantallaPanelCentral extends StatelessWidget {
  const PantallaPanelCentral({super.key});

  void _abrir(BuildContext context, Widget pantalla) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => pantalla));
  }

  @override
  Widget build(BuildContext context) {
    final repositorio = ReportesRepositorio.instancia;
    return AnimatedBuilder(
      animation: repositorio,
      builder: (context, _) {
        final reportes = repositorio.reportesParaCentral;
        return Scaffold(
          backgroundColor: ColoresApp.fondo,
          body: SafeArea(
            child: Column(
              children: [
                BarraSuperiorSire(
                  titulo: 'Panel Central',
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
                      const Text(
                        'Radio-operador · Central SMA',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: ColoresApp.tinta,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          EtiquetaSeccion('SERVICIOS ACTIVOS'),
                          ChipPanel(
                            texto: 'CENTRAL',
                            colorTexto: ColoresApp.azul,
                            colorFondo: ColoresApp.azulClaro,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      for (final reporte in reportes) ...[
                        if (reporte.folio == '0154')
                          _TarjetaServicioCentral(
                            reporte: reporte,
                            alAbrir: () => _abrir(
                              context,
                              PantallaBitacora(reporte: reporte),
                            ),
                          )
                        else
                          _FilaServicio(
                            punto: _colorEstado(reporte.estado),
                            titulo:
                                '${reporte.folioVisible} · ${reporte.subcategoria}',
                            subtitulo:
                                '${reporte.categoria} · ${reporte.unidadesTexto} · ${reporte.estado}',
                            colorSubtitulo: _colorEstado(reporte.estado),
                            alPresionar: () => _abrir(
                              context,
                              PantallaBitacora(reporte: reporte),
                            ),
                          ),
                        const SizedBox(height: 10),
                      ],
                      const SizedBox(height: 20),
                      _BotonNuevaAlerta(
                        alPresionar: () =>
                            _abrir(context, const PantallaNuevaAlerta()),
                      ),
                    ],
                  ),
                ),
                PestanasInferioresPanel(
                  etiquetaActiva: 'Servicios',
                  colorActivo: ColoresApp.azulMarino,
                  alSincronizar: () =>
                      _abrir(context, const PantallaSincronizacion()),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Color _colorEstado(String estado) {
  switch (estado) {
    case 'En atención':
    case 'En escena':
      return ColoresApp.verde;
    case 'En camino':
      return ColoresApp.azul;
    default:
      return ColoresApp.ambarOscuro;
  }
}

class _TarjetaServicioCentral extends StatelessWidget {
  const _TarjetaServicioCentral({required this.reporte, required this.alAbrir});

  final ReporteServicio reporte;
  final VoidCallback alAbrir;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: alAbrir,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: ColoresApp.azul, width: 2),
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ColoresApp.tinta,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: ColoresApp.atenuado),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${reporte.categoria} · ${reporte.unidadesTexto} · ${reporte.estado}',
              style: const TextStyle(fontSize: 14, color: ColoresApp.atenuado),
            ),
            const SizedBox(height: 6),
            const Text(
              'Ver bitácora',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: ColoresApp.azul,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilaServicio extends StatelessWidget {
  const _FilaServicio({
    required this.punto,
    required this.titulo,
    required this.subtitulo,
    required this.colorSubtitulo,
    required this.alPresionar,
  });

  final Color punto;
  final String titulo;
  final String subtitulo;
  final Color colorSubtitulo;
  final VoidCallback alPresionar;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: alPresionar,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: punto, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
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
                    style: TextStyle(fontSize: 13, color: colorSubtitulo),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BotonNuevaAlerta extends StatelessWidget {
  final VoidCallback alPresionar;

  const _BotonNuevaAlerta({required this.alPresionar});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColoresApp.azul,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(64),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      onPressed: alPresionar,
      child: const Text(
        '+ NUEVA ALERTA',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
