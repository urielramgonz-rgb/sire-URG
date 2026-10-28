/// Datos de la tripulación asignada a una unidad dentro del formulario local.
class TripulacionUnidad {
  String maquinista = '';
  String jefeServicio = '';
  final List<IntegranteApoyo> personalApoyo = [];

  bool get tieneDatos =>
      maquinista.trim().isNotEmpty ||
      jefeServicio.trim().isNotEmpty ||
      personalApoyo.isNotEmpty;

  bool get completa =>
      maquinista.trim().isNotEmpty &&
      jefeServicio.trim().isNotEmpty &&
      personalApoyo.every((integrante) => integrante.completo);
}

/// Registro independiente para cada integrante de apoyo.
class IntegranteApoyo {
  String nombreCompleto = '';
  String? rangoFuncion;

  bool get completo =>
      nombreCompleto.trim().isNotEmpty && rangoFuncion != null;
}
