import 'enums.dart';

/// Formato HH:mm usado en cronologías y reportes.
String formatearHora(DateTime momento) {
  final hora = momento.hour.toString().padLeft(2, '0');
  final minuto = momento.minute.toString().padLeft(2, '0');
  return '$hora:$minuto';
}

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
  final PrioridadServicio prioridad;
  final List<PersonalReporte> personal;
  final String apoyoExterno;
  final List<EventoCronologia> cronologia;
  final String eventosCampo;
  final List<String> corporacionesApoyo;
  final String estadoCorporacionesApoyo;
  final List<UnidadApoyoReporte> unidadesApoyo;
  final String estadoUnidadesApoyo;
  final String estadoTripulacionApoyo;
  final String cierreServicio;

  /// Estado derivado del último tiempo registrado.
  EstadoServicio get estado {
    EstatusServicio? ultimo;
    for (final evento in cronologia) {
      if (evento.completado) ultimo = evento.estatus;
    }
    return EstadoServicio.desdeEstatus(ultimo);
  }

  /// Un servicio finalizado es de solo consulta.
  bool get cerrado => estado == EstadoServicio.finalizado;

  /// Primer tiempo que aún no se registra (null si ya están todos).
  EventoCronologia? get siguientePendiente {
    for (final evento in cronologia) {
      if (!evento.completado) return evento;
    }
    return null;
  }

  /// Hora del último tiempo registrado.
  DateTime? get ultimaMarca {
    DateTime? ultima;
    for (final evento in cronologia) {
      final marca = evento.marcadoEn;
      if (marca != null && (ultima == null || marca.isAfter(ultima))) {
        ultima = marca;
      }
    }
    return ultima;
  }

  DatosServicioReporte get datosServicio => DatosServicioReporte(
    eventosCampo: eventosCampo,
    corporacionesApoyo: corporacionesApoyo,
    estadoCorporacionesApoyo: estadoCorporacionesApoyo,
    unidadesApoyo: unidadesApoyo,
    estadoUnidadesApoyo: estadoUnidadesApoyo,
    estadoTripulacionApoyo: estadoTripulacionApoyo,
    cierreServicio: cierreServicio,
  );

  ReporteServicio _copiar({
    List<EventoCronologia>? nuevaCronologia,
    DatosServicioReporte? datos,
  }) {
    final d = datos ?? datosServicio;
    return ReporteServicio(
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
      cronologia: nuevaCronologia ?? cronologia,
      eventosCampo: d.eventosCampo,
      corporacionesApoyo: d.corporacionesApoyo,
      estadoCorporacionesApoyo: d.estadoCorporacionesApoyo,
      unidadesApoyo: d.unidadesApoyo,
      estadoUnidadesApoyo: d.estadoUnidadesApoyo,
      estadoTripulacionApoyo: d.estadoTripulacionApoyo,
      cierreServicio: d.cierreServicio,
    );
  }

  ReporteServicio conDatosServicio(DatosServicioReporte datos) =>
      _copiar(datos: datos);

  ReporteServicio conCronologia(List<EventoCronologia> nueva) =>
      _copiar(nuevaCronologia: List.unmodifiable(nueva));

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

/// Un tiempo de la línea de tiempo del servicio. Se registra una sola vez
/// con la hora real del dispositivo; después es inmutable.
class EventoCronologia {
  const EventoCronologia({
    required this.estatus,
    this.marcadoEn,
    this.detalle = '',
  });

  /// Línea de tiempo nueva: solo el envío del reporte queda registrado.
  static List<EventoCronologia> lineaInicial(
    DateTime enviadoEn, {
    String detalle = 'Central',
  }) {
    final eventos = <EventoCronologia>[];
    for (final estatus in EstatusServicio.values) {
      if (estatus == EstatusServicio.alertaEnviada) {
        eventos.add(
          EventoCronologia(
            estatus: estatus,
            marcadoEn: enviadoEn,
            detalle: detalle,
          ),
        );
      } else {
        eventos.add(EventoCronologia(estatus: estatus));
      }
    }
    return List.unmodifiable(eventos);
  }

  final EstatusServicio estatus;
  final DateTime? marcadoEn;
  final String detalle;

  String get titulo => estatus.etiqueta;
  bool get completado => marcadoEn != null;
  String get hora => marcadoEn == null ? '--:--' : formatearHora(marcadoEn!);

  EventoCronologia marcar(DateTime momento, String detalle) =>
      EventoCronologia(estatus: estatus, marcadoEn: momento, detalle: detalle);
}
