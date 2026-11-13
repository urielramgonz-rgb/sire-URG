import 'package:flutter_test/flutter_test.dart';

import 'package:sire/modelos/enums.dart';
import 'package:sire/modelos/reporte_servicio.dart';
import 'soporte.dart';

void main() {
  group('Estado derivado de los tiempos', () {
    const esperados = [
      EstadoServicio.asignada,
      EstadoServicio.enCamino,
      EstadoServicio.enEscena,
      EstadoServicio.enAtencion,
      EstadoServicio.enTraslado,
      EstadoServicio.finalizado,
    ];

    for (var marcados = 1; marcados <= 6; marcados++) {
      test(
        'con $marcados tiempo(s) registrado(s) el estado es '
        '${esperados[marcados - 1].etiqueta}',
        () {
          final reporte = reportePrueba(
            cronologia: cronologiaConMarcas(marcados),
          );
          expect(reporte.estado, esperados[marcados - 1]);
        },
      );
    }

    test('sin ningún tiempo el servicio figura como asignado', () {
      final reporte = reportePrueba(cronologia: cronologiaConMarcas(0));
      expect(reporte.estado, EstadoServicio.asignada);
    });

    test('solo está cerrado cuando se marca el fin del servicio', () {
      expect(reportePrueba(cronologia: cronologiaConMarcas(5)).cerrado, isFalse);
      expect(reportePrueba(cronologia: cronologiaConMarcas(6)).cerrado, isTrue);
    });
  });

  group('Línea de tiempo', () {
    test('la línea inicial solo trae registrado el envío del reporte', () {
      final lineas = EventoCronologia.lineaInicial(horaBase);
      expect(lineas.length, EstatusServicio.values.length);
      expect(lineas.first.estatus, EstatusServicio.alertaEnviada);
      expect(lineas.first.completado, isTrue);
      expect(lineas.first.marcadoEn, horaBase);
      expect(lineas.skip(1).every((evento) => !evento.completado), isTrue);
    });

    test('los tiempos siguen el orden cronológico del enum', () {
      final reporte = reportePrueba();
      expect(
        reporte.cronologia.map((evento) => evento.estatus).toList(),
        EstatusServicio.values,
      );
    });

    test('el siguiente pendiente es el primero sin registrar', () {
      final reporte = reportePrueba(cronologia: cronologiaConMarcas(3));
      expect(reporte.siguientePendiente?.estatus, EstatusServicio.inicioAtencion);
    });

    test('sin pendientes, siguientePendiente es null', () {
      final reporte = reportePrueba(cronologia: cronologiaConMarcas(6));
      expect(reporte.siguientePendiente, isNull);
    });

    test('ultimaMarca devuelve la hora más reciente registrada', () {
      final reporte = reportePrueba(cronologia: cronologiaConMarcas(4));
      expect(reporte.ultimaMarca, horaBase.add(const Duration(minutes: 3)));
    });

    test('ultimaMarca es null si no hay ningún tiempo', () {
      final reporte = reportePrueba(cronologia: cronologiaConMarcas(0));
      expect(reporte.ultimaMarca, isNull);
    });
  });

  group('EventoCronologia', () {
    test('un tiempo pendiente muestra --:--', () {
      const evento = EventoCronologia(estatus: EstatusServicio.salidaBase);
      expect(evento.completado, isFalse);
      expect(evento.hora, '--:--');
    });

    test('la hora se muestra con dos dígitos', () {
      final evento = EventoCronologia(
        estatus: EstatusServicio.salidaBase,
        marcadoEn: DateTime(2026, 11, 4, 9, 5),
      );
      expect(evento.hora, '09:05');
      expect(evento.completado, isTrue);
    });

    test('marcar devuelve un evento nuevo y no modifica el original', () {
      const original = EventoCronologia(estatus: EstatusServicio.llegadaLugar);
      final marcado = original.marcar(horaBase, 'Unidad BYP01');
      expect(original.completado, isFalse);
      expect(marcado.completado, isTrue);
      expect(marcado.detalle, 'Unidad BYP01');
      expect(marcado.estatus, EstatusServicio.llegadaLugar);
    });

    test('el título coincide con la etiqueta del estatus', () {
      const evento = EventoCronologia(estatus: EstatusServicio.finServicio);
      expect(evento.titulo, 'Fin del servicio');
    });
  });

  group('ReporteServicio inmutable', () {
    test('conCronologia no modifica el reporte original', () {
      final original = reportePrueba();
      final nuevo = original.conCronologia(cronologiaConMarcas(3));
      expect(original.estado, EstadoServicio.asignada);
      expect(nuevo.estado, EstadoServicio.enEscena);
    });

    test('conCronologia conserva el resto de los datos', () {
      final original = reportePrueba(folio: '1234');
      final nuevo = original.conCronologia(cronologiaConMarcas(2));
      expect(nuevo.id, original.id);
      expect(nuevo.folio, '1234');
      expect(nuevo.unidadesAsignadas, original.unidadesAsignadas);
      expect(nuevo.prioridad, original.prioridad);
    });

    test('conDatosServicio conserva la cronología', () {
      final original = reportePrueba(cronologia: cronologiaConMarcas(3));
      final nuevo = original.actualizarDatosServicio(
        eventos: 'Texto',
        corporaciones: const [],
        unidades: const [],
        cierre: 'Cierre',
      );
      expect(nuevo.estado, EstadoServicio.enEscena);
      expect(nuevo.eventosCampo, 'Texto');
      expect(nuevo.cierreServicio, 'Cierre');
      expect(original.eventosCampo, '');
    });

    test('folioVisible indica cuando no hay folio', () {
      expect(reportePrueba(folio: '  ').folioVisible, 'Sin folio');
      expect(reportePrueba(folio: '0154').folioVisible, '0154');
    });
  });

  group('Catálogos', () {
    test('los códigos de estatus son únicos', () {
      final codigos = EstatusServicio.values.map((e) => e.codigo).toSet();
      expect(codigos.length, EstatusServicio.values.length);
    });

    test('toString devuelve la etiqueta legible', () {
      expect(PrioridadServicio.alta.toString(), 'Alta');
      expect(EstadoServicio.enCamino.toString(), 'En camino');
      expect(EstatusServicio.salidaBase.toString(), 'Salida de base');
    });

    test('la prioridad tiene tres niveles', () {
      expect(PrioridadServicio.values.map((p) => p.etiqueta), [
        'Baja',
        'Media',
        'Alta',
      ]);
    });
  });
}
