import 'package:flutter/material.dart';

import '../tema/colores_app.dart';
import '../componentes/widgets_formulario.dart';
import '../componentes/barra_superior.dart';
import 'pantalla_alerta_recibida.dart';
import 'pantalla_sincronizacion.dart';

/// S2 · Panel de servicios (Perfil Campo / Bomberos y Paramédicos).
class PantallaPanelCampo extends StatelessWidget {
  const PantallaPanelCampo({super.key});

  void _abrir(BuildContext context, Widget pantalla) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => pantalla));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.fondo,
      body: SafeArea(
        child: Column(
          children: [
            const BarraSuperiorSire(
              titulo: 'Mi Panel',
              widgetFinal: ChipConexion(enLinea: true),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text(
                    'Prm. López · Unidad A-03',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ColoresApp.tinta,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Bomberos y Paramédicos SMA',
                    style: TextStyle(
                      fontSize: 14,
                      color: ColoresApp.atenuado,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      EtiquetaSeccion('SERVICIO ASIGNADO'),
                      _Chip(
                        texto: 'CAMPO',
                        colorTexto: ColoresApp.verdeAzulado,
                        colorFondo: ColoresApp.verdeAzuladoClaro,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Tarjeta de alerta asignada (Click para ir a S5)
                  GestureDetector(
                    onTap: () => _abrir(context, const PantallaAlertaRecibida()),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: ColoresApp.rojoClaro,
                        border: Border.all(color: ColoresApp.rojo, width: 2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Accidente vehicular',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: ColoresApp.tinta,
                                ),
                              ),
                              Icon(Icons.chevron_right, color: ColoresApp.rojo),
                            ],
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Carretera SMA–Dolores, km 12',
                            style: TextStyle(fontSize: 15, color: ColoresApp.tinta),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Toca aquí para aceptar el servicio',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: ColoresApp.rojo,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  const EtiquetaSeccion('HISTORIAL RECIENTE'),
                  const SizedBox(height: 10),
                  const _FilaHistorial(
                    titulo: '0152 · Incendio forestal',
                    subtitulo: 'Reporte enviado 09:12',
                  ),
                  const SizedBox(height: 10),
                  const _FilaHistorial(
                    titulo: '0151 · Urgencia médica',
                    subtitulo: 'Reporte enviado ayer',
                  ),
                ],
              ),
            ),
            _PestanasInferiores(
              alSincronizar: () => _abrir(context, const PantallaSincronizacion()),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilaHistorial extends StatelessWidget {
  final String titulo;
  final String subtitulo;

  const _FilaHistorial({
    required this.titulo,
    required this.subtitulo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: ColoresApp.verde, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: ColoresApp.tinta,
                ),
              ),
              Text(
                subtitulo,
                style: const TextStyle(fontSize: 13, color: ColoresApp.atenuado),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String texto;
  final Color colorTexto;
  final Color colorFondo;
  const _Chip({required this.texto, required this.colorTexto, required this.colorFondo});

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
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colorTexto),
      ),
    );
  }
}

class _PestanasInferiores extends StatelessWidget {
  final VoidCallback alSincronizar;
  const _PestanasInferiores({required this.alSincronizar});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: ColoresApp.linea, width: 2)),
      ),
      child: Row(
        children: [
          const _ItemPestana(etiqueta: 'Mi Servicio', activo: true),
          _ItemPestana(etiqueta: 'Sincronizar', activo: false, alTocar: alSincronizar),
        ],
      ),
    );
  }
}

class _ItemPestana extends StatelessWidget {
  final String etiqueta;
  final bool activo;
  final VoidCallback? alTocar;
  const _ItemPestana({required this.etiqueta, required this.activo, this.alTocar});

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
                color: activo ? ColoresApp.verdeAzulado : Colors.transparent,
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
              color: activo ? ColoresApp.verdeAzulado : ColoresApp.atenuado,
            ),
          ),
        ),
      ),
    );
  }
}