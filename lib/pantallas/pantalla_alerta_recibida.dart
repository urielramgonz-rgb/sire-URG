import 'package:flutter/material.dart';

import '../tema/colores_app.dart';
import '../componentes/widgets_comunes.dart';
import '../componentes/barra_superior.dart';
import 'pantalla_tiempos.dart';

/// S5 · Alerta recibida (perfil Campo / personal operativo).
///
/// Sólo interfaz: "ACEPTAR E INICIAR SERVICIO" navega a S6.
class PantallaAlertaRecibida extends StatelessWidget {
  const PantallaAlertaRecibida({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const BarraSuperiorSire(titulo: 'Alerta asignada'),
            Container(
              width: double.infinity,
              color: ColoresApp.rojo,
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: const Text(
                'NUEVA ALERTA · PRIORIDAD ALTA',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const EtiquetaRol.campo(),
                    const SizedBox(height: 18),
                    const _CampoInfo('Servicio', 'Accidente vehicular'),
                    const _CampoInfo(
                      'Ubicación',
                      'Carretera SMA–Dolores, km 12',
                    ),
                    const _CampoInfo('Unidad asignada', 'A-03'),
                    const _CampoInfo('Hora de la alerta · Folio', '14:32 · 0154'),
                    const SizedBox(height: 12),
                    const CajaInfo(
                      'Datos enviados por la central',
                      fondo: ColoresApp.azulClaro,
                      colorTexto: ColoresApp.azul,
                      alineacion: TextAlign.center,
                    ),
                    const SizedBox(height: 22),
                    BotonSire(
                      etiqueta: 'ACEPTAR E INICIAR SERVICIO',
                      color: ColoresApp.verde,
                      alPresionar: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const PantallaTiempos(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    const Center(
                      child: Text(
                        'Se guarda la hora de aceptación',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: ColoresApp.atenuado,
                        ),
                      ),
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

class _CampoInfo extends StatelessWidget {
  final String etiqueta;
  final String valor;

  const _CampoInfo(this.etiqueta, this.valor);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          etiqueta,
          style: const TextStyle(fontSize: 14, color: ColoresApp.atenuado),
        ),
        const SizedBox(height: 2),
        Text(
          valor,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: ColoresApp.tinta,
          ),
        ),
        const Divider(color: ColoresApp.linea, height: 22, thickness: 1.5),
      ],
    );
  }
}