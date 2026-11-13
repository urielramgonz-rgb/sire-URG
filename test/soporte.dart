// Datos y utilidades compartidas por las pruebas.

import 'package:sire/modelos/enums.dart';
import 'package:sire/modelos/reporte_servicio.dart';
import 'package:sire/modelos/usuario.dart';

/// Hora fija para que las pruebas no dependan del reloj real.
final DateTime horaBase = DateTime(2026, 11, 4, 10, 0);

const usuarioCampo = Usuario(
  id: 'T-CAMPO',
  nif: 'T-NIF-CAMPO',
  nombre: 'Campo Uno',
  rol: RolUsuario.campo,
  unidad: 'BYP01',
);

const usuarioOtraUnidad = Usuario(
  id: 'T-OTRA',
  nif: 'T-NIF-OTRA',
  nombre: 'Campo Dos',
  rol: RolUsuario.campo,
  unidad: 'BYP02',
);

const usuarioCentral = Usuario(
  id: 'T-CENTRAL',
  nif: 'T-NIF-CENTRAL',
  nombre: 'Central Uno',
  rol: RolUsuario.central,
);

const usuarioInactivo = Usuario(
  id: 'T-INACTIVO',
  nif: 'T-NIF-INACTIVO',
  nombre: 'Campo Inactivo',
  rol: RolUsuario.campo,
  unidad: 'BYP01',
  activo: false,
);

/// Cronología con los primeros [cuantas] tiempos registrados, uno por minuto
/// a partir de [horaBase].
List<EventoCronologia> cronologiaConMarcas(int cuantas) {
  final eventos = <EventoCronologia>[];
  var indice = 0;
  for (final estatus in EstatusServicio.values) {
    if (indice < cuantas) {
      eventos.add(
        EventoCronologia(
          estatus: estatus,
          marcadoEn: horaBase.add(Duration(minutes: indice)),
          detalle: 'prueba',
        ),
      );
    } else {
      eventos.add(EventoCronologia(estatus: estatus));
    }
    indice++;
  }
  return eventos;
}

/// Reporte mínimo y válido. Por defecto solo tiene registrado el envío.
ReporteServicio reportePrueba({
  String id = 't-1',
  String folio = '9001',
  List<String> unidades = const ['BYP01'],
  List<EventoCronologia>? cronologia,
}) {
  return ReporteServicio(
    id: id,
    folio: folio,
    categoria: 'INCENDIO',
    subcategoria: 'Pastizal',
    camposFormulario: const {},
    ubicacion: 'Camino de prueba',
    detallesUbicacion: const {},
    solicitante: 'C4 (Central)',
    datosSolicitante: const {},
    unidadesAsignadas: unidades,
    prioridad: PrioridadServicio.alta,
    personal: const [],
    apoyoExterno: 'No especificado',
    cronologia: cronologia ?? EventoCronologia.lineaInicial(horaBase),
  );
}
