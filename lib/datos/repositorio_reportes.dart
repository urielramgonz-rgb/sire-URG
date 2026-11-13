import 'package:flutter/foundation.dart';

import '../modelos/entrada_bitacora.dart';
import '../modelos/enums.dart';
import '../modelos/reporte_servicio.dart';
import '../modelos/usuario.dart';
import 'repositorio_bitacora.dart';

class ReportesRepositorio extends ChangeNotifier {
  ReportesRepositorio._()
    : _reportes = _reportesIniciales(),
      _bitacora = BitacoraRepositorio.instancia;

  /// Instancia aislada para pruebas, con los reportes y la bitácora dados.
  @visibleForTesting
  ReportesRepositorio.paraPruebas({
    required List<ReporteServicio> reportes,
    required BitacoraRepositorio bitacora,
  }) : _reportes = List.of(reportes),
       _bitacora = bitacora;

  static final ReportesRepositorio instancia = ReportesRepositorio._();

  final List<ReporteServicio> _reportes;
  final BitacoraRepositorio _bitacora;
  final Map<String, DatosServicioReporte> _versionesPublicadas = {};
  int _siguienteId = 1;

  List<ReporteServicio> get reportes => List.unmodifiable(_reportes);

  List<ReporteServicio> get reportesParaCentral => List.unmodifiable(
    _reportes.map((reporte) {
      final publicada = _versionesPublicadas[reporte.id];
      return publicada == null ? reporte : reporte.conDatosServicio(publicada);
    }),
  );

  ReporteServicio? porId(String id) {
    for (final reporte in _reportes) {
      if (reporte.id == id) return reporte;
    }
    return null;
  }

  /// Versión que ve Central: incluye los datos publicados por Campo.
  ReporteServicio? porIdParaCentral(String id) {
    final reporte = porId(id);
    if (reporte == null) return null;
    final publicada = _versionesPublicadas[id];
    return publicada == null ? reporte : reporte.conDatosServicio(publicada);
  }

  List<ReporteServicio> asignadosA(String unidad) => List.unmodifiable(
    _reportes
        .where((reporte) => reporte.unidadesAsignadas.contains(unidad))
        .toList(),
  );

  String crearId() => 'nuevo-${_siguienteId++}';

  bool contieneFolio(String folio) {
    final normalizado = folio.trim().toLowerCase();
    if (normalizado.isEmpty) return false;
    return _reportes.any(
      (reporte) => reporte.folio.trim().toLowerCase() == normalizado,
    );
  }

  bool agregar(ReporteServicio reporte, {Usuario? creadoPor}) {
    if (contieneFolio(reporte.folio)) return false;
    _reportes.add(reporte);
    _bitacora.registrar(
      usuario: creadoPor?.nombre ?? 'Sistema',
      accion: AccionBitacora.altaServicio,
      detalle: '${reporte.folioVisible} · ${reporte.categoria}',
      servicioId: reporte.id,
    );
    notifyListeners();
    return true;
  }

  /// Registra un tiempo del servicio con la hora real del dispositivo.
  ///
  /// Reglas: solo personal de Campo activo con la unidad asignada; los
  /// tiempos se marcan en orden; cada uno se marca una sola vez; un servicio
  /// finalizado ya no se modifica. Devuelve null si se registró o el mensaje
  /// con el motivo del rechazo.
  String? marcarTiempo({
    required String id,
    required EstatusServicio estatus,
    required Usuario usuario,
    DateTime? momento,
  }) {
    final indice = _reportes.indexWhere((reporte) => reporte.id == id);
    if (indice < 0) return 'No se encontró el servicio.';
    final reporte = _reportes[indice];

    if (!usuario.canTakeService() ||
        !reporte.unidadesAsignadas.contains(usuario.unidad)) {
      return 'No tienes permiso para registrar tiempos de este servicio.';
    }
    if (reporte.cerrado) {
      return 'El servicio ya está finalizado. Los tiempos son de solo consulta.';
    }
    final siguiente = reporte.siguientePendiente;
    if (siguiente == null || siguiente.estatus != estatus) {
      return 'Registra los tiempos en orden. '
          'Sigue: ${siguiente?.titulo ?? 'ninguno'}.';
    }

    final ahora = momento ?? DateTime.now();
    final previa = reporte.ultimaMarca;
    if (previa != null && ahora.isBefore(previa)) {
      return 'La hora del dispositivo es anterior al último tiempo '
          'registrado (${formatearHora(previa)}). Revisa la hora del teléfono.';
    }

    final nueva = [
      for (final evento in reporte.cronologia)
        if (evento.estatus == estatus)
          evento.marcar(ahora, 'Unidad ${usuario.unidad}')
        else
          evento,
    ];
    _reportes[indice] = reporte.conCronologia(nueva);

    _bitacora.registrar(
      usuario: usuario.nombre,
      accion: AccionBitacora.tiempoRegistrado,
      detalle: '${estatus.etiqueta} · ${formatearHora(ahora)}',
      servicioId: reporte.id,
      momento: ahora,
    );
    notifyListeners();
    return null;
  }

  void actualizarDatosServicio({
    required String id,
    required String eventos,
    required List<String> corporaciones,
    required List<UnidadApoyoReporte> unidades,
    required String cierre,
  }) {
    final indice = _reportes.indexWhere((reporte) => reporte.id == id);
    if (indice < 0) return;

    _reportes[indice] = _reportes[indice].actualizarDatosServicio(
      eventos: eventos,
      corporaciones: corporaciones,
      unidades: unidades,
      cierre: cierre,
    );
    notifyListeners();
  }

  bool publicarDatosServicio(String id, {Usuario? usuario}) {
    final reporte = porId(id);
    if (reporte == null) return false;
    _versionesPublicadas[id] = reporte.datosServicio;
    _bitacora.registrar(
      usuario: usuario?.nombre ?? 'Campo',
      accion: AccionBitacora.reporteEnviado,
      detalle: reporte.folioVisible,
      servicioId: id,
    );
    notifyListeners();
    return true;
  }

  /// Arma una línea de tiempo de ejemplo. [haceMinutos] indica hace cuántos
  /// minutos se registró cada estatus; los que faltan quedan pendientes.
  static List<EventoCronologia> _linea(
    String unidad,
    Map<EstatusServicio, int> haceMinutos,
  ) {
    final ahora = DateTime.now();
    final eventos = <EventoCronologia>[];
    for (final estatus in EstatusServicio.values) {
      final minutos = haceMinutos[estatus];
      if (minutos == null) {
        eventos.add(EventoCronologia(estatus: estatus));
      } else {
        eventos.add(
          EventoCronologia(
            estatus: estatus,
            marcadoEn: ahora.subtract(Duration(minutes: minutos)),
            detalle: estatus == EstatusServicio.alertaEnviada
                ? 'Central'
                : 'Unidad $unidad',
          ),
        );
      }
    }
    return List.unmodifiable(eventos);
  }

  static List<ReporteServicio> _reportesIniciales() => [
    ReporteServicio(
      id: 'demo-0154',
      folio: '0154',
      categoria: 'ACCIDENTES',
      subcategoria: 'Choque',
      camposFormulario: const {
        'tipo': 'Por alcance',
        'vehiculos_involucrados': 'Automóvil, Camioneta',
        'vehiculos': '2 vehículos',
        'lesionadas': '2 personas',
        'atrapadas': 'No',
        'derrame': 'No',
        'bloqueo': 'Sí',
      },
      ubicacion: 'Carretera SMA–Dolores, km 12',
      detallesUbicacion: const {
        'Colonia': 'Zona rural de San Miguel de Allende',
        'Calle': 'Carretera SMA–Dolores',
        'Número': 'km 12',
        'Referencias': 'Tramo carretero a la altura del km 12',
      },
      solicitante: 'C4 (Central)',
      datosSolicitante: const {
        'Nombre del reportante': 'Central SMA',
        'Teléfono del reportante': 'No especificado',
      },
      unidadesAsignadas: const ['BYP01'],
      eventosCampo: 'BYP01 arribó al kilómetro 12 de la carretera SMA–Dolores. Se identificaron dos vehículos involucrados, un automóvil y una camioneta, con dos personas lesionadas. Se realizó una valoración inicial y se delimitó la zona de trabajo. No se reportaron personas prensadas ni derrame de combustible. El servicio continúa en atención.',
      corporacionesApoyo: const ['Cruz Roja'],
      estadoUnidadesApoyo: 'Confirmado',
      estadoTripulacionApoyo: 'Confirmada',
      unidadesApoyo: const [
        UnidadApoyoReporte(
          corporacion: 'Cruz Roja',
          identificador: 'CR-12',
          responsable: 'Andrea Morales',
          tripulacion: ['Diego Ruiz', 'Paula Hernández'],
        ),
      ],
      cierreServicio: 'Pendiente. La atención continúa y aún no se ha registrado el resultado final.',
      prioridad: PrioridadServicio.alta,
      personal: const [
        PersonalReporte(
          nombre: 'Andres Romo',
          funcion: 'Maquinista',
          unidad: 'BYP01',
        ),
        PersonalReporte(
          nombre: 'Juan González',
          funcion: 'Jefe de servicio',
          unidad: 'BYP01',
        ),
      ],
      apoyoExterno: 'Cruz Roja',
      cronologia: _linea('BYP01', const {
        EstatusServicio.alertaEnviada: 60,
        EstatusServicio.salidaBase: 58,
        EstatusServicio.llegadaLugar: 45,
        EstatusServicio.inicioAtencion: 42,
      }),
    ),
    ReporteServicio(
      id: 'demo-0155',
      folio: '0155',
      categoria: 'INCENDIO',
      subcategoria: 'Pastizal',
      camposFormulario: const {
        'terreno': 'Pastizal',
        'superficie': '2.5 hectáreas',
        'direccion': 'Hacia el noreste',
        'amenaza': 'No',
        'personas_animales': 'No',
        'viento': 'Sí',
      },
      ubicacion: 'Camino de terracería, S/N, Zona rural',
      detallesUbicacion: const {
        'Colonia': 'Zona rural',
        'Calle': 'Camino de terracería',
        'Número': 'S/N',
        'Referencias': 'Pastizal junto al camino rural',
      },
      solicitante: 'C4 (Central)',
      datosSolicitante: const {
        'Nombre del reportante': 'Central SMA',
        'Teléfono del reportante': 'No especificado',
      },
      unidadesAsignadas: const ['BYP02'],
      eventosCampo: 'Unidad en camino al reporte de incendio de pastizal. Pendiente de llegada al lugar y de evaluación por el personal de Campo.',
      estadoCorporacionesApoyo:
          'No hay corporaciones externas con participación confirmada.',
      estadoUnidadesApoyo: 'Pendiente de información de Campo.',
      estadoTripulacionApoyo: 'Pendiente de información de Campo.',
      cierreServicio: 'Pendiente',
      prioridad: PrioridadServicio.media,
      personal: const [
        PersonalReporte(
          nombre: 'Andres Romo',
          funcion: 'Maquinista',
          unidad: 'BYP02',
        ),
        PersonalReporte(
          nombre: 'Juan González',
          funcion: 'Jefe de servicio',
          unidad: 'BYP02',
        ),
      ],
      apoyoExterno: 'No especificado',
      cronologia: _linea('BYP02', const {
        EstatusServicio.alertaEnviada: 12,
        EstatusServicio.salidaBase: 9,
      }),
    ),
    ReporteServicio(
      id: 'demo-0156',
      folio: '0156',
      categoria: 'RESCATE',
      subcategoria: 'Montaña',
      camposFormulario: const {
        'incidente': 'Persona extraviada',
        'personas': '1 persona',
        'ubicacion': 'Sendero del mirador, punto de referencia km 3',
        'ultimo_contacto': 'Hace aproximadamente 30 minutos',
        'condicion': 'Desconocida',
        'acceso': 'Difícil',
        'riesgos': 'Sí',
      },
      ubicacion: 'Camino al mirador, S/N, Zona serrana',
      detallesUbicacion: const {
        'Colonia': 'Zona serrana',
        'Calle': 'Camino al mirador',
        'Número': 'S/N',
        'Referencias': 'Acceso principal al sendero',
      },
      solicitante: 'C4 (Central)',
      datosSolicitante: const {
        'Nombre del reportante': 'Central SMA',
        'Teléfono del reportante': 'No especificado',
      },
      unidadesAsignadas: const ['BYP04'],
      eventosCampo: 'Pendiente de respuesta de la unidad. El personal de Campo aún no ha reportado acciones en el lugar.',
      estadoCorporacionesApoyo: 'No hay corporaciones externas confirmadas.',
      estadoUnidadesApoyo: 'No hay unidades externas confirmadas.',
      estadoTripulacionApoyo: 'No hay tripulantes externos confirmados.',
      cierreServicio: 'Pendiente',
      prioridad: PrioridadServicio.alta,
      personal: const [
        PersonalReporte(
          nombre: 'Andres Romo',
          funcion: 'Maquinista',
          unidad: 'BYP04',
        ),
        PersonalReporte(
          nombre: 'Juan González',
          funcion: 'Jefe de servicio',
          unidad: 'BYP04',
        ),
      ],
      apoyoExterno: 'No especificado',
      cronologia: _linea('BYP04', const {EstatusServicio.alertaEnviada: 7}),
    ),
    ReporteServicio(
      id: 'demo-0157',
      folio: '0157',
      categoria: 'MAT. PELIGROSO',
      subcategoria: 'Derrame',
      camposFormulario: const {
        'sustancia': 'Diésel',
        'onu': 'No especificado',
        'estado': 'Líquido',
        'cantidad': '80',
        'unidad_cantidad': 'Litros',
        'origen': 'Vehículo',
        'expuestas': 'No',
        'cantidad_expuestas': 'No especificado',
        'fuego': 'No',
        'explosion': 'No',
        'drenajes_agua': 'No',
        'superficie': 'Aproximadamente 4 m²',
        'tipo_superficie': 'Pavimento',
        'extension': 'No',
        'contacto': 'No',
      },
      ubicacion: 'Carretera a Dolores, km 8, Zona rural',
      detallesUbicacion: const {
        'Colonia': 'Zona rural',
        'Calle': 'Carretera a Dolores',
        'Número': 'km 8',
        'Referencias': 'Derrame junto a un vehículo detenido',
      },
      solicitante: 'C4 (Central)',
      datosSolicitante: const {
        'Nombre del reportante': 'Central SMA',
        'Teléfono del reportante': 'No especificado',
      },
      unidadesAsignadas: const ['BYP05'],
      eventosCampo: 'BYP05 arribó al lugar. Se encuentra en reconocimiento inicial del área reportada por derrame de diésel. El inicio de atención y el resultado del servicio aún no han sido registrados.',
      estadoCorporacionesApoyo: 'No hay corporaciones externas confirmadas.',
      estadoUnidadesApoyo: 'No hay unidades externas confirmadas.',
      estadoTripulacionApoyo: 'No hay tripulantes externos confirmados.',
      cierreServicio: 'Pendiente',
      prioridad: PrioridadServicio.alta,
      personal: const [
        PersonalReporte(
          nombre: 'Andres Romo',
          funcion: 'Maquinista',
          unidad: 'BYP05',
        ),
        PersonalReporte(
          nombre: 'Juan González',
          funcion: 'Jefe de servicio',
          unidad: 'BYP05',
        ),
      ],
      apoyoExterno: 'No especificado',
      cronologia: _linea('BYP05', const {
        EstatusServicio.alertaEnviada: 20,
        EstatusServicio.salidaBase: 16,
        EstatusServicio.llegadaLugar: 5,
      }),
    ),
  ];
}
