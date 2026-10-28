import 'package:flutter/material.dart';

import '../tema/colores_app.dart';
import '../componentes/widgets_comunes.dart';
import '../componentes/barra_superior.dart';
import 'pantalla_formulario_servicio.dart';

/// S6 · Registro de tiempos (perfil Campo), mostrado sin conexión.
///
/// Sólo interfaz: el botón grande no registra nada. La pestaña
/// FORMULARIO lleva a S7.
class PantallaTiempos extends StatelessWidget {
  const PantallaTiempos({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const BarraSuperiorSire(
              titulo: 'Servicio 0154',
              mostrarAtras: true,
              widgetFinal: ChipConexion(enLinea: false),
            ),
            PestanasServicio(
              indiceActivo: 0,
              alSeleccionar: (indice) {
                if (indice == 1) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const PantallaFormularioServicio(),
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
                    const _FilaCompletada('Salida de base', '14:34'),
                    const _FilaCompletada('Llegada al lugar', '14:47'),
                    const SizedBox(height: 4),
                    BotonSire(
                      etiqueta: 'INICIO DE ATENCIÓN',
                      subEtiqueta: 'Toca para registrar la hora exacta',
                      color: ColoresApp.verde,
                      altura: 120,
                      tamanoFuente: 22,
                      alPresionar: () {},
                    ),
                    const SizedBox(height: 14),
                    const _FilaPendiente('Salida del lugar / traslado'),
                    const _FilaPendiente('Fin del servicio'),
                    const SizedBox(height: 4),
                    const CajaInfo(
                      'Sin señal: cada hora se guarda en el teléfono y se '
                      'envía sola al volver la señal.',
                      fondo: ColoresApp.ambarClaro,
                      colorTexto: ColoresApp.ambarOscuro,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                hora,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: ColoresApp.verde,
                ),
              ),
              const Text(
                'corregir',
                style: TextStyle(fontSize: 12, color: ColoresApp.atenuado),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilaPendiente extends StatelessWidget {
  final String titulo;

  const _FilaPendiente(this.titulo);

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
            child: Text(
              titulo,
              style: const TextStyle(fontSize: 16, color: ColoresApp.atenuado),
            ),
          ),
          const Text(
            '--:--',
            style: TextStyle(fontSize: 17, color: ColoresApp.atenuado),
          ),
        ],
      ),
    );
  }
}