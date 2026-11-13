import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sire/componentes/seccion_informacion_personas.dart';
import 'package:sire/modelos/configuracion_campos_alerta.dart';

void main() {
  test('Industrial tiene la nueva lista y mantiene otras subcategorías', () {
    final industrial =
        ConfiguracionCamposAlerta.porCategoria['INCENDIO']!['Industrial']!;
    expect(industrial.first.opciones, [
      'Planta de producción',
      'Almacén industrial',
      'Taller industrial',
      'Planta de procesamiento',
      'Patio industrial',
      'Otro',
      'Desconocido',
    ]);
    expect(
      industrial.map((campo) => campo.etiqueta),
      contains('Área afectada'),
    );
    expect(
      industrial.map((campo) => campo.etiqueta),
      contains('Extensión del incendio'),
    );
    expect(
      ConfiguracionCamposAlerta.porCategoria['INCENDIO']!['Comercio']!.map(
        (campo) => campo.etiqueta,
      ),
      contains('Materiales que se queman'),
    );
  });

  testWidgets('las cantidades solo aceptan enteros positivos', (tester) async {
    final formKey = GlobalKey<FormState>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: _FormularioPersonas(formKey: formKey)),
      ),
    );

    final cantidad = find.byKey(
      const ValueKey('¿Hay personas atrapadas?:cantidad'),
    );
    await tester.enterText(cantidad, '1.5-abc');
    await tester.pump();
    expect(tester.widget<TextFormField>(cantidad).controller!.text, '15');

    await tester.enterText(cantidad, '0');
    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(
      find.text('Ingresa un número entero positivo mayor que cero.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'marcar cantidad desconocida limpia el número y permite continuar',
    (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: _FormularioPersonas(formKey: formKey)),
        ),
      );
      final cantidad = find.byKey(
        const ValueKey('¿Hay personas atrapadas?:cantidad'),
      );
      await tester.enterText(cantidad, '4');
      await tester.tap(find.text('Cantidad desconocida').first);
      await tester.pump();

      expect(tester.widget<TextFormField>(cantidad).controller!.text, isEmpty);
      expect(formKey.currentState!.validate(), isTrue);
    },
  );

  testWidgets('responder No oculta y limpia la cantidad asociada', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: _FormularioPersonas(formKey: formKey)),
      ),
    );
    final cantidad = find.byKey(
      const ValueKey('¿Hay personas atrapadas?:cantidad'),
    );
    await tester.enterText(cantidad, '4');
    await tester.tap(
      find.byKey(const ValueKey('¿Hay personas atrapadas?:respuesta')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('No').last);
    await tester.pumpAndSettle();

    expect(cantidad, findsNothing);
    expect(find.text('Número aproximado de personas atrapadas'), findsNothing);
    expect(formKey.currentState!.validate(), isTrue);
  });

  testWidgets('atrapadas y lesionadas conservan cantidades separadas', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: _FormularioPersonas(formKey: formKey)),
      ),
    );
    await tester.enterText(find.byType(TextFormField).first, '2');
    await tester.tap(find.byType(DropdownButtonFormField<String>).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sí').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).last, '3');

    expect(
      tester
          .widget<TextFormField>(find.byType(TextFormField).first)
          .controller!
          .text,
      '2',
    );
    expect(
      tester
          .widget<TextFormField>(find.byType(TextFormField).last)
          .controller!
          .text,
      '3',
    );
  });
}

class _FormularioPersonas extends StatefulWidget {
  const _FormularioPersonas({required this.formKey});

  final GlobalKey<FormState> formKey;

  @override
  State<_FormularioPersonas> createState() => _FormularioPersonasState();
}

class _FormularioPersonasState extends State<_FormularioPersonas> {
  final _atrapadas = TextEditingController();
  final _lesionadas = TextEditingController();
  String? _respuestaAtrapadas = 'Sí';
  String? _respuestaLesionadas = 'No';
  bool _cantidadDesconocida = false;
  bool _cantidadLesionadasDesconocida = false;

  @override
  void dispose() {
    _atrapadas.dispose();
    _lesionadas.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: SeccionInformacionPersonas(
        mostrarAtrapadas: true,
        mostrarLesionadas: true,
        respuestaAtrapadas: _respuestaAtrapadas,
        respuestaLesionadas: _respuestaLesionadas,
        cantidadAtrapadas: _atrapadas,
        cantidadLesionadas: _lesionadas,
        cantidadAtrapadasDesconocida: _cantidadDesconocida,
        cantidadLesionadasDesconocida: _cantidadLesionadasDesconocida,
        alCambiarAtrapadas: (valor) => setState(() {
          _respuestaAtrapadas = valor;
          if (valor != 'Sí') {
            _atrapadas.clear();
            _cantidadDesconocida = false;
          }
        }),
        alCambiarLesionadas: (valor) => setState(() {
          _respuestaLesionadas = valor;
          if (valor != 'Sí') {
            _lesionadas.clear();
            _cantidadLesionadasDesconocida = false;
          }
        }),
        alCambiarDesconocidaAtrapadas: (valor) => setState(() {
          _cantidadDesconocida = valor;
          if (valor) _atrapadas.clear();
        }),
        alCambiarDesconocidaLesionadas: (valor) => setState(() {
          _cantidadLesionadasDesconocida = valor;
          if (valor) _lesionadas.clear();
        }),
        validarCantidadAtrapadas: (valor) {
          if (_respuestaAtrapadas != 'Sí' || _cantidadDesconocida) return null;
          final cantidad = int.tryParse(valor ?? '');
          return cantidad == null || cantidad <= 0
              ? 'Ingresa un número entero positivo mayor que cero.'
              : null;
        },
        validarCantidadLesionadas: (valor) {
          if (_respuestaLesionadas != 'Sí' || _cantidadLesionadasDesconocida) {
            return null;
          }
          final cantidad = int.tryParse(valor ?? '');
          return cantidad == null || cantidad <= 0
              ? 'Ingresa un número entero positivo mayor que cero.'
              : null;
        },
      ),
    );
  }
}
