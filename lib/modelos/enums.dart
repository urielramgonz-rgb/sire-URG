// Catálogos cerrados del sistema. Sustituyen a los textos libres para que
// no existan valores inválidos ni duplicados con distinto formato.

/// Prioridad de un servicio. Es el único campo de prioridad del modelo.
enum PrioridadServicio {
  baja('Baja'),
  media('Media'),
  alta('Alta');

  const PrioridadServicio(this.etiqueta);

  final String etiqueta;

  @override
  String toString() => etiqueta;
}

/// Estatus (tiempos) que Campo marca durante un servicio, en orden
/// cronológico. Cada uno se registra una sola vez con la hora del dispositivo.
enum EstatusServicio {
  alertaEnviada('ALERTA_ENVIADA', 'Reporte enviado'),
  salidaBase('SALIDA_BASE', 'Salida de base'),
  llegadaLugar('LLEGADA_LUGAR', 'Llegada al lugar'),
  inicioAtencion('INICIO_ATENCION', 'Inicio de atención'),
  salidaLugar('SALIDA_LUGAR', 'Salida del lugar / traslado'),
  finServicio('FIN_SERVICIO', 'Fin del servicio');

  const EstatusServicio(this.codigo, this.etiqueta);

  /// Código estable para sincronización y reportes.
  final String codigo;
  final String etiqueta;

  @override
  String toString() => etiqueta;
}

/// Estado del servicio. No se captura a mano: se deriva del último estatus
/// registrado, de modo que estado y tiempos nunca se contradicen.
enum EstadoServicio {
  asignada('Asignada'),
  enCamino('En camino'),
  enEscena('En escena'),
  enAtencion('En atención'),
  enTraslado('En traslado'),
  finalizado('Finalizado');

  const EstadoServicio(this.etiqueta);

  final String etiqueta;

  static EstadoServicio desdeEstatus(EstatusServicio? ultimo) {
    return switch (ultimo) {
      null || EstatusServicio.alertaEnviada => EstadoServicio.asignada,
      EstatusServicio.salidaBase => EstadoServicio.enCamino,
      EstatusServicio.llegadaLugar => EstadoServicio.enEscena,
      EstatusServicio.inicioAtencion => EstadoServicio.enAtencion,
      EstatusServicio.salidaLugar => EstadoServicio.enTraslado,
      EstatusServicio.finServicio => EstadoServicio.finalizado,
    };
  }

  @override
  String toString() => etiqueta;
}
