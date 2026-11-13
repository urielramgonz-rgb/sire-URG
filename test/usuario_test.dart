import 'package:flutter_test/flutter_test.dart';

import 'package:sire/modelos/usuario.dart';
import 'soporte.dart';

void main() {
  group('canTakeService', () {
    test('Campo activo con unidad puede atender servicios', () {
      expect(usuarioCampo.canTakeService(), isTrue);
    });

    test('Campo sin unidad asignada no puede', () {
      const sinUnidad = Usuario(
        id: 'x',
        nif: 'x',
        nombre: 'Sin unidad',
        rol: RolUsuario.campo,
      );
      expect(sinUnidad.canTakeService(), isFalse);
    });

    test('Campo inactivo no puede', () {
      expect(usuarioInactivo.canTakeService(), isFalse);
    });

    test('Central no atiende servicios', () {
      expect(usuarioCentral.canTakeService(), isFalse);
    });
  });

  group('puedeCrearServicios', () {
    test('solo Central activo puede crear servicios', () {
      expect(usuarioCentral.puedeCrearServicios, isTrue);
      expect(usuarioCampo.puedeCrearServicios, isFalse);
    });

    test('Central inactivo no puede', () {
      const centralInactivo = Usuario(
        id: 'c',
        nif: 'c',
        nombre: 'Central inactivo',
        rol: RolUsuario.central,
        activo: false,
      );
      expect(centralInactivo.puedeCrearServicios, isFalse);
    });
  });

  group('coincideCon', () {
    test('coincide por identificador, NIF o nombre', () {
      expect(usuarioCampo.coincideCon('T-CAMPO'), isTrue);
      expect(usuarioCampo.coincideCon('T-NIF-CAMPO'), isTrue);
      expect(usuarioCampo.coincideCon('Campo Uno'), isTrue);
    });

    test('ignora mayúsculas y espacios en los extremos', () {
      expect(usuarioCampo.coincideCon('  t-campo '), isTrue);
      expect(usuarioCampo.coincideCon('CAMPO UNO'), isTrue);
    });

    test('no coincide con texto vacío ni con otras cuentas', () {
      expect(usuarioCampo.coincideCon(''), isFalse);
      expect(usuarioCampo.coincideCon('   '), isFalse);
      expect(usuarioCampo.coincideCon('T-OTRA'), isFalse);
    });

    test('no hace coincidencias parciales', () {
      expect(usuarioCampo.coincideCon('Campo'), isFalse);
      expect(usuarioCampo.coincideCon('T-CAM'), isFalse);
    });
  });
}
