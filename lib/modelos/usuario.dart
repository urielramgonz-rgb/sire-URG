/// Rol de acceso. El modelo actual no define un rol de administración.
enum RolUsuario {
  central('Central'),
  campo('Campo');

  const RolUsuario(this.etiqueta);

  final String etiqueta;
}

/// Cuenta de acceso a la aplicación.
class Usuario {
  const Usuario({
    required this.id,
    required this.nif,
    required this.nombre,
    required this.rol,
    this.unidad,
    this.activo = true,
  });

  /// Identificador de empleado.
  final String id;
  final String nif;
  final String nombre;
  final RolUsuario rol;

  /// Unidad asignada (solo personal de Campo).
  final String? unidad;
  final bool activo;

  static String normalizar(String texto) => texto.trim().toLowerCase();

  /// Acepta identificador de empleado, NIF o nombre completo.
  bool coincideCon(String entrada) {
    final buscado = normalizar(entrada);
    if (buscado.isEmpty) return false;
    return normalizar(id) == buscado ||
        normalizar(nif) == buscado ||
        normalizar(nombre) == buscado;
  }

  /// Indica si el usuario puede recibir y atender servicios.
  bool canTakeService() => activo && rol == RolUsuario.campo && unidad != null;

  /// Solo Central activa registra y asigna servicios nuevos.
  bool get puedeCrearServicios => activo && rol == RolUsuario.central;
}
