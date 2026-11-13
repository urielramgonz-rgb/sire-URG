import 'package:flutter/foundation.dart';

import '../modelos/entrada_bitacora.dart';
import '../modelos/usuario.dart';
import 'repositorio_bitacora.dart';

/// Resultado de verificar credenciales.
class ResultadoAcceso {
  const ResultadoAcceso._(this.usuario, this.mensaje);

  const ResultadoAcceso.correcto(Usuario usuario) : this._(usuario, null);

  const ResultadoAcceso.fallido(String mensaje) : this._(null, mensaje);

  final Usuario? usuario;
  final String? mensaje;

  bool get exitoso => usuario != null;
}

/// Control de acceso local: usuarios activos, límite de intentos, bloqueo
/// temporal, sesión actual y bitácora de accesos.
///
/// IMPORTANTE (demostración): los PIN se guardan en memoria y en texto
/// legible dentro de este archivo. Antes de producción deben almacenarse como
/// hash (con sal) y validarse contra un servidor. Esta clase concentra toda la
/// lógica de credenciales para que ese cambio se haga en un solo lugar.
class Autenticacion extends ChangeNotifier {
  Autenticacion._()
    : _bitacora = BitacoraRepositorio.instancia,
      _ahora = DateTime.now;

  /// Instancia aislada para pruebas, con bitácora y reloj controlables.
  @visibleForTesting
  Autenticacion.paraPruebas({
    required BitacoraRepositorio bitacora,
    DateTime Function()? reloj,
  }) : _bitacora = bitacora,
       _ahora = reloj ?? DateTime.now;

  static final Autenticacion instancia = Autenticacion._();

  static const int maxIntentos = 3;
  static const Duration duracionBloqueo = Duration(seconds: 30);
  static const int longitudMinimaPin = 4;
  static const int longitudMaximaPin = 8;

  final BitacoraRepositorio _bitacora;
  final DateTime Function() _ahora;

  final List<Usuario> _usuarios = const [
    Usuario(
      id: 'EMP-001',
      nif: 'DEMO-NIF-001',
      nombre: 'Uriel Ramírez',
      rol: RolUsuario.central,
    ),
    Usuario(
      id: 'EMP-002',
      nif: 'DEMO-NIF-002',
      nombre: 'Juan González',
      rol: RolUsuario.campo,
      unidad: 'BYP01',
    ),
    Usuario(
      id: 'EMP-003',
      nif: 'DEMO-NIF-003',
      nombre: 'Andres Romo',
      rol: RolUsuario.campo,
      unidad: 'BYP02',
    ),
    Usuario(
      id: 'EMP-005',
      nif: 'DEMO-NIF-005',
      nombre: 'Rosa Vega',
      rol: RolUsuario.campo,
      unidad: 'BYP04',
    ),
    Usuario(
      id: 'EMP-004',
      nif: 'DEMO-NIF-004',
      nombre: 'Carlos Méndez',
      rol: RolUsuario.campo,
      unidad: 'BYP03',
      activo: false,
    ),
  ];

  final Map<String, String> _pins = {
    'EMP-001': '1234',
    'EMP-002': '5678',
    'EMP-003': '4321',
    'EMP-004': '0000',
    'EMP-005': '2468',
  };

  final Map<String, int> _fallos = {};
  final Map<String, DateTime> _bloqueos = {};
  Usuario? _usuarioActual;

  Usuario? get usuarioActual => _usuarioActual;

  Usuario? _buscar(String entrada) {
    for (final usuario in _usuarios) {
      if (usuario.coincideCon(entrada)) return usuario;
    }
    return null;
  }

  /// Verifica identificador y PIN aplicando límite de intentos, sin abrir
  /// sesión. También se usa para confirmar la identidad antes de cambiar PIN.
  ResultadoAcceso verificar(String entrada, String pin) {
    final identificador = entrada.trim();
    final pinLimpio = pin.trim();
    if (identificador.isEmpty || pinLimpio.isEmpty) {
      return const ResultadoAcceso.fallido(
        'Ingresa tu identificador y tu PIN.',
      );
    }

    final usuario = _buscar(identificador);
    final clave =
        usuario?.id ?? 'desconocido:${Usuario.normalizar(identificador)}';

    final restante = _segundosDeBloqueo(clave);
    if (restante > 0) {
      return ResultadoAcceso.fallido(
        'Demasiados intentos fallidos. Intenta de nuevo en $restante s.',
      );
    }

    if (usuario == null || _pins[usuario.id] != pinLimpio) {
      return _registrarFallo(clave, usuario, identificador);
    }

    if (!usuario.activo) {
      _bitacora.registrar(
        usuario: usuario.nombre,
        accion: AccionBitacora.intentoFallido,
        detalle: 'Cuenta desactivada',
      );
      return const ResultadoAcceso.fallido(
        'Tu cuenta está desactivada. Contacta a administración.',
      );
    }

    _fallos.remove(clave);
    _bloqueos.remove(clave);
    return ResultadoAcceso.correcto(usuario);
  }

  ResultadoAcceso iniciarSesion(String entrada, String pin) {
    final resultado = verificar(entrada, pin);
    final usuario = resultado.usuario;
    if (usuario != null) {
      _usuarioActual = usuario;
      _bitacora.registrar(
        usuario: usuario.nombre,
        accion: AccionBitacora.inicioSesion,
        detalle: 'Rol ${usuario.rol.etiqueta}',
      );
      notifyListeners();
    }
    return resultado;
  }

  void cerrarSesion() {
    final usuario = _usuarioActual;
    if (usuario == null) return;
    _bitacora.registrar(
      usuario: usuario.nombre,
      accion: AccionBitacora.cierreSesion,
    );
    _usuarioActual = null;
    notifyListeners();
  }

  /// Devuelve null si el cambio se guardó o el mensaje del problema.
  String? cambiarPin(Usuario usuario, String pinNuevo) {
    final nuevo = pinNuevo.trim();
    if (nuevo.length < longitudMinimaPin || nuevo.length > longitudMaximaPin) {
      return 'El PIN debe tener entre $longitudMinimaPin y '
          '$longitudMaximaPin dígitos.';
    }
    if (!RegExp(r'^\d+$').hasMatch(nuevo)) {
      return 'El PIN solo puede contener números.';
    }
    if (_pins[usuario.id] == nuevo) {
      return 'El nuevo PIN debe ser distinto al actual.';
    }
    _pins[usuario.id] = nuevo;
    _bitacora.registrar(
      usuario: usuario.nombre,
      accion: AccionBitacora.cambioPin,
    );
    return null;
  }

  int _segundosDeBloqueo(String clave) {
    final hasta = _bloqueos[clave];
    if (hasta == null) return 0;
    final restante = hasta.difference(_ahora());
    if (restante.inMilliseconds <= 0) {
      _bloqueos.remove(clave);
      _fallos.remove(clave);
      return 0;
    }
    return (restante.inMilliseconds / 1000).ceil();
  }

  ResultadoAcceso _registrarFallo(
    String clave,
    Usuario? usuario,
    String entrada,
  ) {
    final fallos = (_fallos[clave] ?? 0) + 1;
    _fallos[clave] = fallos;
    final quien = usuario?.nombre ?? entrada;
    _bitacora.registrar(
      usuario: quien,
      accion: AccionBitacora.intentoFallido,
      detalle: 'Intento $fallos de $maxIntentos',
    );

    if (fallos >= maxIntentos) {
      _bloqueos[clave] = _ahora().add(duracionBloqueo);
      _bitacora.registrar(
        usuario: quien,
        accion: AccionBitacora.bloqueoTemporal,
        detalle: '${duracionBloqueo.inSeconds} s',
      );
      return ResultadoAcceso.fallido(
        'Demasiados intentos fallidos. Acceso bloqueado '
        '${duracionBloqueo.inSeconds} s.',
      );
    }

    final restantes = maxIntentos - fallos;
    return ResultadoAcceso.fallido(
      'Identificador o PIN incorrecto. '
      'Te quedan $restantes intento${restantes == 1 ? '' : 's'}.',
    );
  }
}
