import 'package:flutter/material.dart';

import '../componentes/barra_superior.dart';
import '../componentes/widgets_comunes.dart';
import '../componentes/widgets_formulario.dart';
import '../datos/repositorio_reportes.dart';
import '../modelos/reporte_servicio.dart';
import '../tema/colores_app.dart';
import 'pantalla_panel_campo.dart';
import 'pantalla_reporte.dart';
import 'pantalla_tiempos.dart';

/// Formulario por etapas con datos conservados en el repositorio de la sesión.
class PantallaFormularioServicio extends StatefulWidget {
  const PantallaFormularioServicio({
    super.key,
    required this.reporte,
    this.etapaInicial = 0,
  });

  final ReporteServicio reporte;
  final int etapaInicial;

  @override
  State<PantallaFormularioServicio> createState() =>
      _PantallaFormularioServicioState();
}

class _PantallaFormularioServicioState
    extends State<PantallaFormularioServicio> {
  static const _corporaciones = [
    _CorporacionApoyo('Cruz Roja'),
    _CorporacionApoyo('Protección Civil'),
    _CorporacionApoyo('Tránsito Municipal'),
    _CorporacionApoyo('Guardia Nacional'),
    _CorporacionApoyo('SEDENA'),
    _CorporacionApoyo('FSPE'),
    _CorporacionApoyo('Policía Municipal'),
  ];

  static const _acentosCorporacion = [
    Color(0xFF426A8C),
    Color(0xFF397D78),
    Color(0xFF6A7195),
    Color(0xFF547486),
    Color(0xFF7B6D8D),
    Color(0xFF647F68),
    Color(0xFF8A745A),
  ];

  final _repositorio = ReportesRepositorio.instancia;
  late final TextEditingController _eventosController;
  late final TextEditingController _cierreController;
  final Set<String> _corporacionesSeleccionadas = {};
  final Map<String, List<_BorradorUnidadApoyo>> _unidadesPorCorporacion = {};
  late _EtapaFormulario _etapa;

  @override
  void initState() {
    super.initState();
    final reporte = _reporteActual;
    _eventosController = TextEditingController(text: reporte.eventosCampo);
    _cierreController = TextEditingController(text: reporte.cierreServicio);
    _corporacionesSeleccionadas.addAll(reporte.corporacionesApoyo);
    for (final corporacion in _corporacionesSeleccionadas) {
      _unidadesPorCorporacion[corporacion] = [
        for (final unidad in reporte.unidadesApoyo)
          if (unidad.corporacion == corporacion)
            _BorradorUnidadApoyo.desdeReporte(unidad),
      ];
    }
    _etapa =
        _EtapaFormulario.values[widget.etapaInicial
            .clamp(0, _EtapaFormulario.values.length - 1)
            .toInt()];
  }

  ReporteServicio get _reporteActual =>
      _repositorio.porId(widget.reporte.id) ?? widget.reporte;

  @override
  void dispose() {
    _eventosController.dispose();
    _cierreController.dispose();
    for (final unidades in _unidadesPorCorporacion.values) {
      for (final unidad in unidades) {
        unidad.dispose();
      }
    }
    super.dispose();
  }

  void _cambiarEtapa(_EtapaFormulario etapa) {
    FocusScope.of(context).unfocus();
    setState(() => _etapa = etapa);
  }

  void _alternarCorporacion(_CorporacionApoyo corporacion) {
    setState(() {
      if (!_corporacionesSeleccionadas.add(corporacion.nombre)) {
        _corporacionesSeleccionadas.remove(corporacion.nombre);
      } else {
        _unidadesPorCorporacion.putIfAbsent(corporacion.nombre, () => []);
      }
      _guardarBorrador();
    });
  }

  void _sinCorporacionesApoyo() {
    for (final unidades in _unidadesPorCorporacion.values) {
      for (final unidad in unidades) {
        unidad.dispose();
      }
    }
    _unidadesPorCorporacion.clear();
    _corporacionesSeleccionadas.clear();
    _cambiarEtapa(_EtapaFormulario.cierre);
    _guardarBorrador();
  }

  void _agregarUnidad(_CorporacionApoyo corporacion) {
    setState(() {
      _unidadesPorCorporacion
          .putIfAbsent(corporacion.nombre, () => [])
          .add(_BorradorUnidadApoyo());
      _guardarBorrador();
    });
    _notificar('Se agregó una unidad de ${corporacion.nombre}.');
  }

  void _agregarTripulante(_BorradorUnidadApoyo unidad) {
    setState(() {
      unidad.tripulantes.add(TextEditingController());
      _guardarBorrador();
    });
    _notificar('Se agregó un campo para tripulante.');
  }

  void _guardarBorrador() {
    final nombresCorporaciones = [
      for (final corporacion in _corporaciones)
        if (_corporacionesSeleccionadas.contains(corporacion.nombre))
          corporacion.nombre,
    ];
    final unidades = <UnidadApoyoReporte>[
      for (final corporacion in _corporaciones)
        if (_corporacionesSeleccionadas.contains(corporacion.nombre))
          for (final unidad
              in _unidadesPorCorporacion[corporacion.nombre] ??
                  const <_BorradorUnidadApoyo>[])
            UnidadApoyoReporte(
              corporacion: corporacion.nombre,
              identificador: unidad.identificador.text.trim(),
              responsable: unidad.responsable.text.trim(),
              tripulacion: List.unmodifiable([
                for (final tripulante in unidad.tripulantes)
                  if (tripulante.text.trim().isNotEmpty) tripulante.text.trim(),
              ]),
            ),
    ];
    _repositorio.actualizarDatosServicio(
      id: widget.reporte.id,
      eventos: _eventosController.text,
      corporaciones: nombresCorporaciones,
      unidades: unidades,
      cierre: _cierreController.text,
    );
  }

  void _verReporte() {
    _guardarBorrador();
    final reporte = _reporteActual;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PantallaReporte(reporte: reporte, esCentral: false),
      ),
    );
  }

  void _notificar(String mensaje) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensaje)));
  }

  void _anterior() {
    switch (_etapa) {
      case _EtapaFormulario.eventos:
        return;
      case _EtapaFormulario.corporaciones:
        _cambiarEtapa(_EtapaFormulario.eventos);
        return;
      case _EtapaFormulario.unidades:
        _cambiarEtapa(_EtapaFormulario.corporaciones);
        return;
      case _EtapaFormulario.cierre:
        _cambiarEtapa(_EtapaFormulario.unidades);
        return;
    }
  }

  void _continuar() {
    switch (_etapa) {
      case _EtapaFormulario.eventos:
        _cambiarEtapa(_EtapaFormulario.corporaciones);
        return;
      case _EtapaFormulario.corporaciones:
        _cambiarEtapa(_EtapaFormulario.unidades);
        return;
      case _EtapaFormulario.unidades:
        _cambiarEtapa(_EtapaFormulario.cierre);
        return;
      case _EtapaFormulario.cierre:
        return;
    }
  }

  void _enviarReporte() {
    _guardarBorrador();
    if (!_repositorio.publicarDatosServicio(widget.reporte.id)) {
      _notificar('No se encontró el reporte para enviar.');
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Reporte enviado a Central.')),
      );
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const PantallaPanelCampo()),
      (ruta) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            BarraSuperiorSire(
              titulo: 'Servicio ${_reporteActual.folioVisible}',
              mostrarAtras: true,
              widgetFinal: BotonBarraSuperior(
                etiqueta: 'Ver reporte',
                alPresionar: _verReporte,
              ),
            ),
            PestanasServicio(
              indiceActivo: 1,
              alSeleccionar: (indice) {
                if (indice == 0) {
                  _guardarBorrador();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => PantallaTiempos(
                        reporte: _reporteActual,
                        etapaFormulario: _etapa.index,
                      ),
                    ),
                  );
                }
              },
            ),
            _menuEtapas(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const EtiquetaRol.campo(),
                    const SizedBox(height: 14),
                    _resumenServicio(),
                    const SizedBox(height: 20),
                    Text(
                      _etapa.titulo.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: ColoresApp.azulMarino,
                        letterSpacing: .3,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _contenidoEtapa(),
                    const SizedBox(height: 20),
                    ..._accionesEtapa(),
                    const SizedBox(height: 10),
                    const Center(
                      child: Text(
                        'Datos de demostración del servicio',
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

  Widget _menuEtapas() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: ColoresApp.linea, width: 2)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final ancho = (constraints.maxWidth - 8) / 2;
          return Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              for (final etapa in _EtapaFormulario.values)
                SizedBox(width: ancho, child: _opcionEtapa(etapa)),
            ],
          );
        },
      ),
    );
  }

  Widget _opcionEtapa(_EtapaFormulario etapa) {
    final activa = _etapa == etapa;
    return Material(
      color: activa ? ColoresApp.azulClaro : Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _cambiarEtapa(etapa),
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: activa ? ColoresApp.azulMarino : ColoresApp.linea,
              width: activa ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: activa
                    ? ColoresApp.azulMarino
                    : ColoresApp.fondo,
                child: Text(
                  '${etapa.index + 1}',
                  style: TextStyle(
                    color: activa ? Colors.white : ColoresApp.atenuado,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  etapa.titulo,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: activa ? ColoresApp.azulMarino : ColoresApp.tinta,
                    fontSize: 12.5,
                    fontWeight: activa ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
              if (activa)
                const Icon(
                  Icons.check_circle,
                  size: 16,
                  color: ColoresApp.azul,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _resumenServicio() {
    final reporte = _reporteActual;
    return Container(
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
            '${reporte.categoria} · ${reporte.subcategoria}',
            style: const TextStyle(
              color: ColoresApp.azulMarino,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Ubicación: ${reporte.ubicacion}',
            style: const TextStyle(color: ColoresApp.tinta, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            'Unidades principales: ${reporte.unidadesTexto}',
            style: const TextStyle(color: ColoresApp.tinta, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _contenidoEtapa() => switch (_etapa) {
    _EtapaFormulario.eventos => _contenidoEventos(),
    _EtapaFormulario.corporaciones => _contenidoCorporaciones(),
    _EtapaFormulario.unidades => _contenidoUnidades(),
    _EtapaFormulario.cierre => _contenidoCierre(),
  };

  Widget _contenidoEventos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const EtiquetaCampo('Descripción de los hechos y acciones realizadas'),
        const SizedBox(height: 8),
        CampoTextoSire(
          fieldKey: const ValueKey('service-events'),
          controller: _eventosController,
          onChanged: (_) => _guardarBorrador(),
          hintText: 'Describe lo ocurrido durante la atención, las acciones realizadas y los resultados observados',
          maxLines: 6,
          keyboardType: TextInputType.multiline,
        ),
      ],
    );
  }

  Widget _contenidoCorporaciones() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Selecciona todas las corporaciones que brindaron apoyo.',
          style: TextStyle(color: ColoresApp.atenuado, fontSize: 13),
        ),
        const SizedBox(height: 12),
        for (var indice = 0; indice < _corporaciones.length; indice++) ...[
          _tarjetaCorporacion(_corporaciones[indice], indice),
          if (indice < _corporaciones.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _tarjetaCorporacion(_CorporacionApoyo corporacion, int indice) {
    final seleccionada = _corporacionesSeleccionadas.contains(
      corporacion.nombre,
    );
    final acento = _acentoCorporacion(indice);
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => _alternarCorporacion(corporacion),
      child: Container(
        constraints: const BoxConstraints(minHeight: 58),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: seleccionada ? acento.withValues(alpha: .09) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: seleccionada ? acento : ColoresApp.linea,
            width: seleccionada ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              seleccionada ? Icons.check_circle : Icons.circle_outlined,
              size: 20,
              color: seleccionada ? acento : ColoresApp.atenuado,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                corporacion.nombre,
                style: TextStyle(
                  color: ColoresApp.tinta,
                  fontSize: 14,
                  fontWeight: seleccionada ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
            if (seleccionada)
              Text(
                'Seleccionada',
                style: TextStyle(
                  color: acento,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _contenidoUnidades() {
    final seleccionadas = [
      for (final corporacion in _corporaciones)
        if (_corporacionesSeleccionadas.contains(corporacion.nombre))
          corporacion,
    ];
    if (seleccionadas.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CajaInfo(
            'No hay corporaciones seleccionadas. Regresa a Corporaciones de apoyo para agregar alguna, o continúa al cierre del servicio.',
            fondo: ColoresApp.azulClaro,
            colorTexto: ColoresApp.azulMarino,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _cambiarEtapa(_EtapaFormulario.corporaciones),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Ir a Corporaciones de apoyo'),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var indice = 0; indice < seleccionadas.length; indice++) ...[
          _seccionCorporacion(seleccionadas[indice], indice),
          if (indice < seleccionadas.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }

  Widget _seccionCorporacion(_CorporacionApoyo corporacion, int indice) {
    final unidades = _unidadesPorCorporacion[corporacion.nombre] ?? const [];
    final acento = _acentoCorporacion(indice);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: acento.withValues(alpha: .055),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: acento.withValues(alpha: .45), width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 5,
                height: 32,
                decoration: BoxDecoration(
                  color: acento,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  corporacion.nombre,
                  style: TextStyle(
                    color: acento,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${unidades.length} ${unidades.length == 1 ? 'unidad' : 'unidades'}',
                style: const TextStyle(
                  color: ColoresApp.atenuado,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (unidades.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'Sin unidades externas registradas.',
                style: TextStyle(color: ColoresApp.atenuado, fontSize: 13),
              ),
            ),
          for (
            var indiceUnidad = 0;
            indiceUnidad < unidades.length;
            indiceUnidad++
          ) ...[
            _tarjetaUnidad(
              corporacion,
              unidades[indiceUnidad],
              indiceUnidad,
              acento,
            ),
            if (indiceUnidad < unidades.length - 1) const SizedBox(height: 9),
          ],
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => _agregarUnidad(corporacion),
              icon: const Icon(Icons.add),
              label: Text(
                unidades.isEmpty ? 'Agregar unidad' : 'Agregar otra unidad',
              ),
              style: TextButton.styleFrom(foregroundColor: acento),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tarjetaUnidad(
    _CorporacionApoyo corporacion,
    _BorradorUnidadApoyo unidad,
    int indice,
    Color acento,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ColoresApp.linea),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Unidad ${indice + 1}',
            style: TextStyle(
              color: acento,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const EtiquetaCampo('Número o clave de identificación de la unidad'),
          const SizedBox(height: 7),
          CampoTextoSire(
            fieldKey: ValueKey('${corporacion.nombre}-$indice-identificador'),
            controller: unidad.identificador,
            onChanged: (_) => _guardarBorrador(),
            hintText: 'Identificación de la unidad',
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 12),
          const EtiquetaCampo('Responsable'),
          const SizedBox(height: 7),
          CampoTextoSire(
            fieldKey: ValueKey('${corporacion.nombre}-$indice-responsable'),
            controller: unidad.responsable,
            onChanged: (_) => _guardarBorrador(),
            hintText: 'Nombre completo',
          ),
          if (unidad.tripulantes.isNotEmpty) ...[
            const SizedBox(height: 14),
            const EtiquetaCampo('Tripulantes'),
            for (
              var numero = 0;
              numero < unidad.tripulantes.length;
              numero++
            ) ...[
              const SizedBox(height: 8),
              CampoTextoSire(
                fieldKey: ValueKey(
                  '${corporacion.nombre}-$indice-tripulante-$numero',
                ),
                controller: unidad.tripulantes[numero],
                onChanged: (_) => _guardarBorrador(),
                hintText: 'Nombre completo del tripulante',
              ),
            ],
          ],
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => _agregarTripulante(unidad),
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Agregar tripulante'),
              style: TextButton.styleFrom(foregroundColor: acento),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contenidoCierre() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const EtiquetaCampo('Observaciones finales y resultado del servicio'),
        const SizedBox(height: 8),
        CampoTextoSire(
          fieldKey: const ValueKey('service-closure'),
          controller: _cierreController,
          onChanged: (_) => _guardarBorrador(),
          hintText: 'Describe el resultado de la atención y cualquier información final relevante',
          maxLines: 5,
          keyboardType: TextInputType.multiline,
        ),
        const SizedBox(height: 8),
        const Text(
          'Este apartado complementa el reporte del servicio.',
          style: TextStyle(fontSize: 12, color: ColoresApp.atenuado),
        ),
      ],
    );
  }

  List<Widget> _accionesEtapa() => switch (_etapa) {
    _EtapaFormulario.eventos => [
      BotonSire(etiqueta: 'CONTINUAR', alPresionar: _continuar),
    ],
    _EtapaFormulario.corporaciones => [
      BotonSire(etiqueta: 'CONTINUAR', alPresionar: _continuar),
      const SizedBox(height: 10),
      BotonSire(
        etiqueta: 'SIN CORPORACIONES DE APOYO',
        conBorde: true,
        tamanoFuente: 15,
        alPresionar: _sinCorporacionesApoyo,
      ),
      const SizedBox(height: 10),
      BotonSire(etiqueta: 'ANTERIOR', conBorde: true, alPresionar: _anterior),
    ],
    _EtapaFormulario.unidades => [
      Row(
        children: [
          Expanded(
            child: BotonSire(
              etiqueta: 'ANTERIOR',
              conBorde: true,
              tamanoFuente: 14,
              alPresionar: _anterior,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: BotonSire(
              etiqueta: 'CONTINUAR',
              tamanoFuente: 14,
              alPresionar: _continuar,
            ),
          ),
        ],
      ),
    ],
    _EtapaFormulario.cierre => [
      BotonSire(etiqueta: 'ANTERIOR', conBorde: true, alPresionar: _anterior),
      const SizedBox(height: 10),
      BotonSire(
        etiqueta: 'ENVIAR REPORTE A CENTRAL',
        alPresionar: _enviarReporte,
      ),
    ],
  };

  Color _acentoCorporacion(int indice) =>
      _acentosCorporacion[indice % _acentosCorporacion.length];
}

enum _EtapaFormulario { eventos, corporaciones, unidades, cierre }

extension on _EtapaFormulario {
  String get titulo => switch (this) {
    _EtapaFormulario.eventos => 'Eventos del servicio',
    _EtapaFormulario.corporaciones => 'Corporaciones de apoyo',
    _EtapaFormulario.unidades => 'Unidades y tripulación',
    _EtapaFormulario.cierre => 'Cierre del servicio',
  };
}

class _CorporacionApoyo {
  const _CorporacionApoyo(this.nombre);

  final String nombre;
}

class _BorradorUnidadApoyo {
  _BorradorUnidadApoyo()
    : identificador = TextEditingController(),
      responsable = TextEditingController(),
      tripulantes = [];

  _BorradorUnidadApoyo.desdeReporte(UnidadApoyoReporte reporte)
    : identificador = TextEditingController(text: reporte.identificador),
      responsable = TextEditingController(text: reporte.responsable),
      tripulantes = [
        for (final nombre in reporte.tripulacion)
          TextEditingController(text: nombre),
      ];

  final TextEditingController identificador;
  final TextEditingController responsable;
  final List<TextEditingController> tripulantes;

  void dispose() {
    identificador.dispose();
    responsable.dispose();
    for (final tripulante in tripulantes) {
      tripulante.dispose();
    }
  }
}
