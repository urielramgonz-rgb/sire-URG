import 'package:flutter/foundation.dart';

import '../modelos/entrada_bitacora.dart';

/// Bitácora de acciones. Solo permite agregar: no se edita ni se borra.
class BitacoraRepositorio extends ChangeNotifier {
  BitacoraRepositorio._();

  /// Instancia aislada para pruebas (la app usa [instancia]).
  @visibleForTesting
  BitacoraRepositorio.paraPruebas();

  static final BitacoraRepositorio instancia = BitacoraRepositorio._();

  final List<EntradaBitacora> _entradas = [];

  List<EntradaBitacora> get entradas => List.unmodifiable(_entradas);

  List<EntradaBitacora> deServicio(String servicioId) => List.unmodifiable(
    _entradas.where((entrada) => entrada.servicioId == servicioId),
  );

  void registrar({
    required String usuario,
    required AccionBitacora accion,
    String detalle = '',
    String? servicioId,
    DateTime? momento,
  }) {
    _entradas.add(
      EntradaBitacora(
        momento: momento ?? DateTime.now(),
        usuario: usuario,
        accion: accion,
        detalle: detalle,
        servicioId: servicioId,
      ),
    );
    notifyListeners();
  }
}
