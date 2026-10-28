import 'package:flutter/material.dart';

import '../tema/colores_app.dart';
import '../componentes/widgets_comunes.dart';
import '../componentes/barra_superior.dart';
import '../modelos/configuracion_campos_alerta.dart';
import '../modelos/reporte_servicio.dart';
import 'pantalla_panel_central.dart';
import 'pantalla_panel_campo.dart';

String _nombreCorporacionVisible(String identidad) => switch (identidad) {
  'CR — Cruz Roja' => 'Cruz Roja',
  'PC — Protección Civil' => 'Protección Civil',
  'TM — Tránsito Municipal' => 'Tránsito Municipal',
  'GN — Guardia Nacional' => 'Guardia Nacional',
  'PM — Policía Municipal' => 'Policía Municipal',
  _ => identidad,
};

const _acentosApoyo = [
  Color(0xFF426A8C),
  Color(0xFF397D78),
  Color(0xFF6A7195),
  Color(0xFF547486),
  Color(0xFF7B6D8D),
  Color(0xFF647F68),
  Color(0xFF8A745A),
];

String _datoOpcional(String? valor) =>
    valor == null || valor.trim().isEmpty ? 'No especificado' : valor;

/// S8 · Reporte del servicio seleccionado.
class PantallaReporte extends StatelessWidget {
  final bool esCentral;
  final ReporteServicio reporte;

  const PantallaReporte({
    super.key,
    required this.reporte,
    this.esCentral = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            BarraSuperiorSire(
              titulo: 'Reporte · ${reporte.folioVisible}',
              mostrarAtras: true,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const EtiquetaRol.todos(texto: 'CENTRAL Y CAMPO'),
                    const SizedBox(height: 16),
                    _TarjetaReporte(reporte: reporte),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: BotonSire(
                            etiqueta: 'ENVIAR A CENTRAL',
                            tamanoFuente: 15,
                            alPresionar: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (_) => esCentral
                                      ? const PantallaPanelCentral()
                                      : const PantallaPanelCampo(),
                                ),
                                (ruta) => ruta.isFirst,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: BotonSire(
                            etiqueta: 'PDF',
                            conBorde: true,
                            tamanoFuente: 15,
                            alPresionar: () {},
                          ),
                        ),
                      ],
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

class _TarjetaReporte extends StatelessWidget {
  const _TarjetaReporte({required this.reporte});

  final ReporteServicio reporte;

  @override
  Widget build(BuildContext context) {
    final camposCategoria =
        ConfiguracionCamposAlerta.porCategoria[reporte.categoria]?[reporte
            .subcategoria] ??
        const <CampoAlerta>[];
    final tripulaciones = reporte.unidadesAsignadas.map((unidad) {
      final personas = reporte.personal
          .where((persona) => persona.unidad == unidad)
          .toList();
      final datosTripulacion = <MapEntry<String, String>>[
        for (final persona in personas)
          if (persona.funcion == 'Maquinista' ||
              persona.funcion == 'Jefe de servicio')
            MapEntry(persona.funcion, persona.nombre),
        if (!personas.any(
          (persona) =>
              persona.funcion != 'Maquinista' &&
              persona.funcion != 'Jefe de servicio',
        ))
          const MapEntry('Personal de apoyo', 'No especificado'),
        for (final persona in personas)
          if (persona.funcion != 'Maquinista' &&
              persona.funcion != 'Jefe de servicio')
            MapEntry(persona.funcion, persona.nombre),
      ];
      return _TarjetaSeccionReporte(
        titulo: 'Tripulación de $unidad',
        datos: datosTripulacion,
      );
    });
    final corporacionesApoyo = <String>{
      ...reporte.corporacionesApoyo,
      ...reporte.unidadesApoyo.map((unidad) => unidad.corporacion),
    };
    final tarjetasApoyo = corporacionesApoyo.isEmpty
        ? <Widget>[
            const _TarjetaSeccionReporte(
              titulo: 'Corporaciones de apoyo',
              datos: [
                MapEntry('Estado', 'Sin corporaciones de apoyo registradas'),
              ],
            ),
          ]
        : <Widget>[
            for (var indice = 0; indice < corporacionesApoyo.length; indice++)
              _TarjetaGrupoApoyo(
                corporacion: _nombreCorporacionVisible(
                  corporacionesApoyo.elementAt(indice),
                ),
                unidades: reporte.unidadesApoyo
                    .where(
                      (unidad) =>
                          unidad.corporacion ==
                          corporacionesApoyo.elementAt(indice),
                    )
                    .toList(),
                acento: _acentosApoyo[indice % _acentosApoyo.length],
              ),
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'REPORTE DE SERVICIO',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: ColoresApp.azulMarino,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Bomberos y Paramédicos SMA',
          style: TextStyle(fontSize: 13, color: ColoresApp.atenuado),
        ),
        const SizedBox(height: 10),
        const SizedBox(height: 14),
        _TarjetaSeccionReporte(
          titulo: 'Categoría',
          datos: [
            MapEntry('Categoría', reporte.categoria),
            MapEntry('Subcategoría', reporte.subcategoria),
          ],
        ),
        _TarjetaSeccionReporte(
          titulo: 'Detalles de la emergencia',
          datos: [
            for (final campo in camposCategoria)
              MapEntry(
                campo.etiqueta,
                _datoOpcional(reporte.camposFormulario[campo.id]),
              ),
          ],
        ),
        _TarjetaSeccionReporte(
          titulo: 'Reporte',
          datos: [
            MapEntry('Folio C4', reporte.folioVisible),
            MapEntry('Quién reporta', _datoOpcional(reporte.solicitante)),
            for (final dato in reporte.datosSolicitante.entries)
              MapEntry(dato.key, _datoOpcional(dato.value)),
          ],
        ),
        _TarjetaSeccionReporte(
          titulo: 'Ubicación',
          datos: [
            MapEntry('Ubicación del evento', _datoOpcional(reporte.ubicacion)),
            for (final dato in reporte.detallesUbicacion.entries)
              MapEntry(dato.key, _datoOpcional(dato.value)),
          ],
        ),
        ...tripulaciones,
        _TarjetaSeccionReporte(
          titulo: 'Despacho',
          datos: [
            MapEntry('Unidades', _datoOpcional(reporte.unidadesTexto)),
            MapEntry('Prioridad', _datoOpcional(reporte.prioridad)),
            MapEntry('Estado', _datoOpcional(reporte.estado)),
          ],
        ),
        _TarjetaSeccionReporte(
          titulo: 'Información complementaria de Campo',
          datos: [
            MapEntry(
              'Eventos del servicio',
              _datoOpcional(reporte.eventosCampo),
            ),
            MapEntry(
              'Cierre del servicio',
              _datoOpcional(reporte.cierreServicio),
            ),
          ],
        ),
        ...tarjetasApoyo,
        _TarjetaCronologia(reporte: reporte),
      ],
    );
  }
}

class _TarjetaSeccionReporte extends StatelessWidget {
  const _TarjetaSeccionReporte({required this.titulo, required this.datos});

  final String titulo;
  final List<MapEntry<String, String>> datos;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ColoresApp.fondo,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColoresApp.linea),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              color: ColoresApp.azulMarino,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          for (var indice = 0; indice < datos.length; indice++) ...[
            if (indice > 0) const Divider(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    datos[indice].key,
                    style: const TextStyle(
                      color: ColoresApp.atenuado,
                      fontSize: 12.5,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: Text(
                    datos[indice].value,
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      color: ColoresApp.tinta,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _TarjetaGrupoApoyo extends StatelessWidget {
  const _TarjetaGrupoApoyo({
    required this.corporacion,
    required this.unidades,
    required this.acento,
  });

  final String corporacion;
  final List<UnidadApoyoReporte> unidades;
  final Color acento;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: acento.withValues(alpha: .055),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: acento.withValues(alpha: .45), width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 5,
                height: 30,
                decoration: BoxDecoration(
                  color: acento,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  corporacion,
                  style: TextStyle(
                    color: acento,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (unidades.isEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Sin unidades externas registradas',
              style: TextStyle(color: ColoresApp.atenuado, fontSize: 13),
            ),
          ],
          for (var indice = 0; indice < unidades.length; indice++)
            _TarjetaSeccionReporte(
              titulo: 'Unidad ${indice + 1}',
              datos: [
                MapEntry(
                  'Identificador',
                  _datoOpcional(unidades[indice].identificador),
                ),
                MapEntry(
                  'Responsable',
                  _datoOpcional(unidades[indice].responsable),
                ),
                MapEntry(
                  'Tripulantes',
                  unidades[indice].tripulacion
                          .where((nombre) => nombre.trim().isNotEmpty)
                          .isEmpty
                      ? 'No especificado'
                      : unidades[indice].tripulacion
                            .where((nombre) => nombre.trim().isNotEmpty)
                            .join('\n'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _TarjetaCronologia extends StatelessWidget {
  const _TarjetaCronologia({required this.reporte});

  final ReporteServicio reporte;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ColoresApp.fondo,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColoresApp.linea),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Cronología',
            style: TextStyle(
              color: ColoresApp.azulMarino,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          for (final evento in reporte.cronologia) _FilaHora(evento: evento),
        ],
      ),
    );
  }
}

class _FilaHora extends StatelessWidget {
  const _FilaHora({required this.evento});

  final EventoCronologia evento;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: evento.completado ? Colors.white : ColoresApp.fondo,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              evento.hora,
              style: TextStyle(
                fontSize: 15,
                fontWeight: evento.completado
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: evento.completado
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
                  evento.titulo,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: evento.completado
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: evento.completado
                        ? ColoresApp.tinta
                        : ColoresApp.atenuado,
                  ),
                ),
                if (!evento.completado)
                  const Text(
                    'Pendiente',
                    style: TextStyle(fontSize: 12, color: ColoresApp.atenuado),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
