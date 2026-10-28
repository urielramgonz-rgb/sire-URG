import 'package:flutter/material.dart';

import '../tema/colores_app.dart';
import '../componentes/widgets_comunes.dart';
import '../componentes/widgets_formulario.dart';
import '../componentes/barra_superior.dart';
import 'pantalla_reporte.dart';
import 'pantalla_tiempos.dart';

/// S7 · Formulario del servicio (perfil Campo).
///
/// Sólo interfaz: las selecciones son fijas. La pestaña TIEMPOS vuelve a S6
/// y "FINALIZAR SERVICIO" abre el reporte (S8).
class PantallaFormularioServicio extends StatelessWidget {
  const PantallaFormularioServicio({super.key});

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
              widgetFinal: ChipConexion(enLinea: true),
            ),
            PestanasServicio(
              indiceActivo: 1,
              alSeleccionar: (indice) {
                if (indice == 0) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const PantallaTiempos()),
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
                    const EtiquetaCampo('Tipo de servicio'),
                    const SizedBox(height: 10),
                    const Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ChipOpcion('Incendio'),
                        ChipOpcion('Accidente', seleccionado: true),
                        ChipOpcion('Rescate'),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const EtiquetaCampo('Ubicación'),
                    const SizedBox(height: 8),
                    const CampoTextoSire(
                      valorInicial: 'Carretera SMA–Dolores, km 12',
                      etiqueta: 'de alerta',
                    ),
                    const SizedBox(height: 18),
                    const EtiquetaCampo('Unidades de apoyo'),
                    const SizedBox(height: 10),
                    const Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ChipOpcion('B-01', seleccionado: true),
                        ChipOpcion('Prot. Civil'),
                        ChipOpcion('Policía'),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const EtiquetaCampo('Personal a bordo'),
                    const SizedBox(height: 6),
                    const _FilaTripulacion('Cap. Hernández', marcado: true),
                    const _FilaTripulacion('Prm. López', marcado: true),
                    const _FilaTripulacion('Prm. Torres'),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: BotonSire(
                            etiqueta: 'GUARDAR',
                            conBorde: true,
                            tamanoFuente: 15,
                            alPresionar: () {},
                          ),
                        ),
                        const SizedBox(width: 12),
                                                Expanded(
                          child: BotonSire(
                            etiqueta: 'FINALIZAR SERVICIO',
                            color: ColoresApp.verde,
                            tamanoFuente: 15,
                            alPresionar: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const PantallaReporte(esCentral: false),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Center(
                      child: Text(
                        'Sin teclear: todo por selección',
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

class _FilaTripulacion extends StatelessWidget {
  final String nombre;
  final bool marcado;

  const _FilaTripulacion(this.nombre, {this.marcado = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            marcado ? Icons.check_box : Icons.check_box_outline_blank,
            size: 34,
            color: marcado ? ColoresApp.azulMarino : ColoresApp.linea,
          ),
          const SizedBox(width: 12),
          Text(
            nombre,
            style: TextStyle(
              fontSize: 18,
              fontWeight: marcado ? FontWeight.bold : FontWeight.normal,
              color: marcado ? ColoresApp.tinta : ColoresApp.atenuado,
            ),
          ),
        ],
      ),
    );
  }
}