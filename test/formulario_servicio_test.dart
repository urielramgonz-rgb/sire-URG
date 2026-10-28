import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sire/datos/repositorio_reportes.dart';
import 'package:sire/modelos/reporte_servicio.dart';
import 'package:sire/pantallas/pantalla_formulario_servicio.dart';

void main() {
  final repositorio = ReportesRepositorio.instancia;

  ReporteServicio crearReporteNuevo() {
    final reporte = ReporteServicio(
      id: repositorio.crearId(),
      folio: '',
      categoria: 'INCENDIO',
      subcategoria: 'Pastizal',
      camposFormulario: const {},
      ubicacion: 'No especificado',
      detallesUbicacion: const {},
      solicitante: 'Central SMA',
      datosSolicitante: const {},
      unidadesAsignadas: const ['BYP01'],
      prioridad: 'Media',
      personal: const [],
      apoyoExterno: 'No especificado',
      estado: 'Asignada',
      cronologia: const [
        EventoCronologia(
          titulo: 'Reporte enviado',
          hora: '15:00',
          completado: true,
          detalle: 'Central',
        ),
        EventoCronologia(
          titulo: 'Salida de base',
          hora: '--:--',
          completado: false,
          detalle: 'Pendiente',
        ),
      ],
    );
    expect(repositorio.agregar(reporte), isTrue);
    return reporte;
  }

  testWidgets(
    'conserva etapas y datos, agrupa unidades y vuelve del reporte antes de enviar',
    (tester) async {
      final reporte = crearReporteNuevo();
      await tester.pumpWidget(
        MaterialApp(home: PantallaFormularioServicio(reporte: reporte)),
      );

      await tester.enterText(
        find.byKey(const ValueKey('service-events')),
        'Acciones registradas durante el servicio.',
      );
      await tester.tap(find.text('Corporaciones de apoyo'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Cruz Roja'));
      await tester.tap(find.text('Cruz Roja'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Protección Civil'));
      await tester.tap(find.text('Protección Civil'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Unidades y tripulación'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Agregar unidad').first);
      await tester.tap(find.text('Agregar unidad').first);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('Cruz Roja-0-identificador')),
        'CR-21',
      );
      await tester.enterText(
        find.byKey(const ValueKey('Cruz Roja-0-responsable')),
        'María López',
      );
      await tester.ensureVisible(find.text('Agregar tripulante').first);
      await tester.tap(find.text('Agregar tripulante').first);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('Cruz Roja-0-tripulante-0')),
        'Luis Pérez',
      );
      await tester.ensureVisible(find.text('Agregar tripulante').first);
      await tester.tap(find.text('Agregar tripulante').first);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextFormField>(
              find.byKey(const ValueKey('Cruz Roja-0-tripulante-0')),
            )
            .controller!
            .text,
        'Luis Pérez',
      );
      await tester.ensureVisible(find.text('Agregar otra unidad'));
      await tester.tap(find.text('Agregar otra unidad'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Agregar unidad').last);
      await tester.tap(find.text('Agregar unidad').last);
      await tester.pumpAndSettle();

      var guardado = repositorio.porId(reporte.id)!;
      expect(
        guardado.eventosCampo,
        'Acciones registradas durante el servicio.',
      );
      expect(guardado.corporacionesApoyo, ['Cruz Roja', 'Protección Civil']);
      expect(
        guardado.unidadesApoyo.map((unidad) => unidad.corporacion).toList(),
        ['Cruz Roja', 'Cruz Roja', 'Protección Civil'],
      );
      expect(guardado.unidadesApoyo.first.identificador, 'CR-21');
      expect(guardado.unidadesApoyo.first.responsable, 'María López');
      expect(guardado.unidadesApoyo.first.tripulacion, ['Luis Pérez']);
      expect(find.text('Unidad 2'), findsOneWidget);
      expect(find.text('Cruz Roja'), findsOneWidget);
      expect(find.text('Protección Civil'), findsOneWidget);

      await tester.tap(find.text('Cierre del servicio'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('service-closure')),
        'Servicio concluido.',
      );
      await tester.tap(find.text('Ver reporte'));
      await tester.pumpAndSettle();
      expect(
        find.text('Acciones registradas durante el servicio.'),
        findsOneWidget,
      );
      expect(find.text('CR-21'), findsOneWidget);
      expect(find.text('Servicio concluido.'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.chevron_left).last);
      await tester.pumpAndSettle();
      expect(find.text('CIERRE DEL SERVICIO'), findsOneWidget);
      expect(
        tester
            .widget<TextFormField>(
              find.byKey(const ValueKey('service-closure')),
            )
            .controller!
            .text,
        'Servicio concluido.',
      );
      await tester.ensureVisible(find.text('ENVIAR REPORTE A CENTRAL'));
      await tester.tap(find.text('ENVIAR REPORTE A CENTRAL'));
      await tester.pumpAndSettle();
      expect(find.text('Reporte enviado a Central.'), findsOneWidget);
      expect(
        repositorio.reportesParaCentral
            .singleWhere((item) => item.id == reporte.id)
            .unidadesApoyo
            .length,
        3,
      );
    },
  );

  testWidgets('sin apoyo lleva al cierre y no crea unidades vacías', (
    tester,
  ) async {
    final reporte = crearReporteNuevo();
    await tester.pumpWidget(
      MaterialApp(home: PantallaFormularioServicio(reporte: reporte)),
    );
    await tester.enterText(
      find.byKey(const ValueKey('service-events')),
      'Sin apoyo externo.',
    );
    await tester.tap(find.text('Corporaciones de apoyo'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('SIN CORPORACIONES DE APOYO'));
    await tester.tap(find.text('SIN CORPORACIONES DE APOYO'));
    await tester.pumpAndSettle();

    expect(find.text('CIERRE DEL SERVICIO'), findsOneWidget);
    final guardado = repositorio.porId(reporte.id)!;
    expect(guardado.eventosCampo, 'Sin apoyo externo.');
    expect(guardado.corporacionesApoyo, isEmpty);
    expect(guardado.unidadesApoyo, isEmpty);
  });

  test('Central refleja borrador hasta el primer envío y después conserva lo publicado', () {
    final reporte = crearReporteNuevo();
    repositorio.actualizarDatosServicio(
      id: reporte.id,
      eventos: 'Primera versión',
      corporaciones: const ['Cruz Roja'],
      unidades: const [],
      cierre: '',
    );
    expect(
      repositorio.reportesParaCentral
          .singleWhere((item) => item.id == reporte.id)
          .eventosCampo,
      'Primera versión',
    );

    expect(repositorio.publicarDatosServicio(reporte.id), isTrue);
    repositorio.actualizarDatosServicio(
      id: reporte.id,
      eventos: 'Borrador posterior',
      corporaciones: const ['Protección Civil'],
      unidades: const [],
      cierre: 'Cierre en borrador',
    );

    expect(repositorio.porId(reporte.id)!.eventosCampo, 'Borrador posterior');
    final central = repositorio.reportesParaCentral.singleWhere(
      (item) => item.id == reporte.id,
    );
    expect(central.eventosCampo, 'Primera versión');
    expect(central.corporacionesApoyo, ['Cruz Roja']);
    expect(central.cierreServicio, '');

    expect(repositorio.porId('demo-0154')!.folio, '0154');
    expect(repositorio.porId('demo-0155')!.folio, '0155');
    expect(repositorio.porId('demo-0156')!.folio, '0156');
    expect(repositorio.porId('demo-0157')!.folio, '0157');
  });

  test('los cuatro reportes de muestra conservan datos y seis eventos', () {
    final choque = repositorio.porId('demo-0154')!;
    expect(choque.unidadesAsignadas, ['BYP01']);
    expect(choque.estado, 'En atención');
    expect(choque.ubicacion, 'Carretera SMA–Dolores, km 12');
    expect(choque.corporacionesApoyo, ['Cruz Roja']);
    expect(choque.unidadesApoyo.single.identificador, 'CR-12');
    expect(choque.unidadesApoyo.single.responsable, 'Andrea Morales');
    expect(choque.unidadesApoyo.single.tripulacion, [
      'Diego Ruiz',
      'Paula Hernández',
    ]);
    expect(choque.cronologia.map((evento) => evento.hora).toList(), [
      '14:32',
      '14:34',
      '14:47',
      '14:50',
      '--:--',
      '--:--',
    ]);

    for (final id in ['demo-0154', 'demo-0155', 'demo-0156', 'demo-0157']) {
      expect(repositorio.porId(id)!.cronologia, hasLength(6));
      expect(
        repositorio
            .porId(id)!
            .cronologia
            .where((evento) => !evento.completado)
            .every((evento) => evento.hora == '--:--'),
        isTrue,
      );
    }
  });
}
