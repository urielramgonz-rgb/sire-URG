import 'package:flutter/material.dart';

import '../tema/colores_app.dart';
import '../componentes/widgets_comunes.dart';
import '../componentes/widgets_formulario.dart';
import '../componentes/barra_superior.dart';
import 'pantalla_panel_central.dart';
import 'pantalla_panel_campo.dart';

/// S8 · Reporte del servicio (Central y Campo).
///
/// Recibe [esCentral] para saber a qué panel regresar al enviar.
class PantallaReporte extends StatelessWidget {
  final bool esCentral;

  const PantallaReporte({super.key, this.esCentral = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const BarraSuperiorSire(titulo: 'Reporte · 0154', mostrarAtras: true),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const EtiquetaRol.todos(texto: 'CENTRAL Y CAMPO'),
                    const SizedBox(height: 16),
                    
                    // Se quitó el "const" aquí para evitar el error de compilación
                    _TarjetaReporte(), 
                    
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: BotonSire(
                            etiqueta: 'ENVIAR A CENTRAL',
                            tamanoFuente: 15,
                            alPresionar: () {
                              // Regresa al panel correspondiente según el rol
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (_) => esCentral 
                                      ? const PantallaPanelCentral() 
                                      : const PantallaPanelCampo(),
                                ),
                                (ruta) => ruta.isFirst,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: BotonSire(
                            etiqueta: 'PDF',
                            conBorde: true,
                            tamanoFuente: 15,
                            alPresionar: () {},
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaReporte extends StatelessWidget {
  const _TarjetaReporte();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: ColoresApp.linea, width: 2),
        borderRadius: BorderRadius.circular(14),
      ),
      // El contenido de esta columna sí puede ser const
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'REPORTE DE SERVICIO',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: ColoresApp.azulMarino,
            ),
          ),
          SizedBox(height: 2),
          Text(
            'Bomberos y Paramédicos SMA',
            style: TextStyle(fontSize: 13, color: ColoresApp.atenuado),
          ),
          SizedBox(height: 10),
          _InsigniaGenerada(),
          Divider(color: ColoresApp.linea, height: 26, thickness: 1.5),
          _CampoDato('Tipo', 'Accidente vehicular'),
          _CampoDato('Ubicación', 'Carretera SMA–Dolores, km 12'),
          _CampoDato('Unidad / apoyo', 'A-03 / B-01'),
          _CampoDato('Personal', 'Hernández, López'),
          SizedBox(height: 6),
          EtiquetaSeccion('CRONOLOGÍA'),
          SizedBox(height: 8),
          _FilaHora('14:32', 'Alerta recibida', sombreado: true),
          _FilaHora('14:34', 'Salida de base'),
          _FilaHora('14:47', 'Llegada al lugar', sombreado: true),
          _FilaHora('14:50', 'Inicio de atención'),
          _FilaHora('15:20', 'Salida / traslado', sombreado: true),
          _FilaHora('15:48', 'Fin del servicio'),
        ],
      ),
    );
  }
}

class _InsigniaGenerada extends StatelessWidget {
  const _InsigniaGenerada();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: ColoresApp.verdeClaro,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColoresApp.verde, width: 1.5),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 16, color: ColoresApp.verde),
          SizedBox(width: 6),
          Text(
            'GENERADO AUTOMÁTICAMENTE',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: ColoresApp.verde,
            ),
          ),
        ],
      ),
    );
  }
}

class _CampoDato extends StatelessWidget {
  final String etiqueta;
  final String valor;

  const _CampoDato(this.etiqueta, this.valor);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            etiqueta,
            style: const TextStyle(fontSize: 13, color: ColoresApp.atenuado),
          ),
          Text(
            valor,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: ColoresApp.tinta,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilaHora extends StatelessWidget {
  final String hora;
  final String texto;
  final bool sombreado;

  const _FilaHora(this.hora, this.texto, {this.sombreado = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: sombreado ? ColoresApp.fondo : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              hora,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: ColoresApp.tinta,
              ),
            ),
          ),
          Text(
            texto,
            style: const TextStyle(fontSize: 15, color: ColoresApp.tinta),
          ),
        ],
      ),
    );
  }
}