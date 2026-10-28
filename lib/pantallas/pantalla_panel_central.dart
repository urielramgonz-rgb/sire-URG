import 'package:flutter/material.dart';

import '../tema/colores_app.dart';
import '../componentes/widgets_formulario.dart';
import '../componentes/barra_superior.dart';
import 'pantalla_nueva_alerta.dart';
import 'pantalla_sincronizacion.dart';
import 'pantalla_bitacora.dart';

/// S2 · Panel de servicios (Perfil Central / Radio-operador).
class PantallaPanelCentral extends StatelessWidget {
  const PantallaPanelCentral({super.key});

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
              titulo: 'Panel Central',
              widgetFinal: ChipConexion(enLinea: true),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text(
                    'Radio-operador · Central SMA',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: ColoresApp.tinta,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      EtiquetaSeccion('SERVICIOS ACTIVOS'),
                      _Chip(
                        texto: 'CENTRAL',
                        colorTexto: ColoresApp.azul,
                        colorFondo: ColoresApp.azulClaro,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Tarjeta de servicio activo (Click para ver bitácora)
                  GestureDetector(
                    onTap: () => _abrir(context, const PantallaBitacora()),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: ColoresApp.azul, width: 2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '0154 · Accidente vehicular',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: ColoresApp.tinta,
                                ),
                              ),
                              Icon(Icons.chevron_right, color: ColoresApp.atenuado),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Unidad A-03 en atención',
                            style: TextStyle(fontSize: 14, color: ColoresApp.atenuado),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Ver bitácora en tiempo real',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: ColoresApp.azul,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  const _FilaServicio(
                    punto: ColoresApp.azul,
                    titulo: '0153 · Traslado programado',
                    subtitulo: 'Unidad A-05 en camino',
                    colorSubtitulo: ColoresApp.azul,
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Botón exclusivo de la central
                  _BotonNuevaAlerta(
                    alPresionar: () => _abrir(context, const PantallaNuevaAlerta()),
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

// ... (Aquí reutilizamos los widgets _FilaServicio, _BotonNuevaAlerta, _Chip y _PestanasInferiores del archivo anterior)
// Los incluyo completos para que solo copies y pegues este archivo:

class _FilaServicio extends StatelessWidget {
  final Color? punto;
  final String titulo;
  final String subtitulo;
  final Color colorSubtitulo;

  const _FilaServicio({
    this.punto,
    required this.titulo,
    required this.subtitulo,
    required this.colorSubtitulo,
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
          if (punto != null)
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: punto, shape: BoxShape.circle),
            ),
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
                style: TextStyle(fontSize: 13, color: colorSubtitulo),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BotonNuevaAlerta extends StatelessWidget {
  final VoidCallback alPresionar;
  const _BotonNuevaAlerta({required this.alPresionar});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColoresApp.azul,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(64),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      onPressed: alPresionar,
      child: const Text(
        '+ NUEVA ALERTA',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
          const _ItemPestana(etiqueta: 'Servicios', activo: true),
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
                color: activo ? ColoresApp.azulMarino : Colors.transparent,
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
              color: activo ? ColoresApp.azulMarino : ColoresApp.atenuado,
            ),
          ),
        ),
      ),
    );
  }
}