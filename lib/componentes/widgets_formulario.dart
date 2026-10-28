import 'package:flutter/material.dart';

import '../tema/colores_app.dart';

/// Título de sección en mayúsculas pequeñas (ej. "SERVICIOS ACTIVOS").
class EtiquetaSeccion extends StatelessWidget {
  final String texto;

  const EtiquetaSeccion(this.texto, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: ColoresApp.atenuado,
        letterSpacing: .5,
      ),
    );
  }
}

/// Etiqueta que va arriba de un campo o grupo de opciones.
class EtiquetaCampo extends StatelessWidget {
  final String texto;

  const EtiquetaCampo(this.texto, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: ColoresApp.atenuado,
      ),
    );
  }
}

/// Campo de texto con valor de ejemplo. [etiqueta] muestra una etiqueta azul al final.
class CampoTextoSire extends StatelessWidget {
  final String valorInicial;
  final bool ocultarTexto;
  final String? etiqueta;

  const CampoTextoSire({
    super.key,
    required this.valorInicial,
    this.ocultarTexto = false,
    this.etiqueta,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: valorInicial,
      obscureText: ocultarTexto,
      style: const TextStyle(fontSize: 18, color: ColoresApp.tinta),
      decoration: InputDecoration(
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        suffix: etiqueta == null
            ? null
            : Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: ColoresApp.azulClaro,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  etiqueta!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: ColoresApp.azul,
                  ),
                ),
              ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: ColoresApp.linea, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: ColoresApp.azulMarino, width: 2),
        ),
      ),
    );
  }
}

/// Opción tipo "chip" (seleccionada o no). Sólo visual.
class ChipOpcion extends StatelessWidget {
  final String etiqueta;
  final bool seleccionado;
  final Color colorSeleccionado;

  const ChipOpcion(
    this.etiqueta, {
    super.key,
    this.seleccionado = false,
    this.colorSeleccionado = ColoresApp.azulMarino,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
      decoration: BoxDecoration(
        color: seleccionado ? colorSeleccionado : Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: seleccionado ? colorSeleccionado : ColoresApp.linea,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (seleccionado) const Icon(Icons.check, size: 18, color: Colors.white),
          if (seleccionado) const SizedBox(width: 6),
          Text(
            etiqueta,
            style: TextStyle(
              fontSize: 16,
              fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
              color: seleccionado ? Colors.white : ColoresApp.tinta,
            ),
          ),
        ],
      ),
    );
  }
}