import 'package:flutter/foundation.dart';

import '../modelos/reporte_servicio.dart';

class ReportesRepositorio extends ChangeNotifier {
  ReportesRepositorio._() : _reportes = _reportesIniciales();

  static final ReportesRepositorio instancia = ReportesRepositorio._();

  final List<ReporteServicio> _reportes;
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

  bool agregar(ReporteServicio reporte) {
    if (contieneFolio(reporte.folio)) return false;
    _reportes.add(reporte);
    notifyListeners();
    return true;
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

  bool publicarDatosServicio(String id) {
    final reporte = porId(id);
    if (reporte == null) return false;
    _versionesPublicadas[id] = reporte.datosServicio;
    notifyListeners();
    return true;
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
      eventosCampo: 'A las 14:47, BYP01 arribó al kilómetro 12 de la carretera SMA–Dolores. Se identificaron dos vehículos involucrados, un automóvil y una camioneta, con dos personas lesionadas. Se realizó una valoración inicial y se delimitó la zona de trabajo. No se reportaron personas prensadas ni derrame de combustible. El servicio continúa en atención.',
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
      prioridad: 'Alta',
      personal: const [
        PersonalReporte(
          nombre: 'Juan González',
          funcion: 'Maquinista',
          unidad: 'BYP01',
        ),
        PersonalReporte(
          nombre: 'Cap. Hernández',
          funcion: 'Jefe de servicio',
          unidad: 'BYP01',
        ),
      ],
      apoyoExterno: 'Cruz Roja',
      estado: 'En atención',
      cronologia: [
        EventoCronologia(
          titulo: 'Reporte enviado',
          hora: '14:32',
          completado: true,
          detalle: 'Central',
        ),
        EventoCronologia(
          titulo: 'Salida de base',
          hora: '14:34',
          completado: true,
          detalle: 'Unidad BYP01',
        ),
        EventoCronologia(
          titulo: 'Llegada al lugar',
          hora: '14:47',
          completado: true,
          detalle: 'Unidad BYP01',
        ),
        EventoCronologia(
          titulo: 'Inicio de atención',
          hora: '14:50',
          completado: true,
          detalle: 'Unidad BYP01',
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
      prioridad: 'Media',
      personal: const [
        PersonalReporte(
          nombre: 'Bom. Luis Ramírez',
          funcion: 'Maquinista',
          unidad: 'BYP02',
        ),
        PersonalReporte(
          nombre: 'Cap. Carlos Méndez',
          funcion: 'Jefe de servicio',
          unidad: 'BYP02',
        ),
      ],
      apoyoExterno: 'No especificado',
      estado: 'En camino',
      cronologia: [
        EventoCronologia(
          titulo: 'Reporte enviado',
          hora: '15:05',
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
      prioridad: 'Alta',
      personal: const [
        PersonalReporte(
          nombre: 'Bom. Miguel Torres',
          funcion: 'Maquinista',
          unidad: 'BYP04',
        ),
        PersonalReporte(
          nombre: 'Cap. Laura Sánchez',
          funcion: 'Jefe de servicio',
          unidad: 'BYP04',
        ),
      ],
      apoyoExterno: 'No especificado',
      estado: 'Asignada',
      cronologia: [
        EventoCronologia(
          titulo: 'Reporte enviado',
          hora: '15:10',
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
      eventosCampo: 'BYP05 arribó al lugar a las 15:32. Se encuentra en reconocimiento inicial del área reportada por derrame de diésel. El inicio de atención y el resultado del servicio aún no han sido registrados.',
      estadoCorporacionesApoyo: 'No hay corporaciones externas confirmadas.',
      estadoUnidadesApoyo: 'No hay unidades externas confirmadas.',
      estadoTripulacionApoyo: 'No hay tripulantes externos confirmados.',
      cierreServicio: 'Pendiente',
      prioridad: 'Alta',
      personal: const [
        PersonalReporte(
          nombre: 'Bom. Arturo Pérez',
          funcion: 'Maquinista',
          unidad: 'BYP05',
        ),
        PersonalReporte(
          nombre: 'Cap. Ricardo Flores',
          funcion: 'Jefe de servicio',
          unidad: 'BYP05',
        ),
      ],
      apoyoExterno: 'No especificado',
      estado: 'En escena',
      cronologia: [
        EventoCronologia(
          titulo: 'Reporte enviado',
          hora: '15:15',
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
          hora: '15:32',
          completado: true,
          detalle: 'Unidad BYP05',
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
    ),
  ];
}
