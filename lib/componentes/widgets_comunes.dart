import 'package:flutter/material.dart';

import '../tema/colores_app.dart';

/// Etiqueta que indica para qué perfil es la pantalla.
class EtiquetaRol extends StatelessWidget {
  final String texto;
  final Color color;
  final Color colorClaro;

  const EtiquetaRol.central({super.key})
    : texto = 'CENTRAL · Radio-operador',
      color = ColoresApp.azul,
      colorClaro = ColoresApp.azulClaro;

  const EtiquetaRol.campo({super.key})
    : texto = 'CAMPO · Personal operativo',
      color = ColoresApp.verdeAzulado,
      colorClaro = ColoresApp.verdeAzuladoClaro;

  const EtiquetaRol.todos({super.key, this.texto = 'TODOS LOS USUARIOS'})
    : color = ColoresApp.pizarra,
      colorClaro = ColoresApp.pizarraClaro;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: colorClaro,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Text(
          texto,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}

/// Caja de aviso con fondo de color.
class CajaInfo extends StatelessWidget {
  final String texto;
  final Color fondo;
  final Color colorTexto;
  final TextAlign alineacion;

  const CajaInfo(
    this.texto, {
    super.key,
    required this.fondo,
    required this.colorTexto,
    this.alineacion = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        texto,
        textAlign: alineacion,
        style: TextStyle(fontSize: 13.5, color: colorTexto, height: 1.4),
      ),
    );
  }
}

/// Insignia de estado con el estilo ámbar compartido.
class ChipEstadoAmbar extends StatelessWidget {
  final String texto;
  final Color colorFondo;
  final double rellenoVertical;

  const ChipEstadoAmbar({
    super.key,
    required this.texto,
    required this.colorFondo,
    required this.rellenoVertical,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: rellenoVertical),
      decoration: BoxDecoration(
        color: colorFondo,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ColoresApp.ambar, width: 1.5),
      ),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: ColoresApp.ambarOscuro,
        ),
      ),
    );
  }
}

/// Botón grande de la app. Con [alPresionar] nulo se ve deshabilitado.
class BotonSire extends StatelessWidget {
  final String etiqueta;
  final String? subEtiqueta;
  final VoidCallback? alPresionar;
  final Color color;
  final bool conBorde;
  final double altura;
  final double tamanoFuente;

  const BotonSire({
    super.key,
    required this.etiqueta,
    this.subEtiqueta,
    this.alPresionar,
    this.color = ColoresApp.azulMarino,
    this.conBorde = false,
    this.altura = 58,
    this.tamanoFuente = 17,
  });

  @override
  Widget build(BuildContext context) {
    final textoEtiqueta = Text(
      etiqueta,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: tamanoFuente, fontWeight: FontWeight.bold),
    );

    return ElevatedButton(
      onPressed: alPresionar,
      style: ElevatedButton.styleFrom(
        backgroundColor: conBorde ? Colors.white : color,
        foregroundColor: conBorde ? color : Colors.white,
        disabledBackgroundColor: const Color(0xFFDDE3E6),
        disabledForegroundColor: const Color(0xFF8A979F),
        elevation: 0,
        minimumSize: Size.fromHeight(altura),
        side: conBorde ? BorderSide(color: color, width: 2) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: subEtiqueta == null
          ? textoEtiqueta
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                textoEtiqueta,
                const SizedBox(height: 6),
                Text(
                  subEtiqueta!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
    );
  }
}

/// Pestañas TIEMPOS / FORMULARIO de la pantalla de servicio.
class PestanasServicio extends StatelessWidget {
  final int indiceActivo;
  final ValueChanged<int> alSeleccionar;

  const PestanasServicio({
    super.key,
    required this.indiceActivo,
    required this.alSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    const etiquetas = ['TIEMPOS', 'FORMULARIO'];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: ColoresApp.linea, width: 2)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < etiquetas.length; i++)
            Expanded(
              child: InkWell(
                onTap: () => alSeleccionar(i),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: i == indiceActivo
                            ? ColoresApp.azulMarino
                            : Colors.transparent,
                        width: 4,
                      ),
                    ),
                  ),
                  child: Text(
                    etiquetas[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: i == indiceActivo
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: i == indiceActivo
                          ? ColoresApp.azulMarino
                          : ColoresApp.atenuado,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Chip compacto usado para identificar el perfil de un panel.
class ChipPanel extends StatelessWidget {
  final String texto;
  final Color colorTexto;
  final Color colorFondo;

  const ChipPanel({
    super.key,
    required this.texto,
    required this.colorTexto,
    required this.colorFondo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: colorFondo,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: colorTexto,
        ),
      ),
    );
  }
}

/// Pestañas inferiores para los paneles Central y Campo.
class PestanasInferioresPanel extends StatelessWidget {
  final String etiquetaActiva;
  final Color colorActivo;
  final VoidCallback alSincronizar;

  const PestanasInferioresPanel({
    super.key,
    required this.etiquetaActiva,
    required this.colorActivo,
    required this.alSincronizar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: ColoresApp.linea, width: 2)),
      ),
      child: Row(
        children: [
          _ItemPestanaPanel(
            etiqueta: etiquetaActiva,
            activo: true,
            colorActivo: colorActivo,
          ),
          _ItemPestanaPanel(
            etiqueta: 'Sincronizar',
            activo: false,
            colorActivo: colorActivo,
            alTocar: alSincronizar,
          ),
        ],
      ),
    );
  }
}

class _ItemPestanaPanel extends StatelessWidget {
  final String etiqueta;
  final bool activo;
  final Color colorActivo;
  final VoidCallback? alTocar;

  const _ItemPestanaPanel({
    required this.etiqueta,
    required this.activo,
    required this.colorActivo,
    this.alTocar,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: alTocar,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: activo ? colorActivo : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            etiqueta,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: activo ? FontWeight.bold : FontWeight.normal,
              color: activo ? colorActivo : ColoresApp.atenuado,
            ),
          ),
        ),
      ),
    );
  }
}
