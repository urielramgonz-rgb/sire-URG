import 'package:flutter_test/flutter_test.dart';

import 'package:sire/datos/autenticacion.dart';
import 'package:sire/datos/repositorio_bitacora.dart';
import 'package:sire/modelos/entrada_bitacora.dart';
import 'package:sire/modelos/usuario.dart';

void main() {
  late BitacoraRepositorio bitacora;
  late DateTime ahora;
  late Autenticacion auth;

  setUp(() {
    bitacora = BitacoraRepositorio.paraPruebas();
    ahora = DateTime(2026, 11, 4, 10, 0);
    auth = Autenticacion.paraPruebas(bitacora: bitacora, reloj: () => ahora);
  });

  // PIN que no corresponde a ninguna cuenta de demostración.
  const pinMalo = '9999';

  ResultadoAcceso fallar(String identificador) =>
      auth.verificar(identificador, pinMalo);

  group('Inicio de sesión', () {
    test('acepta identificador de empleado y PIN correctos', () {
      final resultado = auth.iniciarSesion('EMP-001', '1234');
      expect(resultado.exitoso, isTrue);
      expect(resultado.usuario?.nombre, 'Uriel Ramírez');
      expect(auth.usuarioActual?.id, 'EMP-001');
    });

    test('acepta el NIF y el nombre, sin distinguir mayúsculas ni espacios', () {
      expect(auth.verificar('emp-001', '1234').exitoso, isTrue);
      expect(auth.verificar('  DEMO-NIF-001  ', '1234').exitoso, isTrue);
      expect(auth.verificar('uriel ramírez', '1234').exitoso, isTrue);
    });

    test('el PIN sí distingue entre cuentas', () {
      expect(auth.verificar('EMP-001', '5678').exitoso, isFalse);
      expect(auth.verificar('EMP-002', '5678').exitoso, isTrue);
    });

    test('devuelve el rol correcto para cada cuenta', () {
      expect(auth.verificar('EMP-001', '1234').usuario?.rol, RolUsuario.central);
      final campo = auth.verificar('EMP-002', '5678').usuario;
      expect(campo?.rol, RolUsuario.campo);
      expect(campo?.unidad, 'BYP01');
      expect(campo?.canTakeService(), isTrue);
    });

    test('verificar no abre sesión; iniciarSesion sí', () {
      auth.verificar('EMP-001', '1234');
      expect(auth.usuarioActual, isNull);
      auth.iniciarSesion('EMP-001', '1234');
      expect(auth.usuarioActual, isNotNull);
    });

    test('un intento fallido no abre sesión', () {
      final resultado = auth.iniciarSesion('EMP-001', pinMalo);
      expect(resultado.exitoso, isFalse);
      expect(auth.usuarioActual, isNull);
    });

    test('rechaza campos vacíos sin contarlos como intento', () {
      expect(auth.verificar('', '1234').mensaje, contains('Ingresa'));
      expect(auth.verificar('EMP-001', '').mensaje, contains('Ingresa'));
      expect(fallar('EMP-001').mensaje, contains('Te quedan 2'));
    });

    test('solo permite el acceso a usuarios activos', () {
      final resultado = auth.iniciarSesion('EMP-004', '0000');
      expect(resultado.exitoso, isFalse);
      expect(resultado.mensaje, contains('desactivada'));
      expect(auth.usuarioActual, isNull);
    });

    test('avisa a los listeners al iniciar y cerrar sesión', () {
      var avisos = 0;
      auth.addListener(() => avisos++);
      auth.iniciarSesion('EMP-001', '1234');
      auth.cerrarSesion();
      expect(avisos, 2);
    });
  });

  group('Límite de intentos y bloqueo temporal', () {
    test('cuenta los intentos restantes', () {
      expect(fallar('EMP-001').mensaje, contains('Te quedan 2 intentos'));
      expect(fallar('EMP-001').mensaje, contains('Te quedan 1 intento.'));
    });

    test('bloquea al tercer intento fallido', () {
      fallar('EMP-001');
      fallar('EMP-001');
      final tercero = fallar('EMP-001');
      expect(tercero.exitoso, isFalse);
      expect(tercero.mensaje, contains('bloqueado'));
    });

    test('durante el bloqueo rechaza incluso el PIN correcto', () {
      for (var i = 0; i < Autenticacion.maxIntentos; i++) {
        fallar('EMP-001');
      }
      final resultado = auth.iniciarSesion('EMP-001', '1234');
      expect(resultado.exitoso, isFalse);
      expect(resultado.mensaje, contains('Intenta de nuevo'));
      expect(auth.usuarioActual, isNull);
    });

    test('informa cuántos segundos faltan', () {
      for (var i = 0; i < Autenticacion.maxIntentos; i++) {
        fallar('EMP-001');
      }
      ahora = ahora.add(const Duration(seconds: 10));
      expect(auth.verificar('EMP-001', '1234').mensaje, contains('20 s'));
    });

    test('sigue bloqueado hasta que se cumple el tiempo', () {
      for (var i = 0; i < Autenticacion.maxIntentos; i++) {
        fallar('EMP-001');
      }
      ahora = ahora.add(const Duration(seconds: 29));
      expect(auth.verificar('EMP-001', '1234').exitoso, isFalse);
    });

    test('se desbloquea al terminar el tiempo y reinicia los intentos', () {
      for (var i = 0; i < Autenticacion.maxIntentos; i++) {
        fallar('EMP-001');
      }
      ahora = ahora.add(const Duration(seconds: 31));
      expect(auth.verificar('EMP-001', '1234').exitoso, isTrue);

      expect(fallar('EMP-001').mensaje, contains('Te quedan 2'));
    });

    test('un acierto reinicia el contador de fallos', () {
      fallar('EMP-001');
      fallar('EMP-001');
      expect(auth.verificar('EMP-001', '1234').exitoso, isTrue);
      expect(fallar('EMP-001').mensaje, contains('Te quedan 2'));
    });

    test('el bloqueo de una cuenta no afecta a las demás', () {
      for (var i = 0; i < Autenticacion.maxIntentos; i++) {
        fallar('EMP-001');
      }
      expect(auth.verificar('EMP-002', '5678').exitoso, isTrue);
    });

    test('también limita los intentos con identificadores inexistentes', () {
      for (var i = 0; i < Autenticacion.maxIntentos; i++) {
        fallar('nadie');
      }
      expect(auth.verificar('NADIE', '1234').mensaje, contains('Intenta'));
    });

    test('no revela si la cuenta existe', () {
      final conocida = fallar('EMP-001').mensaje;
      final desconocida = fallar('no-existe').mensaje;
      expect(desconocida, conocida);
    });
  });

  group('Cierre de sesión', () {
    test('limpia el usuario actual y lo registra', () {
      auth.iniciarSesion('EMP-002', '5678');
      auth.cerrarSesion();

      expect(auth.usuarioActual, isNull);
      expect(
        bitacora.entradas.map((e) => e.accion),
        contains(AccionBitacora.cierreSesion),
      );
    });

    test('sin sesión abierta no hace nada', () {
      var avisos = 0;
      auth.addListener(() => avisos++);
      auth.cerrarSesion();
      expect(avisos, 0);
      expect(bitacora.entradas, isEmpty);
    });
  });

  group('Cambio de PIN', () {
    late Usuario campo;

    setUp(() {
      campo = auth.verificar('EMP-002', '5678').usuario!;
    });

    test('guarda el PIN nuevo y deja de aceptar el anterior', () {
      expect(auth.cambiarPin(campo, '8765'), isNull);
      expect(auth.verificar('EMP-002', '5678').exitoso, isFalse);
      expect(auth.verificar('EMP-002', '8765').exitoso, isTrue);
    });

    test('lo registra en la bitácora', () {
      auth.cambiarPin(campo, '8765');
      expect(
        bitacora.entradas.map((e) => e.accion),
        contains(AccionBitacora.cambioPin),
      );
    });

    test('rechaza un PIN demasiado corto', () {
      expect(auth.cambiarPin(campo, '12'), contains('entre 4 y 8'));
    });

    test('rechaza un PIN demasiado largo', () {
      expect(auth.cambiarPin(campo, '123456789'), contains('entre 4 y 8'));
    });

    test('rechaza un PIN con letras o símbolos', () {
      expect(auth.cambiarPin(campo, 'abcd'), contains('números'));
      expect(auth.cambiarPin(campo, '12 4'), contains('números'));
    });

    test('rechaza repetir el PIN actual', () {
      expect(auth.cambiarPin(campo, '5678'), contains('distinto'));
    });

    test('un cambio rechazado no altera el PIN', () {
      auth.cambiarPin(campo, '12');
      expect(auth.verificar('EMP-002', '5678').exitoso, isTrue);
    });
  });

  group('Bitácora de accesos', () {
    test('registra cada intento fallido con su número', () {
      fallar('EMP-001');
      fallar('EMP-001');

      final detalles = bitacora.entradas
          .where((e) => e.accion == AccionBitacora.intentoFallido)
          .map((e) => e.detalle)
          .toList();
      expect(detalles, ['Intento 1 de 3', 'Intento 2 de 3']);
    });

    test('registra el bloqueo temporal', () {
      for (var i = 0; i < Autenticacion.maxIntentos; i++) {
        fallar('EMP-001');
      }
      expect(
        bitacora.entradas.map((e) => e.accion),
        contains(AccionBitacora.bloqueoTemporal),
      );
    });

    test('registra el inicio de sesión con el rol', () {
      auth.iniciarSesion('EMP-002', '5678');
      final entrada = bitacora.entradas.single;
      expect(entrada.accion, AccionBitacora.inicioSesion);
      expect(entrada.usuario, 'Juan González');
      expect(entrada.detalle, contains('Campo'));
    });

    test('nunca guarda el PIN en la bitácora', () {
      fallar('EMP-001');
      auth.iniciarSesion('EMP-001', '1234');
      auth.cambiarPin(auth.usuarioActual!, '4321');
      auth.cerrarSesion();

      final texto = bitacora.entradas
          .map((e) => '${e.usuario} ${e.detalle}')
          .join(' ');
      for (final pin in [pinMalo, '1234', '4321']) {
        expect(texto.contains(pin), isFalse, reason: 'No debe incluir $pin');
      }
    });

    test('los fallos de cuentas inexistentes quedan atribuidos al texto escrito', () {
      fallar('intruso');
      expect(bitacora.entradas.single.usuario, 'intruso');
    });
  });
}
