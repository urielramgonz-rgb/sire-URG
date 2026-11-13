import 'package:flutter_test/flutter_test.dart';

import 'package:sire/datos/repositorio_bitacora.dart';
import 'package:sire/modelos/entrada_bitacora.dart';
import 'soporte.dart';

void main() {
  late BitacoraRepositorio bitacora;

  setUp(() {
    bitacora = BitacoraRepositorio.paraPruebas();
  });

  test('empieza vacía', () {
    expect(bitacora.entradas, isEmpty);
  });

  test('registra quién, qué y cuándo', () {
    bitacora.registrar(
      usuario: 'Ana',
      accion: AccionBitacora.altaServicio,
      detalle: 'Folio 1',
      servicioId: 's-1',
      momento: horaBase,
    );

    final entrada = bitacora.entradas.single;
    expect(entrada.usuario, 'Ana');
    expect(entrada.accion, AccionBitacora.altaServicio);
    expect(entrada.detalle, 'Folio 1');
    expect(entrada.servicioId, 's-1');
    expect(entrada.momento, horaBase);
  });

  test('conserva el orden de registro', () {
    for (final nombre in ['uno', 'dos', 'tres']) {
      bitacora.registrar(usuario: nombre, accion: AccionBitacora.inicioSesion);
    }
    expect(bitacora.entradas.map((e) => e.usuario), ['uno', 'dos', 'tres']);
  });

  test('es de solo lectura desde afuera: no se pueden borrar ni agregar', () {
    bitacora.registrar(usuario: 'Ana', accion: AccionBitacora.inicioSesion);

    expect(() => bitacora.entradas.clear(), throwsUnsupportedError);
    expect(() => bitacora.entradas.removeAt(0), throwsUnsupportedError);
    expect(
      () => bitacora.entradas.add(
        EntradaBitacora(
          momento: horaBase,
          usuario: 'Intruso',
          accion: AccionBitacora.inicioSesion,
        ),
      ),
      throwsUnsupportedError,
    );
    expect(bitacora.entradas.length, 1);
  });

  test('deServicio filtra por servicio', () {
    bitacora.registrar(
      usuario: 'a',
      accion: AccionBitacora.tiempoRegistrado,
      servicioId: 's-1',
    );
    bitacora.registrar(
      usuario: 'b',
      accion: AccionBitacora.tiempoRegistrado,
      servicioId: 's-2',
    );
    bitacora.registrar(usuario: 'c', accion: AccionBitacora.inicioSesion);

    expect(bitacora.deServicio('s-1').map((e) => e.usuario), ['a']);
    expect(bitacora.deServicio('s-2').map((e) => e.usuario), ['b']);
    expect(bitacora.deServicio('s-9'), isEmpty);
  });

  test('avisa a los listeners en cada registro', () {
    var avisos = 0;
    bitacora.addListener(() => avisos++);
    bitacora.registrar(usuario: 'a', accion: AccionBitacora.inicioSesion);
    bitacora.registrar(usuario: 'b', accion: AccionBitacora.cierreSesion);
    expect(avisos, 2);
  });

  test('si no se indica momento usa la hora actual', () {
    final antes = DateTime.now();
    bitacora.registrar(usuario: 'a', accion: AccionBitacora.inicioSesion);
    final despues = DateTime.now();

    final momento = bitacora.entradas.single.momento;
    expect(momento.isBefore(antes), isFalse);
    expect(momento.isAfter(despues), isFalse);
  });
}
