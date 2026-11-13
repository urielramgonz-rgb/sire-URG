import 'package:flutter/material.dart';

import '../tema/colores_app.dart';
import '../componentes/widgets_comunes.dart';
import '../componentes/widgets_formulario.dart';
import '../componentes/barra_superior.dart';
import '../datos/repositorio_bitacora.dart';
import '../datos/repositorio_reportes.dart';
import '../modelos/entrada_bitacora.dart';
import '../modelos/reporte_servicio.dart';
import 'pantalla_reporte.dart';

/// S4 · Bitácora compartida del servicio.
///
/// Se actualiza en vivo cuando Campo registra un tiempo y muestra el registro
/// de actividad (quién y cuándo) del servicio.
class PantallaBitacora extends StatelessWidget {
  const PantallaBitacora({super.key, required this.reporte});

  final ReporteServicio reporte;

  @override
  Widget build(BuildContext context) {
    final repositorio = ReportesRepositorio.instancia;
    final bitacora = BitacoraRepositorio.instancia;
    return AnimatedBuilder(
      animation: Listenable.merge([repositorio, bitacora]),
      builder: (context, _) {
        final actual = repositorio.porIdParaCentral(reporte.id) ?? reporte;
        final actividad = bitacora.deServicio(actual.id);
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                BarraSuperiorSire(
                  titulo: 'Bitácora · ${actual.folioVisible}',
                  mostrarAtras: true,
                  widgetFinal: BotonBarraSuperior(
                    etiqueta: 'Reporte',
                    alPresionar: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              PantallaReporte(reporte: actual, esCentral: true),
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const EtiquetaRol.central(),
                        const SizedBox(height: 16),
                        _TarjetaResumen(reporte: actual),
                        const SizedBox(height: 20),
                        const EtiquetaSeccion('CRONOLOGÍA (tiempo real)'),
                        const SizedBox(height: 14),
                        for (
                          var indice = 0;
                          indice < actual.cronologia.length;
                          indice++
                        )
                          _ItemCronologia(
                            hora: actual.cronologia[indice].hora,
                            titulo: actual.cronologia[indice].titulo,
                            subtitulo: actual.cronologia[indice].completado
                                ? actual.cronologia[indice].detalle
                                : 'Pendiente',
                            completado: actual.cronologia[indice].completado,
                            esUltimo: indice == actual.cronologia.length - 1,
                          ),
                        const SizedBox(height: 8),
                        const EtiquetaSeccion('REGISTRO DE ACTIVIDAD'),
                        const SizedBox(height: 10),
                        if (actividad.isEmpty)
                          const Text(
                            'Sin actividad registrada en esta sesión.',
                            style: TextStyle(
                              fontSize: 13,
                              color: ColoresApp.atenuado,
                            ),
                          ),
                        for (final entrada in actividad.reversed)
                          _FilaActividad(entrada: entrada),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FilaActividad extends StatelessWidget {
  const _FilaActividad({required this.entrada});

  final EntradaBitacora entrada;

  @override
  Widget build(BuildContext context) {
    final detalle = entrada.detalle.isEmpty ? '' : ' · ${entrada.detalle}';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: ColoresApp.fondo,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 56,
            child: Text(
              formatearHora(entrada.momento),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: ColoresApp.tinta,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '${entrada.accion.etiqueta}$detalle\n${entrada.usuario}',
              style: const TextStyle(
                fontSize: 13,
                color: ColoresApp.atenuado,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaResumen extends StatelessWidget {
  const _TarjetaResumen({required this.reporte});

  final ReporteServicio reporte;

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
          Text(
            '${reporte.subcategoria} · ${reporte.categoria}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ColoresApp.tinta,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${reporte.folioVisible} · ${reporte.unidadesTexto} · ${reporte.ubicacion}',
            style: const TextStyle(fontSize: 14, color: ColoresApp.atenuado),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ChipEstadoAmbar(
                texto: reporte.estado.etiqueta.toUpperCase(),
                colorFondo: ColoresApp.ambarClaro,
                rellenoVertical: 5,
              ),
              Text(
                'Prioridad ${reporte.prioridad}',
                style: const TextStyle(
                  fontSize: 13,
                  color: ColoresApp.atenuado,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Personal: ${reporte.personalTexto.isEmpty ? 'No especificado' : reporte.personalTexto}',
            style: const TextStyle(fontSize: 13, color: ColoresApp.atenuado),
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
                    width: 76,
                    child: Text(
                      hora,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: completado
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: completado
                            ? ColoresApp.tinta
                            : ColoresApp.atenuado,
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
                            fontWeight: completado
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: completado
                                ? ColoresApp.tinta
                                : ColoresApp.atenuado,
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
