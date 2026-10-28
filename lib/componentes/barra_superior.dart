import 'package:flutter/material.dart';

import '../tema/colores_app.dart';

/// Barra superior azul marino compartida por todas las pantallas.
class BarraSuperiorSire extends StatelessWidget {
  final String titulo;
  final bool mostrarAtras;
  final Widget? widgetFinal;

  const BarraSuperiorSire({
    super.key,
    required this.titulo,
    this.mostrarAtras = false,
    this.widgetFinal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 68, minWidth: double.infinity),
      color: ColoresApp.azulMarino,
      padding: EdgeInsets.fromLTRB(mostrarAtras ? 4 : 24, 10, 16, 10),
      child: Row(
        children: [
          if (mostrarAtras)
            IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(
                Icons.chevron_left,
                color: Colors.white,
                size: 34,
              ),
            ),
          Expanded(
            child: Text(
              titulo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ?widgetFinal,
        ],
      ),
    );
  }
}

/// Botón con borde blanco para la barra superior (ej. "Reporte").
class BotonBarraSuperior extends StatelessWidget {
  final String etiqueta;
  final VoidCallback alPresionar;

  const BotonBarraSuperior({super.key, required this.etiqueta, required this.alPresionar});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: alPresionar,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white, width: 2),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        minimumSize: const Size(0, 40),
      ),
      child: Text(
        etiqueta,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }
}

/// Indicador "En línea" / "Sin conexión".
class ChipConexion extends StatelessWidget {
  final bool enLinea;

  const ChipConexion({super.key, required this.enLinea});

  @override
  Widget build(BuildContext context) {
    final fondo = enLinea ? ColoresApp.verdeClaro : ColoresApp.ambarClaro;
    final texto = enLinea ? ColoresApp.verde : ColoresApp.ambarOscuro;
    final punto = enLinea ? ColoresApp.verde : ColoresApp.ambar;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: punto, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            enLinea ? 'En línea' : 'Sin conexión',
            style: TextStyle(
              color: texto,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}