/// Acciones relevantes que se registran para auditoría.
enum AccionBitacora {
  inicioSesion('Inicio de sesión'),
  intentoFallido('Intento de acceso fallido'),
  bloqueoTemporal('Bloqueo temporal de acceso'),
  cierreSesion('Cierre de sesión'),
  cambioPin('Cambio de PIN'),
  altaServicio('Alta de servicio'),
  tiempoRegistrado('Tiempo registrado'),
  reporteEnviado('Reporte enviado a Central');

  const AccionBitacora(this.etiqueta);

  final String etiqueta;
}

/// Registro inmutable de una acción: quién, qué y cuándo.
class EntradaBitacora {
  const EntradaBitacora({
    required this.momento,
    required this.usuario,
    required this.accion,
    this.detalle = '',
    this.servicioId,
  });

  final DateTime momento;
  final String usuario;
  final AccionBitacora accion;
  final String detalle;

  /// Servicio al que pertenece la acción, si aplica.
  final String? servicioId;
}
