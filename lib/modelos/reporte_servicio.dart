class ReporteServicio {
  const ReporteServicio({
    required this.id,
    required this.folio,
    required this.categoria,
    required this.subcategoria,
    required this.camposFormulario,
    required this.ubicacion,
    required this.detallesUbicacion,
    required this.solicitante,
    required this.datosSolicitante,
    required this.unidadesAsignadas,
    required this.prioridad,
    required this.personal,
    required this.apoyoExterno,
    required this.estado,
    required this.cronologia,
    this.eventosCampo = '',
    this.corporacionesApoyo = const [],
    this.estadoCorporacionesApoyo = 'No especificado',
    this.unidadesApoyo = const [],
    this.estadoUnidadesApoyo = 'Pendiente',
    this.estadoTripulacionApoyo = 'Pendiente',
    this.cierreServicio = '',
  });

  final String id;
  final String folio;
  final String categoria;
  final String subcategoria;
  final Map<String, String> camposFormulario;
  final String ubicacion;
  final Map<String, String> detallesUbicacion;
  final String solicitante;
  final Map<String, String> datosSolicitante;
  final List<String> unidadesAsignadas;
  final String prioridad;
  final List<PersonalReporte> personal;
  final String apoyoExterno;
  final String estado;
  final List<EventoCronologia> cronologia;
  final String eventosCampo;
  final List<String> corporacionesApoyo;
  final String estadoCorporacionesApoyo;
  final List<UnidadApoyoReporte> unidadesApoyo;
  final String estadoUnidadesApoyo;
  final String estadoTripulacionApoyo;
  final String cierreServicio;

  DatosServicioReporte get datosServicio => DatosServicioReporte(
    eventosCampo: eventosCampo,
    corporacionesApoyo: corporacionesApoyo,
    estadoCorporacionesApoyo: estadoCorporacionesApoyo,
    unidadesApoyo: unidadesApoyo,
    estadoUnidadesApoyo: estadoUnidadesApoyo,
    estadoTripulacionApoyo: estadoTripulacionApoyo,
    cierreServicio: cierreServicio,
  );

  ReporteServicio conDatosServicio(DatosServicioReporte datos) =>
      ReporteServicio(
        id: id,
        folio: folio,
        categoria: categoria,
        subcategoria: subcategoria,
        camposFormulario: camposFormulario,
        ubicacion: ubicacion,
        detallesUbicacion: detallesUbicacion,
        solicitante: solicitante,
        datosSolicitante: datosSolicitante,
        unidadesAsignadas: unidadesAsignadas,
        prioridad: prioridad,
        personal: personal,
        apoyoExterno: apoyoExterno,
        estado: estado,
        cronologia: cronologia,
        eventosCampo: datos.eventosCampo,
        corporacionesApoyo: datos.corporacionesApoyo,
        estadoCorporacionesApoyo: datos.estadoCorporacionesApoyo,
        unidadesApoyo: datos.unidadesApoyo,
        estadoUnidadesApoyo: datos.estadoUnidadesApoyo,
        estadoTripulacionApoyo: datos.estadoTripulacionApoyo,
        cierreServicio: datos.cierreServicio,
      );

  ReporteServicio actualizarDatosServicio({
    required String eventos,
    required List<String> corporaciones,
    required List<UnidadApoyoReporte> unidades,
    required String cierre,
  }) => conDatosServicio(
    DatosServicioReporte(
      eventosCampo: eventos,
      corporacionesApoyo: List.unmodifiable(corporaciones),
      estadoCorporacionesApoyo: corporaciones.isEmpty
          ? 'Sin corporaciones de apoyo registradas'
          : 'Confirmado',
      unidadesApoyo: List.unmodifiable(unidades),
      estadoUnidadesApoyo: unidades.isEmpty
          ? 'Sin unidades externas registradas'
          : 'Registradas',
      estadoTripulacionApoyo: 'No especificado',
      cierreServicio: cierre,
    ),
  );

  String get folioVisible => folio.trim().isEmpty ? 'Sin folio' : folio;
  String get unidadesTexto => unidadesAsignadas.join(', ');
  String get personalTexto =>
      personal.map((persona) => persona.nombre).join(', ');
}

class DatosServicioReporte {
  const DatosServicioReporte({
    required this.eventosCampo,
    required this.corporacionesApoyo,
    required this.estadoCorporacionesApoyo,
    required this.unidadesApoyo,
    required this.estadoUnidadesApoyo,
    required this.estadoTripulacionApoyo,
    required this.cierreServicio,
  });

  final String eventosCampo;
  final List<String> corporacionesApoyo;
  final String estadoCorporacionesApoyo;
  final List<UnidadApoyoReporte> unidadesApoyo;
  final String estadoUnidadesApoyo;
  final String estadoTripulacionApoyo;
  final String cierreServicio;
}

class UnidadApoyoReporte {
  const UnidadApoyoReporte({
    required this.corporacion,
    required this.identificador,
    required this.responsable,
    required this.tripulacion,
  });

  final String corporacion;
  final String identificador;
  final String responsable;
  final List<String> tripulacion;
}

class PersonalReporte {
  const PersonalReporte({
    required this.nombre,
    required this.funcion,
    required this.unidad,
  });

  final String nombre;
  final String funcion;
  final String unidad;
}

class EventoCronologia {
  const EventoCronologia({
    required this.titulo,
    required this.hora,
    required this.completado,
    required this.detalle,
  });

  final String titulo;
  final String hora;
  final bool completado;
  final String detalle;
}
