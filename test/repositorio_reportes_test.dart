import 'package:flutter_test/flutter_test.dart';

import 'package:sire/datos/repositorio_bitacora.dart';
import 'package:sire/datos/repositorio_reportes.dart';
import 'package:sire/modelos/entrada_bitacora.dart';
import 'package:sire/modelos/enums.dart';
import 'package:sire/modelos/usuario.dart';
import 'soporte.dart';

void main() {
  late BitacoraRepositorio bitacora;
  late ReportesRepositorio repo;

  setUp(() {
    bitacora = BitacoraRepositorio.paraPruebas();
    repo = ReportesRepositorio.paraPruebas(
      reportes: [reportePrueba()],
      bitacora: bitacora,
    );
  });

  String? marcar(
    EstatusServicio estatus, {
    Usuario usuario = usuarioCampo,
    DateTime? momento,
    String id = 't-1',
  }) {
    return repo.marcarTiempo(
      id: id,
      estatus: estatus,
      usuario: usuario,
      momento: momento ?? horaBase.add(const Duration(minutes: 1)),
    );
  }

  group('marcarTiempo · caso correcto', () {
    test('registra el siguiente tiempo con la hora indicada', () {
      final error = marcar(EstatusServicio.salidaBase);

      expect(error, isNull);
      final reporte = repo.porId('t-1')!;
      final evento = reporte.cronologia.firstWhere(
        (e) => e.estatus == EstatusServicio.salidaBase,
      );
      expect(evento.completado, isTrue);
      expect(evento.marcadoEn, horaBase.add(const Duration(minutes: 1)));
      expect(evento.detalle, 'Unidad BYP01');
    });

    test('el estado avanza con cada tiempo', () {
      marcar(EstatusServicio.salidaBase);
      expect(repo.porId('t-1')!.estado, EstadoServicio.enCamino);

      marcar(
        EstatusServicio.llegadaLugar,
        momento: horaBase.add(const Duration(minutes: 2)),
      );
      expect(repo.porId('t-1')!.estado, EstadoServicio.enEscena);
    });

    test('Central ve el avance en la versión publicada', () {
      marcar(EstatusServicio.salidaBase);
      expect(repo.porIdParaCentral('t-1')!.estado, EstadoServicio.enCamino);
    });

    test('notifica a los listeners una sola vez', () {
      var avisos = 0;
      repo.addListener(() => avisos++);
      marcar(EstatusServicio.salidaBase);
      expect(avisos, 1);
    });

    test('deja una entrada en la bitácora con quién, qué y cuándo', () {
      marcar(EstatusServicio.salidaBase);

      final entradas = bitacora.deServicio('t-1');
      expect(entradas.length, 1);
      expect(entradas.single.accion, AccionBitacora.tiempoRegistrado);
      expect(entradas.single.usuario, 'Campo Uno');
      expect(entradas.single.detalle, contains('Salida de base'));
      expect(entradas.single.detalle, contains('10:01'));
      expect(entradas.single.momento, horaBase.add(const Duration(minutes: 1)));
    });

    test('una hora igual a la última marca es válida', () {
      final error = marcar(EstatusServicio.salidaBase, momento: horaBase);
      expect(error, isNull);
    });

    test('recorre los cinco tiempos de Campo hasta finalizar', () {
      var minutos = 1;
      for (final estatus in EstatusServicio.values.skip(1)) {
        final error = marcar(
          estatus,
          momento: horaBase.add(Duration(minutes: minutos++)),
        );
        expect(error, isNull, reason: 'Debe permitir ${estatus.etiqueta}');
      }

      final reporte = repo.porId('t-1')!;
      expect(reporte.estado, EstadoServicio.finalizado);
      expect(reporte.cerrado, isTrue);
      expect(reporte.siguientePendiente, isNull);
      expect(bitacora.deServicio('t-1').length, 5);
    });

    test('no modifica el reporte que ya se tenía en la mano', () {
      final antes = repo.porId('t-1')!;
      marcar(EstatusServicio.salidaBase);
      expect(antes.siguientePendiente?.estatus, EstatusServicio.salidaBase);
      expect(antes.estado, EstadoServicio.asignada);
    });

    test('los tiempos ya registrados no cambian al marcar el siguiente', () {
      marcar(EstatusServicio.salidaBase);
      final horaSalida = repo
          .porId('t-1')!
          .cronologia
          .firstWhere((e) => e.estatus == EstatusServicio.salidaBase)
          .marcadoEn;

      marcar(
        EstatusServicio.llegadaLugar,
        momento: horaBase.add(const Duration(minutes: 9)),
      );

      final despues = repo
          .porId('t-1')!
          .cronologia
          .firstWhere((e) => e.estatus == EstatusServicio.salidaBase)
          .marcadoEn;
      expect(despues, horaSalida);
    });
  });

  group('marcarTiempo · orden', () {
    test('rechaza saltarse un tiempo', () {
      final error = marcar(EstatusServicio.llegadaLugar);
      expect(error, contains('en orden'));
      expect(error, contains('Salida de base'));
      expect(repo.porId('t-1')!.estado, EstadoServicio.asignada);
    });

    test('rechaza registrar dos veces el mismo tiempo', () {
      expect(marcar(EstatusServicio.salidaBase), isNull);
      final segundo = marcar(
        EstatusServicio.salidaBase,
        momento: horaBase.add(const Duration(minutes: 5)),
      );
      expect(segundo, contains('en orden'));

      final marcas = repo
          .porId('t-1')!
          .cronologia
          .where((e) => e.estatus == EstatusServicio.salidaBase)
          .single;
      expect(marcas.marcadoEn, horaBase.add(const Duration(minutes: 1)));
    });

    test('rechaza volver a marcar un tiempo anterior', () {
      marcar(EstatusServicio.salidaBase);
      marcar(
        EstatusServicio.llegadaLugar,
        momento: horaBase.add(const Duration(minutes: 2)),
      );
      final error = marcar(
        EstatusServicio.salidaBase,
        momento: horaBase.add(const Duration(minutes: 3)),
      );
      expect(error, isNotNull);
    });

    test('rechaza una hora anterior al último tiempo registrado', () {
      final error = marcar(
        EstatusServicio.salidaBase,
        momento: horaBase.subtract(const Duration(minutes: 1)),
      );
      expect(error, contains('hora del dispositivo'));
      expect(repo.porId('t-1')!.estado, EstadoServicio.asignada);
    });

    test('el rechazo no deja rastro ni avisa a los listeners', () {
      var avisos = 0;
      repo.addListener(() => avisos++);

      marcar(EstatusServicio.finServicio);

      expect(avisos, 0);
      expect(bitacora.entradas, isEmpty);
    });
  });

  group('marcarTiempo · inmutabilidad tras el cierre', () {
    setUp(() {
      repo = ReportesRepositorio.paraPruebas(
        reportes: [reportePrueba(cronologia: cronologiaConMarcas(6))],
        bitacora: bitacora,
      );
    });

    test('un servicio finalizado no acepta más tiempos', () {
      final error = marcar(
        EstatusServicio.finServicio,
        momento: horaBase.add(const Duration(hours: 1)),
      );
      expect(error, contains('finalizado'));
    });

    test('los tiempos del servicio finalizado quedan intactos', () {
      final antes = repo.porId('t-1')!.cronologia.map((e) => e.marcadoEn);
      marcar(
        EstatusServicio.finServicio,
        momento: horaBase.add(const Duration(hours: 1)),
      );
      final despues = repo.porId('t-1')!.cronologia.map((e) => e.marcadoEn);
      expect(despues.toList(), antes.toList());
    });
  });

  group('marcarTiempo · permisos', () {
    test('Central no puede registrar tiempos de Campo', () {
      final error = marcar(EstatusServicio.salidaBase, usuario: usuarioCentral);
      expect(error, contains('permiso'));
      expect(repo.porId('t-1')!.estado, EstadoServicio.asignada);
    });

    test('una unidad no asignada no puede registrar tiempos', () {
      final error = marcar(
        EstatusServicio.salidaBase,
        usuario: usuarioOtraUnidad,
      );
      expect(error, contains('permiso'));
    });

    test('un usuario inactivo no puede registrar tiempos', () {
      final error = marcar(
        EstatusServicio.salidaBase,
        usuario: usuarioInactivo,
      );
      expect(error, contains('permiso'));
    });

    test('un servicio que no existe se rechaza', () {
      final error = marcar(EstatusServicio.salidaBase, id: 'no-existe');
      expect(error, contains('No se encontró'));
    });

    test('los permisos se revisan por servicio, no por usuario', () {
      repo = ReportesRepositorio.paraPruebas(
        reportes: [
          reportePrueba(id: 'a', folio: '1', unidades: const ['BYP01']),
          reportePrueba(id: 'b', folio: '2', unidades: const ['BYP02']),
        ],
        bitacora: bitacora,
      );
      expect(marcar(EstatusServicio.salidaBase, id: 'a'), isNull);
      expect(
        marcar(EstatusServicio.salidaBase, id: 'b'),
        contains('permiso'),
      );
    });
  });

  group('agregar', () {
    test('rechaza un folio repetido', () {
      final repetido = reportePrueba(id: 't-2', folio: '9001');
      expect(repo.agregar(repetido, creadoPor: usuarioCentral), isFalse);
      expect(repo.reportes.length, 1);
      expect(bitacora.entradas, isEmpty);
    });

    test('el folio se compara sin espacios ni mayúsculas', () {
      final repetido = reportePrueba(id: 't-2', folio: ' 9001 ');
      expect(repo.agregar(repetido), isFalse);

      repo = ReportesRepositorio.paraPruebas(
        reportes: [reportePrueba(folio: 'abc')],
        bitacora: bitacora,
      );
      expect(repo.agregar(reportePrueba(id: 't-2', folio: 'ABC')), isFalse);
    });

    test('acepta un folio nuevo y lo deja en la bitácora', () {
      final nuevo = reportePrueba(id: 't-2', folio: '9002');
      expect(repo.agregar(nuevo, creadoPor: usuarioCentral), isTrue);

      expect(repo.reportes.length, 2);
      final entradas = bitacora.deServicio('t-2');
      expect(entradas.single.accion, AccionBitacora.altaServicio);
      expect(entradas.single.usuario, 'Central Uno');
    });

    test('sin usuario, la alta queda atribuida al sistema', () {
      repo.agregar(reportePrueba(id: 't-2', folio: '9002'));
      expect(bitacora.deServicio('t-2').single.usuario, 'Sistema');
    });
  });

  group('asignadosA', () {
    test('devuelve solo los servicios de la unidad', () {
      repo = ReportesRepositorio.paraPruebas(
        reportes: [
          reportePrueba(id: 'a', folio: '1', unidades: const ['BYP01']),
          reportePrueba(id: 'b', folio: '2', unidades: const ['BYP02']),
          reportePrueba(
            id: 'c',
            folio: '3',
            unidades: const ['BYP01', 'BYP02'],
          ),
        ],
        bitacora: bitacora,
      );
      expect(repo.asignadosA('BYP01').map((r) => r.id), ['a', 'c']);
      expect(repo.asignadosA('BYP02').map((r) => r.id), ['b', 'c']);
      expect(repo.asignadosA('BYP09'), isEmpty);
    });
  });

  group('Datos de Campo: borrador y envío a Central', () {
    test('tras publicar, Central no ve las ediciones hasta reenviar', () {
      void editar(String texto) => repo.actualizarDatosServicio(
        id: 't-1',
        eventos: texto,
        corporaciones: const [],
        unidades: const [],
        cierre: '',
      );

      editar('Versión 1');
      expect(repo.publicarDatosServicio('t-1', usuario: usuarioCampo), isTrue);

      editar('Versión 2');
      expect(repo.porId('t-1')!.eventosCampo, 'Versión 2');
      expect(repo.porIdParaCentral('t-1')!.eventosCampo, 'Versión 1');

      repo.publicarDatosServicio('t-1', usuario: usuarioCampo);
      expect(repo.porIdParaCentral('t-1')!.eventosCampo, 'Versión 2');
    });

    test('publicar deja una entrada en la bitácora', () {
      repo.publicarDatosServicio('t-1', usuario: usuarioCampo);
      final entrada = bitacora.deServicio('t-1').single;
      expect(entrada.accion, AccionBitacora.reporteEnviado);
      expect(entrada.usuario, 'Campo Uno');
    });

    test('publicar un servicio inexistente devuelve false', () {
      expect(repo.publicarDatosServicio('no-existe'), isFalse);
      expect(bitacora.entradas, isEmpty);
    });

    test('Central sigue viendo los tiempos nuevos tras publicar', () {
      repo.actualizarDatosServicio(
        id: 't-1',
        eventos: 'Texto enviado',
        corporaciones: const [],
        unidades: const [],
        cierre: '',
      );
      repo.publicarDatosServicio('t-1', usuario: usuarioCampo);

      marcar(EstatusServicio.salidaBase);

      final paraCentral = repo.porIdParaCentral('t-1')!;
      expect(paraCentral.estado, EstadoServicio.enCamino);
      expect(paraCentral.eventosCampo, 'Texto enviado');
    });
  });
}
