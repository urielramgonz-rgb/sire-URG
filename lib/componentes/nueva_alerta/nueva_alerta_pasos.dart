part of '../../pantallas/pantalla_nueva_alerta.dart';

extension _PantallaNuevaAlertaPasos on _PantallaNuevaAlertaState {
  Widget _contenidoPaso() {
    switch (_pasoActual) {
      case 0:
        return _pasoTipoEmergencia();
      case 1:
        return _pasoDetalles();
      case 2:
        return _pasoReporteYUbicacion();
      case 3:
        return _pasoUnidadesYPrioridad();
      case 4:
        return _pasoResumen();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _pasoTipoEmergencia() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const EtiquetaRol.central(),
        const SizedBox(height: 18),
        _tituloSeccion(Icons.emergency_outlined, 'Tipo de emergencia'),
        const Text(
          'Selecciona una categoría y después el subtipo del servicio.',
          style: TextStyle(color: ColoresApp.atenuado, height: 1.4),
        ),
        const SizedBox(height: 18),
        const EtiquetaCampo('Categoría'),
        const SizedBox(height: 10),
        _construirTarjetasCategoria(),
        if (_mostrarErrores && _categoriaSeleccionada == null)
          _errorSeleccion('Selecciona una categoría para continuar.'),
        const SizedBox(height: 18),
        _campoConEtiqueta('Subcategoría', _construirDropdownSubcategoria()),
        if (_mostrarErrores &&
            _categoriaSeleccionada != null &&
            _subcategoriaSeleccionada == null)
          _errorSeleccion('Selecciona una subcategoría para continuar.'),
      ],
    );
  }

  Widget _pasoDetalles() {
    final categoria = _categoriaSeleccionada;
    final subtipo = _subcategoriaSeleccionada;
    if (categoria == null || subtipo == null) {
      return _aviso('Regresa al paso anterior y selecciona una emergencia.');
    }

    final campos =
        ConfiguracionCamposAlerta.porCategoria[categoria]?[subtipo] ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const EtiquetaRol.central(),
        const SizedBox(height: 18),
        _tituloSeccion(Icons.assignment_outlined, 'Detalles de la emergencia'),
        _ResumenEmergencia(categoria: categoria, subtipo: subtipo),
        const SizedBox(height: 16),
        const Text(
          'Completa los campos obligatorios. Los opcionales pueden quedar vacíos si el dato aún no se conoce.',
          style: TextStyle(color: ColoresApp.atenuado, height: 1.4),
        ),
        const SizedBox(height: 16),
        for (final campo in campos)
          _construirCampoAlerta(
            campo,
            _idCampoEmergencia(categoria, subtipo, campo.id),
          ),
      ],
    );
  }

  Widget _pasoReporteYUbicacion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const EtiquetaRol.central(),
        const SizedBox(height: 18),
        _tituloSeccion(Icons.person_outline, 'Folio y datos del reporte'),
        _campoTexto(
          id: 'general:folio',
          etiqueta: 'Folio C4 (opcional)',
          sugerencia: 'Ingresa un folio si aplica',
        ),
        _campoConEtiqueta('¿Quién reporta?', _construirDropdownSolicitante()),
        if (_mostrarErrores && _tipoSolicitante == null)
          _errorSeleccion('Selecciona quién reporta.'),
        KeyedSubtree(
          key: ValueKey('solicitante_$_tipoSolicitante'),
          child: _construirCamposSolicitante(),
        ),
        const SizedBox(height: 10),
        _tituloSeccion(Icons.location_on_outlined, 'Ubicación del evento'),
        _campoTexto(
          id: 'ubicacion:colonia',
          etiqueta: 'Colonia',
          sugerencia: 'Insurgentes',
          requerido: true,
          validator: _validarObligatorio('Indica la colonia.'),
        ),
        _campoTexto(
          id: 'ubicacion:calle',
          etiqueta: 'Calle',
          sugerencia: 'Fray Bernardo de Cossín',
          requerido: true,
          validator: _validarObligatorio('Indica la calle.'),
        ),
        _campoTexto(
          id: 'ubicacion:numero',
          etiqueta: 'Número (exterior/interior)',
          sugerencia: '133',
          teclado: TextInputType.streetAddress,
        ),
        _campoTexto(
          id: 'ubicacion:referencias',
          etiqueta: 'Datos adicionales (referencias)',
          sugerencia: 'Portón blanco, frente a la plaza',
          multilinea: true,
        ),
      ],
    );
  }

  Widget _construirCamposSolicitante() {
    switch (_tipoSolicitante) {
      case 'C4 (Central)':
        return Column(
          children: [
            _campoTexto(
              id: 'solicitante:c4_nombre',
              etiqueta: 'Nombre del reportante (opcional)',
              sugerencia: 'Nombre del reportante',
            ),
            _campoTexto(
              id: 'solicitante:c4_telefono',
              etiqueta: 'Teléfono del reportante (opcional)',
              sugerencia: '415 000 0000',
              teclado: TextInputType.phone,
              validator: (valor) => _validarTelefono(valor, requerido: false),
            ),
          ],
        );
      case 'Elemento BYP':
        return Column(
          children: [
            _campoTexto(
              id: 'solicitante:byp_nombre',
              etiqueta: 'Nombre completo',
              sugerencia: 'Nombre completo',
              requerido: true,
              validator: _validarObligatorio(
                'Ingresa el nombre del reportante.',
              ),
            ),
            _campoTexto(
              id: 'solicitante:byp_telefono',
              etiqueta: 'Teléfono',
              sugerencia: '415 123 4567',
              teclado: TextInputType.phone,
              requerido: true,
              validator: (valor) => _validarTelefono(valor, requerido: true),
            ),
          ],
        );
      case 'Persona (Civil)':
      case 'Reporte directo':
        return Column(
          children: [
            _campoTexto(
              id: 'solicitante:civil_nombre',
              etiqueta: 'Nombre del reportante',
              sugerencia: 'Nombre completo',
              requerido: true,
              validator: _validarObligatorio(
                'Ingresa el nombre del reportante.',
              ),
            ),
            _campoTexto(
              id: 'solicitante:civil_telefono',
              etiqueta: 'Teléfono',
              sugerencia: '415 123 4567',
              teclado: TextInputType.phone,
              requerido: true,
              validator: (valor) => _validarTelefono(valor, requerido: true),
            ),
          ],
        );
      case 'Compañía de Gas (Convenio)':
        return Column(
          children: [
            _campoTexto(
              id: 'solicitante:gas_compania',
              etiqueta: 'Compañía',
              sugerencia: 'Nombre de la compañía',
            ),
            _campoTexto(
              id: 'solicitante:gas_habla',
              etiqueta: 'Nombre del que habla',
              sugerencia: 'Nombre de quien llama',
            ),
            _campoTexto(
              id: 'solicitante:gas_reporto',
              etiqueta: 'Nombre del que reportó',
              sugerencia: 'Nombre de quien reportó',
            ),
            _campoTexto(
              id: 'solicitante:gas_telefono',
              etiqueta: 'Teléfono del reportante',
              sugerencia: '415 888 9999',
              teclado: TextInputType.phone,
              validator: (valor) => _validarTelefono(valor, requerido: false),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _pasoUnidadesYPrioridad() {
    final unidadActiva = _unidadActiva;
    final tripulacionActiva = unidadActiva == null
        ? null
        : _tripulacionDe(unidadActiva);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const EtiquetaRol.central(),
        const SizedBox(height: 18),
        _tituloSeccion(Icons.local_shipping_outlined, 'Unidades que responden'),
        const Text(
          'Selecciona las unidades que responderán. Toca una tarjeta para abrir su tripulación.',
          style: TextStyle(color: ColoresApp.atenuado, height: 1.4),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final columnas = constraints.maxWidth >= 620 ? 3 : 2;
            final anchoTarjeta =
                (constraints.maxWidth - (columnas - 1) * 10) / columnas;

            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _unidadesDisponibles.map((unidad) {
                final seleccionada = _unidadesSeleccionadas.contains(unidad);
                final tripulacion = _tripulacionesPorUnidad[unidad];
                final estado = !seleccionada
                    ? 'No seleccionada'
                    : tripulacion?.completa == true
                    ? 'Personal registrado'
                    : 'Pendiente';

                return SizedBox(
                  width: anchoTarjeta,
                  child: _TarjetaUnidadTripulacion(
                    unidad: unidad,
                    estado: estado,
                    seleccionada: seleccionada,
                    activa: unidadActiva == unidad,
                    alAbrir: () {
                      if (!seleccionada) {
                        _cambiarSeleccionUnidad(unidad);
                      } else {
                        setState(() => _unidadActiva = unidad);
                      }
                    },
                    alAlternar: () => _cambiarSeleccionUnidad(unidad),
                  ),
                );
              }).toList(),
            );
          },
        ),
        if (_mostrarErrores && _unidadesSeleccionadas.isEmpty)
          _errorSeleccion('Selecciona al menos una unidad.'),
        if (unidadActiva != null && tripulacionActiva != null) ...[
          const SizedBox(height: 20),
          KeyedSubtree(
            key: ValueKey('tripulacion_$unidadActiva'),
            child: _formularioTripulacion(unidadActiva, tripulacionActiva),
          ),
        ] else ...[
          const SizedBox(height: 20),
          const CajaInfo(
            'Selecciona una unidad para registrar su tripulación.',
            fondo: ColoresApp.azulClaro,
            colorTexto: ColoresApp.azulMarino,
          ),
        ],
        const SizedBox(height: 24),
        _tituloSeccion(Icons.flag_outlined, 'Prioridad'),
        _SelectorPrioridad(
          prioridadActual: _prioridadSeleccionada,
          alSeleccionar: (prioridad) {
            setState(() => _prioridadSeleccionada = prioridad);
          },
        ),
      ],
    );
  }

  Widget _campoNombreTripulante({
    required String id,
    required String etiqueta,
    required String valor,
    required ValueChanged<String> alCambiar,
  }) {
    return _campoConEtiqueta(
      etiqueta,
      TextFormField(
        key: ValueKey(id),
        initialValue: valor.isEmpty ? null : valor,
        onChanged: alCambiar,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.next,
        validator: _validarObligatorio('Ingresa el nombre completo.'),
        decoration: _decoracionCampo().copyWith(hintText: 'Nombre completo'),
      ),
      requerido: true,
    );
  }

  Widget _pasoResumen() {
    final categoriaResumen = <MapEntry<String, String>>[
      MapEntry('Categoría', _categoriaSeleccionada ?? 'Sin seleccionar'),
      MapEntry('Subcategoría', _subcategoriaSeleccionada ?? 'Sin seleccionar'),
    ];
    final categoria = _categoriaSeleccionada;
    final subtipo = _subcategoriaSeleccionada;
    final configuracion = categoria == null || subtipo == null
        ? const <CampoAlerta>[]
        : ConfiguracionCamposAlerta.porCategoria[categoria]?[subtipo] ??
              const <CampoAlerta>[];
    final detalles = configuracion
        .map(
          (campo) => MapEntry(
            campo.etiqueta,
            _valorCampo(
              campo,
              _idCampoEmergencia(categoria!, subtipo!, campo.id),
            ),
          ),
        )
        .toList();

    final reporte = <MapEntry<String, String>>[
      MapEntry('Folio C4', _valor('general:folio').ifEmpty('Sin folio')),
      MapEntry(
        'Quién reporta',
        _tipoSolicitante == null
            ? 'Sin seleccionar'
            : _etiquetasTipoSolicitante[_tipoSolicitante] ?? _tipoSolicitante!,
      ),
      ..._camposResumenSolicitante(),
    ];
    final ubicacion = [
      MapEntry('Colonia', _valor('ubicacion:colonia').ifEmpty('Sin capturar')),
      MapEntry('Calle', _valor('ubicacion:calle').ifEmpty('Sin capturar')),
      MapEntry('Número', _valor('ubicacion:numero').ifEmpty('No especificado')),
      MapEntry(
        'Referencias',
        _valor('ubicacion:referencias').ifEmpty('No especificado'),
      ),
    ];
    final resumenTripulaciones = _unidadesDisponibles
        .where(_unidadesSeleccionadas.contains)
        .map((unidad) {
          final tripulacion = _tripulacionDe(unidad);
          return _TarjetaResumenPaso(
            titulo: 'Tripulación de $unidad',
            datos: [
              MapEntry(
                'Maquinista',
                tripulacion.maquinista.trim().ifEmpty('Sin capturar'),
              ),
              MapEntry(
                'Jefe de servicio',
                tripulacion.jefeServicio.trim().ifEmpty('Sin capturar'),
              ),
              if (tripulacion.personalApoyo.isEmpty)
                const MapEntry('Personal de apoyo', 'Ninguno agregado')
              else
                for (var i = 0; i < tripulacion.personalApoyo.length; i++)
                  MapEntry(
                    tripulacion.personalApoyo[i].rangoFuncion ?? 'Sin rango',
                    tripulacion.personalApoyo[i].nombreCompleto.trim().ifEmpty(
                      'Sin capturar',
                    ),
                  ),
            ],
          );
        })
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const EtiquetaRol.central(),
        const SizedBox(height: 18),
        _tituloSeccion(Icons.fact_check_outlined, 'Revisa la alerta'),
        _TarjetaResumenPaso(titulo: 'Categoría', datos: categoriaResumen),
        _TarjetaResumenPaso(
          titulo: 'Detalles de la emergencia',
          datos: detalles,
        ),
        _TarjetaResumenPaso(titulo: 'Reporte', datos: reporte),
        _TarjetaResumenPaso(titulo: 'Ubicación', datos: ubicacion),
        ...resumenTripulaciones,
        _TarjetaResumenPaso(
          titulo: 'Despacho',
          datos: [
            MapEntry(
              'Unidades',
              _unidadesSeleccionadas.isEmpty
                  ? 'Ninguna seleccionada'
                  : _unidadesDisponibles
                        .where(_unidadesSeleccionadas.contains)
                        .join(', '),
            ),
            MapEntry('Prioridad', _prioridadSeleccionada),
          ],
        ),
        const SizedBox(height: 12),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          value: _confirmacionMarcada,
          onChanged: (valor) {
            setState(() => _confirmacionMarcada = valor ?? false);
          },
          title: const Text(
            'Confirmo que revisé los datos del reporte.',
            style: TextStyle(color: ColoresApp.tinta, fontSize: 14),
          ),
        ),
        if (_mostrarErrores && !_confirmacionMarcada)
          _errorSeleccion('Marca la confirmación para continuar.'),
        const SizedBox(height: 8),
        const CajaInfo(
          'Al confirmar se abrirá la bitácora. Esta pantalla no transmite la alerta a las unidades.',
          fondo: ColoresApp.azulClaro,
          colorTexto: ColoresApp.azulMarino,
        ),
      ],
    );
  }

  Widget _construirTarjetasCategoria() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columnas = constraints.maxWidth >= 580 ? 3 : 2;
        const separacion = 12.0;
        final ancho =
            (constraints.maxWidth - (separacion * (columnas - 1))) / columnas;
        return Wrap(
          spacing: separacion,
          runSpacing: separacion,
          children: ConfiguracionCamposAlerta.porCategoria.keys.map((
            categoria,
          ) {
            return SizedBox(
              width: ancho,
              child: _TarjetaCategoria(
                titulo: categoria,
                icono: _iconosCategoria[categoria]!,
                seleccionada: _categoriaSeleccionada == categoria,
                alTocar: () => _seleccionarCategoria(categoria),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _construirDropdownSubcategoria() {
    final subcategorias =
        ConfiguracionCamposAlerta.porCategoria[_categoriaSeleccionada]?.keys
            .toList() ??
        const <String>[];
    return _DropdownSire<String>(
      valor: _subcategoriaSeleccionada,
      sugerencia: _categoriaSeleccionada == null
          ? 'Selecciona una categoría primero'
          : 'Selecciona una subcategoría',
      opciones: subcategorias.map((valor) => MapEntry(valor, valor)).toList(),
      habilitado: _categoriaSeleccionada != null,
      alCambiar: _seleccionarSubcategoria,
    );
  }

  Widget _construirDropdownSolicitante() {
    final seleccionado = _tipoSolicitante == 'Reporte directo'
        ? 'Persona (Civil)'
        : _tipoSolicitante;
    return _DropdownSire<String>(
      valor: seleccionado,
      sugerencia: 'Selecciona quién reporta',
      opciones: _etiquetasTipoSolicitante.entries
          .map((entrada) => MapEntry(entrada.key, entrada.value))
          .toList(),
      alCambiar: (valor) => setState(() => _tipoSolicitante = valor),
    );
  }

  Widget _campoTexto({
    required String id,
    required String etiqueta,
    required String sugerencia,
    bool requerido = false,
    bool multilinea = false,
    TextInputType teclado = TextInputType.text,
    String? sufijo,
    List<TextInputFormatter>? formateadores,
    FormFieldValidator<String>? validator,
  }) {
    return _campoConEtiqueta(
      etiqueta,
      CampoTextoSire(
        key: ValueKey(id),
        controller: _controlador(id),
        hintText: sugerencia,
        validator: validator,
        keyboardType: teclado,
        maxLines: multilinea ? 3 : 1,
        etiqueta: sufijo,
        inputFormatters: formateadores,
      ),
      requerido: requerido,
    );
  }

  InputDecoration _decoracionCampo() {
    return InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: ColoresApp.linea, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: ColoresApp.azulMarino, width: 2),
      ),
    );
  }

  Widget _tituloSeccion(IconData icono, String titulo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: ColoresApp.azulClaro,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icono, size: 19, color: ColoresApp.azulMarino),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              titulo,
              style: const TextStyle(
                color: ColoresApp.azulMarino,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _campoConEtiqueta(
    String etiqueta,
    Widget campo, {
    bool requerido = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _etiquetaCampo(etiqueta, requerido: requerido),
          const SizedBox(height: 7),
          campo,
        ],
      ),
    );
  }

  Widget _etiquetaCampo(String etiqueta, {required bool requerido}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            etiqueta,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: ColoresApp.atenuado,
            ),
          ),
        ),
        if (requerido)
          const Text(
            'Obligatorio',
            style: TextStyle(
              color: ColoresApp.rojo,
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }

  Widget _errorSeleccion(String texto) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 12),
      child: Text(
        texto,
        style: const TextStyle(color: ColoresApp.rojo, fontSize: 12),
      ),
    );
  }

  Widget _aviso(String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: CajaInfo(
        texto,
        fondo: ColoresApp.ambarClaro,
        colorTexto: ColoresApp.ambarOscuro,
      ),
    );
  }
}
