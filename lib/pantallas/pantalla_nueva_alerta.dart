import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../componentes/barra_superior.dart';
import '../componentes/widgets_comunes.dart';
import '../componentes/widgets_formulario.dart';
import '../datos/repositorio_reportes.dart';
import '../modelos/configuracion_campos_alerta.dart';
import '../modelos/reporte_servicio.dart';
import '../modelos/tripulacion_unidad.dart';
import '../tema/colores_app.dart';
import 'pantalla_bitacora.dart';

part '../componentes/nueva_alerta/nueva_alerta_widgets.dart';
part '../componentes/nueva_alerta/nueva_alerta_pasos.dart';
part '../datos/nueva_alerta_datos.dart';

/// Formulario local para preparar una alerta desde la central.
/// La confirmación conserva el flujo existente hacia la bitácora; no realiza
/// una transmisión a las unidades.
class PantallaNuevaAlerta extends StatefulWidget {
  const PantallaNuevaAlerta({super.key});

  @override
  State<PantallaNuevaAlerta> createState() => _PantallaNuevaAlertaState();
}

class _PantallaNuevaAlertaState extends State<PantallaNuevaAlerta> {
  static const _titulosPasos = [
    'Tipo de emergencia',
    'Detalles de la emergencia',
    'Reporte y ubicación',
    'Unidades y prioridad',
    'Resumen y confirmación',
  ];

  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final Map<String, TextEditingController> _controladores = {};
  final Map<String, String> _selecciones = {};
  final Map<String, Set<String>> _seleccionesMultiples = {};
  final Map<String, DateTime> _fechasHoras = {};
  final Map<IntegranteApoyo, GlobalKey> _clavesIntegrantesApoyo = {};
  bool _mostrarErrores = false;
  bool _confirmacionMarcada = false;
  int _pasoActual = 0;

  final Set<String> _unidadesSeleccionadas = {};
  final Map<String, TripulacionUnidad> _tripulacionesPorUnidad = {};
  String? _unidadActiva;

  String _prioridadSeleccionada = 'Alta';
  String? _tipoSolicitante;
  String? _categoriaSeleccionada;
  String? _subcategoriaSeleccionada;

  TextEditingController _controlador(String id) {
    return _controladores.putIfAbsent(id, TextEditingController.new);
  }

  String _valor(String id) => _controladores[id]?.text.trim() ?? '';

  @override
  void dispose() {
    for (final controlador in _controladores.values) {
      controlador.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const BarraSuperiorSire(titulo: 'Nueva alerta', mostrarAtras: true),
            _IndicadorProgreso(pasoActual: _pasoActual, titulos: _titulosPasos),
            Expanded(
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: Form(key: _formKey, child: _contenidoPaso()),
                    ),
                  ),
                ),
              ),
            ),
            _NavegacionPasos(
              puedeRetroceder: _pasoActual > 0,
              esUltimoPaso: _pasoActual == _titulosPasos.length - 1,
              alRetroceder: _anterior,
              alContinuar: _avanzar,
            ),
          ],
        ),
      ),
    );
  }

  TripulacionUnidad _tripulacionDe(String unidad) {
    return _tripulacionesPorUnidad.putIfAbsent(unidad, TripulacionUnidad.new);
  }

  Future<void> _cambiarSeleccionUnidad(String unidad) async {
    if (!_unidadesSeleccionadas.contains(unidad)) {
      setState(() {
        _unidadesSeleccionadas.add(unidad);
        _tripulacionDe(unidad);
        _unidadActiva = unidad;
      });
      return;
    }

    final tripulacion = _tripulacionesPorUnidad[unidad];
    if (tripulacion?.tieneDatos == true) {
      final confirmar = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('¿Deseas deseleccionar $unidad?'),
          content: Text(
            'La unidad dejará de incluirse en esta alerta. Sus datos de tripulación se conservarán mientras el formulario siga abierto y estarán disponibles si vuelves a seleccionarla.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Deseleccionar'),
            ),
          ],
        ),
      );
      if (confirmar != true || !mounted) return;
    }

    setState(() {
      _unidadesSeleccionadas.remove(unidad);
      if (_unidadActiva == unidad) {
        final restantes = _unidadesDisponibles
            .where(_unidadesSeleccionadas.contains)
            .toList();
        _unidadActiva = restantes.isEmpty ? null : restantes.first;
      }
    });
  }

  Widget _formularioTripulacion(String unidad, TripulacionUnidad tripulacion) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _tituloSeccion(Icons.groups_outlined, 'Tripulación de $unidad'),
        _campoNombreTripulante(
          id: 'maquinista:$unidad',
          etiqueta: 'Maquinista (nombre completo)',
          valor: tripulacion.maquinista,
          alCambiar: (valor) => setState(() {
            tripulacion.maquinista = valor;
          }),
        ),
        _campoNombreTripulante(
          id: 'jefe_servicio:$unidad',
          etiqueta: 'Jefe de servicio (nombre completo)',
          valor: tripulacion.jefeServicio,
          alCambiar: (valor) => setState(() {
            tripulacion.jefeServicio = valor;
          }),
        ),
        const SizedBox(height: 4),
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            'Personal de apoyo',
            style: TextStyle(
              color: ColoresApp.azulMarino,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (tripulacion.personalApoyo.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 14),
            child: Text(
              'Aún no se agregan integrantes de apoyo.',
              style: TextStyle(color: ColoresApp.atenuado, fontSize: 13),
            ),
          ),
        for (
          var indice = 0;
          indice < tripulacion.personalApoyo.length;
          indice++
        )
          _campoIntegranteApoyo(
            unidad,
            indice,
            tripulacion.personalApoyo[indice],
            tripulacion,
          ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () => _agregarPersonalApoyo(tripulacion),
            icon: const Icon(Icons.add),
            label: const Text('Agregar personal'),
          ),
        ),
      ],
    );
  }

  void _agregarPersonalApoyo(TripulacionUnidad tripulacion) {
    final integrante = IntegranteApoyo();
    final clave = GlobalKey();
    _clavesIntegrantesApoyo[integrante] = clave;
    setState(() => tripulacion.personalApoyo.add(integrante));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final contexto = clave.currentContext;
      if (!mounted || contexto == null) return;
      unawaited(
        Scrollable.ensureVisible(
          contexto,
          alignment: 0.18,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        ),
      );
    });
  }

  Widget _campoIntegranteApoyo(
    String unidad,
    int indice,
    IntegranteApoyo integrante,
    TripulacionUnidad tripulacion,
  ) {
    final clave = identityHashCode(integrante);
    return Container(
      key: _clavesIntegrantesApoyo.putIfAbsent(integrante, GlobalKey.new),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColoresApp.fondo,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColoresApp.linea),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Integrante ${indice + 1}',
                  style: const TextStyle(
                    color: ColoresApp.azulMarino,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Eliminar integrante',
                onPressed: () => setState(() {
                  tripulacion.personalApoyo.remove(integrante);
                  _clavesIntegrantesApoyo.remove(integrante);
                }),
                icon: const Icon(Icons.delete_outline),
                color: ColoresApp.rojo,
              ),
            ],
          ),
          _campoNombreTripulante(
            id: 'apoyo_nombre:$unidad:$clave',
            etiqueta: 'Nombre completo',
            valor: integrante.nombreCompleto,
            alCambiar: (valor) => setState(() {
              integrante.nombreCompleto = valor;
            }),
          ),
          _campoConEtiqueta(
            'Rango o función',
            DropdownButtonFormField<String>(
              key: ValueKey('apoyo_rango:$unidad:$clave'),
              initialValue: integrante.rangoFuncion,
              isExpanded: true,
              decoration: _decoracionCampo(),
              hint: const Text('Selecciona un rango o función'),
              validator: (valor) =>
                  valor == null ? 'Selecciona un rango o función.' : null,
              items: _rangosApoyo
                  .map(
                    (rango) => DropdownMenuItem<String>(
                      value: rango,
                      child: Text(rango),
                    ),
                  )
                  .toList(),
              onChanged: (valor) {
                if (valor == null) return;
                setState(() => integrante.rangoFuncion = valor);
              },
            ),
            requerido: true,
          ),
        ],
      ),
    );
  }

  List<MapEntry<String, String>> _camposResumenSolicitante() {
    late final List<MapEntry<String, String>> campos;
    switch (_tipoSolicitante) {
      case 'C4 (Central)':
        campos = const [
          MapEntry('Nombre del reportante', 'solicitante:c4_nombre'),
          MapEntry('Teléfono del reportante', 'solicitante:c4_telefono'),
        ];
        break;
      case 'Elemento BYP':
        campos = const [
          MapEntry('Nombre completo', 'solicitante:byp_nombre'),
          MapEntry('Teléfono', 'solicitante:byp_telefono'),
        ];
        break;
      case 'Persona (Civil)':
      case 'Reporte directo':
        campos = const [
          MapEntry('Nombre del reportante', 'solicitante:civil_nombre'),
          MapEntry('Teléfono', 'solicitante:civil_telefono'),
        ];
        break;
      case 'Compañía de Gas (Convenio)':
        campos = const [
          MapEntry('Compañía', 'solicitante:gas_compania'),
          MapEntry('Nombre del que habla', 'solicitante:gas_habla'),
          MapEntry('Nombre del que reportó', 'solicitante:gas_reporto'),
          MapEntry('Teléfono del reportante', 'solicitante:gas_telefono'),
        ];
        break;
      default:
        campos = const [];
    }

    return campos
        .map(
          (campo) => MapEntry(
            campo.key,
            _valor(campo.value).ifEmpty('No especificado'),
          ),
        )
        .toList();
  }

  void _seleccionarCategoria(String categoria) {
    if (_categoriaSeleccionada == categoria) return;
    _limpiarDetallesEmergencia();
    setState(() {
      _categoriaSeleccionada = categoria;
      _subcategoriaSeleccionada = null;
      _mostrarErrores = false;
    });
  }

  void _seleccionarSubcategoria(String? subcategoria) {
    if (subcategoria == null || subcategoria == _subcategoriaSeleccionada) {
      return;
    }
    _limpiarDetallesEmergencia();
    setState(() {
      _subcategoriaSeleccionada = subcategoria;
      _mostrarErrores = false;
    });
  }

  void _limpiarDetallesEmergencia() {
    for (final entrada in _controladores.entries) {
      if (entrada.key.startsWith('detalle:')) {
        entrada.value.clear();
      }
    }
    _selecciones.removeWhere((id, _) => id.startsWith('detalle:'));
    _seleccionesMultiples.removeWhere((id, _) => id.startsWith('detalle:'));
    _fechasHoras.removeWhere((id, _) => id.startsWith('detalle:'));
  }

  String _idCampoEmergencia(String categoria, String subtipo, String id) {
    return 'detalle:$categoria:$subtipo:$id';
  }

  Widget _construirCampoAlerta(CampoAlerta campo, String id) {
    switch (campo.tipo) {
      case TipoCampoAlerta.textoCorto:
      case TipoCampoAlerta.textoLargo:
        final editor = _campoTexto(
          id: id,
          etiqueta: campo.etiqueta,
          sugerencia: campo.permiteDesconocido
              ? 'Ingresa el dato si se conoce'
              : 'Escribe aquí',
          requerido: campo.obligatorio,
          multilinea: campo.tipo == TipoCampoAlerta.textoLargo,
          validator: (valor) => _validarTexto(campo, valor),
        );
        if (!campo.permiteDesconocido) return editor;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            editor,
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {
                  _controlador(id).text = 'Desconocido';
                  setState(() {});
                },
                icon: const Icon(Icons.help_outline, size: 18),
                label: const Text('Marcar como desconocido'),
              ),
            ),
          ],
        );
      case TipoCampoAlerta.seleccion:
        return _campoSeleccion(campo, id);
      case TipoCampoAlerta.cantidad:
        return _campoCantidad(campo, id);
      case TipoCampoAlerta.seleccionMultipleLibre:
        return _campoSeleccionMultipleLibre(campo, id);
      case TipoCampoAlerta.hora:
        return _campoTemporal(campo, id, soloHora: true);
      case TipoCampoAlerta.fechaYHora:
        return _campoTemporal(campo, id, soloHora: false);
    }
  }

  String? _validarTexto(CampoAlerta campo, String? valor) {
    if (!campo.obligatorio) return null;
    return valor == null || valor.trim().isEmpty
        ? 'Completa este campo o marca “Desconocido” si corresponde.'
        : null;
  }

  Widget _campoSeleccion(CampoAlerta campo, String id) {
    return _campoDropdown(
      id: id,
      etiqueta: campo.etiqueta,
      opciones: campo.opciones,
      requerido: campo.obligatorio,
    );
  }

  Widget _campoDropdown({
    required String id,
    required String etiqueta,
    required List<String> opciones,
    required bool requerido,
    FormFieldValidator<String>? validator,
  }) {
    return _campoConEtiqueta(
      etiqueta,
      DropdownButtonFormField<String>(
        key: ValueKey(id),
        initialValue: _selecciones[id],
        isExpanded: true,
        decoration: _decoracionCampo(),
        hint: const Text('Selecciona una opción'),
        validator:
            validator ??
            (valor) =>
                requerido && valor == null ? 'Selecciona una opción.' : null,
        items: opciones
            .map(
              (opcion) =>
                  DropdownMenuItem<String>(value: opcion, child: Text(opcion)),
            )
            .toList(),
        onChanged: (valor) {
          if (valor == null) return;
          setState(() => _selecciones[id] = valor);
        },
      ),
      requerido: requerido,
    );
  }

  Widget _campoCantidad(CampoAlerta campo, String id) {
    final formateador = TextInputFormatter.withFunction((anterior, nuevo) {
      final patron = campo.decimal
          ? RegExp(r'^\d*(\.\d*)?$')
          : RegExp(r'^\d*$');
      return patron.hasMatch(nuevo.text) ? nuevo : anterior;
    });
    final entrada = _campoTexto(
      id: id,
      etiqueta: campo.etiqueta,
      sugerencia: 'Ingresa una cantidad',
      requerido: campo.obligatorio,
      teclado: TextInputType.numberWithOptions(decimal: campo.decimal),
      sufijo: campo.unidadFija,
      formateadores: [formateador],
      validator: (valor) => _validarCantidad(campo, id, valor),
    );

    if (campo.unidades == null) return entrada;
    final idUnidad = '$id:unidad';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        entrada,
        _campoDropdown(
          id: idUnidad,
          etiqueta: 'Unidad',
          opciones: campo.unidades!,
          requerido: _valor(id).isNotEmpty,
          validator: (valor) => _valor(id).isNotEmpty && valor == null
              ? 'Selecciona la unidad de la cantidad.'
              : null,
        ),
      ],
    );
  }

  String? _validarCantidad(CampoAlerta campo, String id, String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.isEmpty) {
      return campo.obligatorio ? 'Ingresa una cantidad.' : null;
    }
    final cantidad = num.tryParse(texto);
    if (cantidad == null) return 'Ingresa un número válido.';
    if (cantidad < 0) return 'La cantidad no puede ser negativa.';
    if (campo.unidades != null && _selecciones['$id:unidad'] == null) {
      return 'Selecciona la unidad de la cantidad.';
    }
    return null;
  }

  Widget _campoSeleccionMultipleLibre(CampoAlerta campo, String id) {
    final idEntrada = '$id:captura';
    return FormField<Set<String>>(
      key: ValueKey('$id:form'),
      initialValue: Set<String>.of(_seleccionesMultiples[id] ?? const {}),
      validator: (valores) =>
          campo.obligatorio && (valores == null || valores.isEmpty)
          ? 'Agrega al menos una opción.'
          : null,
      builder: (estado) {
        final opcionesElegidas = _seleccionesMultiples[id] ?? <String>{};
        final controladorEntrada = _controlador(idEntrada);

        void agregarValor() {
          final texto = controladorEntrada.text.trim();
          if (texto.isEmpty) return;
          final elegidas = _seleccionesMultiples.putIfAbsent(
            id,
            () => <String>{},
          );
          elegidas.add(texto);
          controladorEntrada.clear();
          estado.didChange(Set<String>.of(elegidas));
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _etiquetaCampo(campo.etiqueta, requerido: campo.obligatorio),
              const SizedBox(height: 7),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controladorEntrada,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => agregarValor(),
                      decoration: _decoracionCampo().copyWith(
                        hintText: 'Escribe un tipo de vehículo',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    tooltip: 'Agregar opción',
                    onPressed: agregarValor,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              if (opcionesElegidas.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: opcionesElegidas.map((opcion) {
                    return InputChip(
                      label: Text(opcion),
                      onDeleted: () {
                        opcionesElegidas.remove(opcion);
                        estado.didChange(Set<String>.of(opcionesElegidas));
                      },
                    );
                  }).toList(),
                ),
              ],
              if (estado.errorText != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 12),
                  child: Text(
                    estado.errorText!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _campoTemporal(
    CampoAlerta campo,
    String id, {
    required bool soloHora,
  }) {
    bool completo() => soloHora
        ? _fechasHoras.containsKey(id)
        : _fechasHoras.containsKey('$id:fecha') &&
              _fechasHoras.containsKey('$id:hora');

    return FormField<bool>(
      key: ValueKey('$id:temporal'),
      validator: (_) => campo.obligatorio && !completo()
          ? soloHora
                ? 'Selecciona una hora.'
                : 'Selecciona la fecha y la hora.'
          : null,
      builder: (estado) {
        final botonFecha = OutlinedButton.icon(
          onPressed: soloHora
              ? null
              : () async {
                  await _elegirFecha('$id:fecha');
                  if (mounted) estado.didChange(completo());
                },
          icon: const Icon(Icons.calendar_today_outlined, size: 18),
          label: Text(
            soloHora
                ? 'Hora'
                : _fechasHoras.containsKey('$id:fecha')
                ? _formatearFecha(_fechasHoras['$id:fecha']!)
                : 'Elegir fecha',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
        final botonHora = OutlinedButton.icon(
          onPressed: () async {
            await _elegirHora(soloHora ? id : '$id:hora');
            if (mounted) estado.didChange(completo());
          },
          icon: const Icon(Icons.access_time, size: 18),
          label: Text(
            soloHora
                ? _fechasHoras.containsKey(id)
                      ? _formatearHora(_fechasHoras[id]!)
                      : 'Elegir hora'
                : _fechasHoras.containsKey('$id:hora')
                ? _formatearHora(_fechasHoras['$id:hora']!)
                : 'Elegir hora',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );

        return _campoConEtiqueta(
          campo.etiqueta,
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  if (!soloHora) ...[
                    Expanded(child: botonFecha),
                    const SizedBox(width: 8),
                  ],
                  Expanded(child: botonHora),
                ],
              ),
              if (estado.errorText != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 12),
                  child: Text(
                    estado.errorText!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          requerido: campo.obligatorio,
        );
      },
    );
  }

  Future<void> _elegirFecha(String id) async {
    final hoy = DateTime.now();
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechasHoras[id] ?? hoy,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (fecha == null || !mounted) return;
    setState(() => _fechasHoras[id] = fecha);
  }

  Future<void> _elegirHora(String id) async {
    final actual = _fechasHoras[id];
    final hora = await showTimePicker(
      context: context,
      initialTime: actual == null
          ? TimeOfDay.now()
          : TimeOfDay.fromDateTime(actual),
    );
    if (hora == null || !mounted) return;
    setState(() {
      _fechasHoras[id] = DateTime(2000, 1, 1, hora.hour, hora.minute);
    });
  }

  String _valorCampo(CampoAlerta campo, String id) {
    switch (campo.tipo) {
      case TipoCampoAlerta.textoCorto:
      case TipoCampoAlerta.textoLargo:
        return _valor(id)
            .ifEmpty(campo.obligatorio ? 'Sin capturar' : 'No especificado');
      case TipoCampoAlerta.seleccion:
        return _selecciones[id] ??
            (campo.obligatorio ? 'Sin seleccionar' : 'No especificado');
      case TipoCampoAlerta.cantidad:
        final cantidad = _valor(id);
        if (cantidad.isEmpty) {
          return campo.obligatorio ? 'Sin capturar' : 'No especificado';
        }
        final unidad =
            campo.unidadFija ??
            (campo.unidades == null ? null : _selecciones['$id:unidad']);
        return unidad == null ? cantidad : '$cantidad $unidad';
      case TipoCampoAlerta.seleccionMultipleLibre:
        final valores = _seleccionesMultiples[id] ?? const <String>{};
        return valores.isEmpty
            ? campo.obligatorio
                  ? 'Sin capturar'
                  : 'No especificado'
            : valores.join(', ');
      case TipoCampoAlerta.hora:
        final hora = _fechasHoras[id];
        return hora == null
            ? campo.obligatorio
                  ? 'Sin capturar'
                  : 'No especificado'
            : _formatearHora(hora);
      case TipoCampoAlerta.fechaYHora:
        final fecha = _fechasHoras['$id:fecha'];
        final hora = _fechasHoras['$id:hora'];
        if (fecha == null && hora == null) {
          return campo.obligatorio ? 'Sin capturar' : 'No especificado';
        }
        return [
          if (fecha != null) _formatearFecha(fecha),
          if (hora != null) _formatearHora(hora),
        ].join(' · ');
    }
  }

  ReporteServicio _crearReporteDesdeFormulario() {
    final categoria = _categoriaSeleccionada!;
    final subcategoria = _subcategoriaSeleccionada!;
    final configuracion =
        ConfiguracionCamposAlerta.porCategoria[categoria]![subcategoria]!;
    final camposFormulario = {
      for (final campo in configuracion)
        campo.id: _valorCampo(
          campo,
          _idCampoEmergencia(categoria, subcategoria, campo.id),
        ),
    };
    final detallesUbicacion = <String, String>{
      'Colonia': _valor('ubicacion:colonia').ifEmpty('No especificado'),
      'Calle': _valor('ubicacion:calle').ifEmpty('No especificado'),
      'Número': _valor('ubicacion:numero').ifEmpty('No especificado'),
      'Referencias': _valor('ubicacion:referencias').ifEmpty('No especificado'),
    };
    final partesUbicacion = [
      detallesUbicacion['Calle']!,
      detallesUbicacion['Número']!,
      detallesUbicacion['Colonia']!,
    ].where((parte) => parte != 'No especificado').toList();
    final datosSolicitante = {
      for (final entrada in _camposResumenSolicitante())
        entrada.key: entrada.value == 'Sin capturar'
            ? 'No especificado'
            : entrada.value,
    };
    final personal = <PersonalReporte>[];
    for (final unidad in _unidadesDisponibles.where(
      _unidadesSeleccionadas.contains,
    )) {
      final tripulacion = _tripulacionDe(unidad);
      if (tripulacion.maquinista.trim().isNotEmpty) {
        personal.add(
          PersonalReporte(
            nombre: tripulacion.maquinista.trim(),
            funcion: 'Maquinista',
            unidad: unidad,
          ),
        );
      }
      if (tripulacion.jefeServicio.trim().isNotEmpty) {
        personal.add(
          PersonalReporte(
            nombre: tripulacion.jefeServicio.trim(),
            funcion: 'Jefe de servicio',
            unidad: unidad,
          ),
        );
      }
      for (final integrante in tripulacion.personalApoyo) {
        personal.add(
          PersonalReporte(
            nombre: integrante.nombreCompleto.trim(),
            funcion: integrante.rangoFuncion ?? 'No especificado',
            unidad: unidad,
          ),
        );
      }
    }

    return ReporteServicio(
      id: ReportesRepositorio.instancia.crearId(),
      folio: _valor('general:folio'),
      categoria: categoria,
      subcategoria: subcategoria,
      camposFormulario: camposFormulario,
      ubicacion: partesUbicacion.isEmpty
          ? 'No especificado'
          : partesUbicacion.join(', '),
      detallesUbicacion: detallesUbicacion,
      solicitante: _tipoSolicitante!,
      datosSolicitante: datosSolicitante,
      unidadesAsignadas: _unidadesDisponibles
          .where(_unidadesSeleccionadas.contains)
          .toList(),
      prioridad: _prioridadSeleccionada,
      personal: personal,
      apoyoExterno: 'No especificado',
      estado: 'Asignada',
      cronologia: const [
        EventoCronologia(
          titulo: 'Reporte enviado',
          hora: '15:00',
          completado: true,
          detalle: 'Central',
        ),
        EventoCronologia(
          titulo: 'Salida de base',
          hora: '--:--',
          completado: false,
          detalle: 'Pendiente',
        ),
        EventoCronologia(
          titulo: 'Llegada al lugar',
          hora: '--:--',
          completado: false,
          detalle: 'Pendiente',
        ),
        EventoCronologia(
          titulo: 'Inicio de atención',
          hora: '--:--',
          completado: false,
          detalle: 'Pendiente',
        ),
        EventoCronologia(
          titulo: 'Salida del lugar / traslado',
          hora: '--:--',
          completado: false,
          detalle: 'Pendiente',
        ),
        EventoCronologia(
          titulo: 'Fin del servicio',
          hora: '--:--',
          completado: false,
          detalle: 'Pendiente',
        ),
      ],
    );
  }

  String _formatearFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    return '$dia/$mes/${fecha.year}';
  }

  String _formatearHora(DateTime fecha) {
    final hora = fecha.hour.toString().padLeft(2, '0');
    final minuto = fecha.minute.toString().padLeft(2, '0');
    return '$hora:$minuto';
  }

  String? Function(String?) _validarObligatorio(String mensaje) {
    return (valor) => valor == null || valor.trim().isEmpty ? mensaje : null;
  }

  String? _validarTelefono(String? valor, {required bool requerido}) {
    final texto = valor?.trim() ?? '';
    if (texto.isEmpty) return requerido ? 'Ingresa el teléfono.' : null;
    final digitos = texto.replaceAll(RegExp(r'\D'), '');
    return digitos.length >= 10 ? null : 'Ingresa un teléfono de 10 dígitos.';
  }

  bool _validarPasoActual() {
    final formularioValido = _formKey.currentState?.validate() ?? true;
    if (!formularioValido) return false;

    switch (_pasoActual) {
      case 0:
        return _categoriaSeleccionada != null &&
            _subcategoriaSeleccionada != null;
      case 1:
        return _categoriaSeleccionada != null &&
            _subcategoriaSeleccionada != null;
      case 2:
        return _tipoSolicitante != null;
      case 3:
        if (_unidadesSeleccionadas.isEmpty) return false;
        for (final unidad in _unidadesDisponibles) {
          if (!_unidadesSeleccionadas.contains(unidad)) continue;
          if (_tripulacionDe(unidad).completa) continue;
          if (_unidadActiva != unidad) {
            setState(() => _unidadActiva = unidad);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _formKey.currentState?.validate();
            });
          }
          return false;
        }
        return true;
      case 4:
        return _confirmacionMarcada;
      default:
        return false;
    }
  }

  String _mensajeValidacionPaso() {
    switch (_pasoActual) {
      case 0:
        if (_categoriaSeleccionada == null) {
          return 'Selecciona una categoría de emergencia.';
        }
        return 'Selecciona una subcategoría para continuar.';
      case 1:
        return 'Completa los campos obligatorios de esta subcategoría.';
      case 2:
        if (_tipoSolicitante == null) return 'Selecciona quién reporta.';
        return 'Revisa el teléfono y la colonia y calle obligatorias.';
      case 3:
        if (_unidadesSeleccionadas.isEmpty) {
          return 'Selecciona al menos una unidad.';
        }
        return 'Completa el maquinista, el jefe de servicio y los datos de cada integrante agregado en todas las unidades seleccionadas.';
      case 4:
        return 'Confirma que revisaste los datos.';
      default:
        return 'Revisa los datos de este paso.';
    }
  }

  void _avanzar() {
    setState(() => _mostrarErrores = true);
    if (!_validarPasoActual()) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(_mensajeValidacionPaso())));
      return;
    }

    FocusScope.of(context).unfocus();
    if (_pasoActual == _titulosPasos.length - 1) {
      final folio = _valor('general:folio');
      final repositorio = ReportesRepositorio.instancia;
      if (folio.isNotEmpty && repositorio.contieneFolio(folio)) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text('El folio $folio ya está registrado.')),
          );
        return;
      }
      final reporte = _crearReporteDesdeFormulario();
      repositorio.agregar(reporte);
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PantallaBitacora(reporte: reporte)),
      );
      return;
    }

    setState(() {
      _pasoActual++;
      _mostrarErrores = false;
    });
    _irAlInicio();
  }

  void _anterior() {
    if (_pasoActual == 0) return;
    FocusScope.of(context).unfocus();
    setState(() {
      if (_pasoActual == _titulosPasos.length - 1) {
        _confirmacionMarcada = false;
      }
      _pasoActual--;
      _mostrarErrores = false;
    });
    _irAlInicio();
  }

  void _irAlInicio() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) _scrollController.jumpTo(0);
    });
  }
}

extension _TextoNoVacio on String {
  String ifEmpty(String alternativa) => isEmpty ? alternativa : this;
}
