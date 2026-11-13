import 'package:flutter/material.dart';

import '../tema/colores_app.dart';
import '../componentes/widgets_comunes.dart';
import '../componentes/barra_superior.dart';
import '../datos/autenticacion.dart';
import '../datos/repositorio_reportes.dart';
import '../modelos/reporte_servicio.dart';
import '../modelos/usuario.dart';
import 'pantalla_formulario_servicio.dart';

/// S6 · Registro de tiempos para el reporte seleccionado.
///
/// Campo marca cada tiempo con la hora real del dispositivo, en orden y una
/// sola vez. Con el servicio finalizado la pantalla es de solo consulta.
class PantallaTiempos extends StatelessWidget {
  const PantallaTiempos({
    super.key,
    required this.reporte,
    this.etapaFormulario = 0,
  });

  final ReporteServicio reporte;
  final int etapaFormulario;

  bool _puedeMarcar(ReporteServicio actual, Usuario? usuario) {
    if (usuario == null || actual.cerrado) return false;
    return usuario.canTakeService() &&
        actual.unidadesAsignadas.contains(usuario.unidad);
  }

  Future<void> _marcar(
    BuildContext context,
    ReporteServicio actual,
    EventoCronologia evento,
    Usuario usuario,
  ) async {
    // La hora se toma al presionar el botón, no al confirmar el diálogo.
    final momento = DateTime.now();
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (contextoDialogo) => AlertDialog(
        title: Text('Registrar ${evento.titulo}'),
        content: Text(
          'Se guardará la hora ${formatearHora(momento)}. '
          'Una vez registrada no se puede cambiar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(contextoDialogo).pop(false),
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () => Navigator.of(contextoDialogo).pop(true),
            child: const Text('REGISTRAR'),
          ),
        ],
      ),
    );
    if (confirmado != true || !context.mounted) return;

    final error = ReportesRepositorio.instancia.marcarTiempo(
      id: actual.id,
      estatus: evento.estatus,
      usuario: usuario,
      momento: momento,
    );
    if (error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(error), backgroundColor: ColoresApp.rojo),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final repositorio = ReportesRepositorio.instancia;
    return AnimatedBuilder(
      animation: repositorio,
      builder: (context, _) {
        final actual = repositorio.porId(reporte.id) ?? reporte;
        final usuario = Autenticacion.instancia.usuarioActual;
        final puedeMarcar = _puedeMarcar(actual, usuario);
        final siguiente = actual.siguientePendiente;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                BarraSuperiorSire(
                  titulo: 'Servicio ${actual.folioVisible}',
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
                            reporte: actual,
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
                                '${actual.categoria} · ${actual.subcategoria}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: ColoresApp.tinta,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${actual.unidadesTexto} · ${actual.estado.etiqueta}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: ColoresApp.atenuado,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                actual.ubicacion,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: ColoresApp.atenuado,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Personal: ${actual.personalTexto.isEmpty ? 'No especificado' : actual.personalTexto}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: ColoresApp.atenuado,
                                ),
                              ),
                            ],
                          ),
                        ),
                        for (final evento in actual.cronologia)
                          if (evento.completado)
                            _FilaCompletada(evento.titulo, evento.hora)
                          else if (puedeMarcar &&
                              siguiente != null &&
                              evento.estatus == siguiente.estatus)
                            _FilaSiguiente(
                              evento: evento,
                              alMarcar: () =>
                                  _marcar(context, actual, evento, usuario!),
                            )
                          else
                            _FilaPendiente(evento),
                        const SizedBox(height: 4),
                        CajaInfo(
                          _mensajeEstado(actual, usuario, puedeMarcar),
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
      },
    );
  }

  String _mensajeEstado(
    ReporteServicio actual,
    Usuario? usuario,
    bool puedeMarcar,
  ) {
    if (actual.cerrado) {
      return 'Servicio finalizado. Los tiempos son de solo consulta.';
    }
    if (!puedeMarcar) {
      return 'Estado del servicio: ${actual.estado.etiqueta}. '
          'Solo la unidad asignada puede registrar tiempos.';
    }
    return 'Estado del servicio: ${actual.estado.etiqueta}. '
        'Los tiempos se registran en orden con la hora del dispositivo.';
  }
}

/// Siguiente tiempo por registrar: botón grande para uso en campo.
class _FilaSiguiente extends StatelessWidget {
  const _FilaSiguiente({required this.evento, required this.alMarcar});

  final EventoCronologia evento;
  final VoidCallback alMarcar;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        onPressed: alMarcar,
        style: ElevatedButton.styleFrom(
          backgroundColor: ColoresApp.azulMarino,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(72),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.touch_app_outlined, size: 30),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                evento.titulo,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Text(
              'REGISTRAR',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: .5,
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
