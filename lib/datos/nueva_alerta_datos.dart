part of '../pantallas/pantalla_nueva_alerta.dart';

final List<String> _unidadesDisponibles = const [
  'BYP00',
  'BYP01',
  'BYP02',
  'BYP03',
  'BYP04',
  'BYP05',
  'BYP06',
];

const List<String> _rangosApoyo = [
  'Bombero',
  'Aspirante',
  'Cadete',
  'Radio Operador',
];

final Map<String, String> _etiquetasTipoSolicitante = const {
  'C4 (Central)': 'C4',
  'Elemento BYP': 'Elemento BYP',
  'Persona (Civil)': 'Reporte directo',
  'Compañía de Gas (Convenio)': 'Compañía de Gas',
};

const Map<String, IconData> _iconosCategoria = {
  'INCENDIO': Icons.local_fire_department_outlined,
  'RESCATE': Icons.health_and_safety_outlined,
  'ACCIDENTES': Icons.directions_car_outlined,
  'MAT. PELIGROSO': Icons.science_outlined,
  'AGENTE PERTURBADOR': Icons.warning_amber_outlined,
  'SERVICIO ESPECIAL': Icons.miscellaneous_services_outlined,
};
