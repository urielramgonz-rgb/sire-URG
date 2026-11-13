import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tema/colores_app.dart';
import 'widgets_formulario.dart';

/// Sección reutilizable para capturar condiciones y cantidades de personas.
/// Cada bloque se puede habilitar por separado para adaptarlo a cada emergencia.
class SeccionInformacionPersonas extends StatelessWidget {
  const SeccionInformacionPersonas({
    super.key,
    required this.mostrarAtrapadas,
    required this.mostrarLesionadas,
    required this.respuestaAtrapadas,
    required this.respuestaLesionadas,
    required this.cantidadAtrapadas,
    required this.cantidadLesionadas,
    required this.cantidadAtrapadasDesconocida,
    required this.cantidadLesionadasDesconocida,
    required this.alCambiarAtrapadas,
    required this.alCambiarLesionadas,
    required this.alCambiarDesconocidaAtrapadas,
    required this.alCambiarDesconocidaLesionadas,
    required this.validarCantidadAtrapadas,
    required this.validarCantidadLesionadas,
  });

  final bool mostrarAtrapadas;
  final bool mostrarLesionadas;
  final String? respuestaAtrapadas;
  final String? respuestaLesionadas;
  final TextEditingController cantidadAtrapadas;
  final TextEditingController cantidadLesionadas;
  final bool cantidadAtrapadasDesconocida;
  final bool cantidadLesionadasDesconocida;
  final ValueChanged<String?> alCambiarAtrapadas;
  final ValueChanged<String?> alCambiarLesionadas;
  final ValueChanged<bool> alCambiarDesconocidaAtrapadas;
  final ValueChanged<bool> alCambiarDesconocidaLesionadas;
  final FormFieldValidator<String> validarCantidadAtrapadas;
  final FormFieldValidator<String> validarCantidadLesionadas;

  @override
  Widget build(BuildContext context) {
    if (!mostrarAtrapadas && !mostrarLesionadas) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 8, bottom: 10),
          child: Text(
            'INFORMACIÓN DE PERSONAS',
            style: TextStyle(
              color: ColoresApp.atenuado,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: .5,
            ),
          ),
        ),
        if (mostrarAtrapadas)
          _BloquePersonas(
            etiqueta: '¿Hay personas atrapadas?',
            etiquetaCantidad: 'Número aproximado de personas atrapadas',
            respuesta: respuestaAtrapadas,
            controlador: cantidadAtrapadas,
            cantidadDesconocida: cantidadAtrapadasDesconocida,
            alCambiarRespuesta: alCambiarAtrapadas,
            alCambiarCantidadDesconocida: alCambiarDesconocidaAtrapadas,
            validador: validarCantidadAtrapadas,
          ),
        if (mostrarLesionadas)
          _BloquePersonas(
            etiqueta: '¿Hay personas lesionadas?',
            etiquetaCantidad: 'Número aproximado de personas lesionadas',
            respuesta: respuestaLesionadas,
            controlador: cantidadLesionadas,
            cantidadDesconocida: cantidadLesionadasDesconocida,
            alCambiarRespuesta: alCambiarLesionadas,
            alCambiarCantidadDesconocida: alCambiarDesconocidaLesionadas,
            validador: validarCantidadLesionadas,
          ),
      ],
    );
  }
}

class _BloquePersonas extends StatelessWidget {
  const _BloquePersonas({
    required this.etiqueta,
    required this.etiquetaCantidad,
    required this.respuesta,
    required this.controlador,
    required this.cantidadDesconocida,
    required this.alCambiarRespuesta,
    required this.alCambiarCantidadDesconocida,
    required this.validador,
  });

  final String etiqueta;
  final String etiquetaCantidad;
  final String? respuesta;
  final TextEditingController controlador;
  final bool cantidadDesconocida;
  final ValueChanged<String?> alCambiarRespuesta;
  final ValueChanged<bool> alCambiarCantidadDesconocida;
  final FormFieldValidator<String> validador;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EtiquetaCampo(etiqueta),
          const SizedBox(height: 7),
          DropdownButtonFormField<String>(
            key: ValueKey('$etiqueta:respuesta'),
            initialValue: respuesta,
            decoration: _decoracion(),
            hint: const Text('Selecciona una opción'),
            items: const ['Sí', 'No', 'Desconocido']
                .map(
                  (opcion) =>
                      DropdownMenuItem(value: opcion, child: Text(opcion)),
                )
                .toList(),
            validator: (valor) =>
                valor == null ? 'Selecciona una opción.' : null,
            onChanged: alCambiarRespuesta,
          ),
          if (respuesta == 'Sí') ...[
            const SizedBox(height: 10),
            EtiquetaCampo(etiquetaCantidad),
            const SizedBox(height: 7),
            TextFormField(
              key: ValueKey('$etiqueta:cantidad'),
              controller: controlador,
              enabled: !cantidadDesconocida,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: false,
                signed: false,
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: validador,
              decoration: _decoracion().copyWith(
                hintText: 'Ingresa una cantidad entera positiva',
              ),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Cantidad desconocida'),
              value: cantidadDesconocida,
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (valor) =>
                  alCambiarCantidadDesconocida(valor ?? false),
            ),
          ],
        ],
      ),
    );
  }

  InputDecoration _decoracion() {
    return InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: ColoresApp.linea, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: ColoresApp.azulMarino, width: 2),
      ),
    );
  }
}
