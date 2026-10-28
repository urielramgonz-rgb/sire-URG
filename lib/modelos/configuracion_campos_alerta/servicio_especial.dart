part of '../configuracion_campos_alerta.dart';

const Map<String, List<CampoAlerta>> _camposServicioEspecial = {
  'Interrupción de servicios': [
    CampoAlerta.seleccion('servicio', 'Servicio afectado', [
      'Electricidad',
      'Agua',
      'Gas',
      'Telecomunicaciones',
      'Otro',
    ]),
    CampoAlerta.texto('ubicacion', 'Ubicación afectada'),
    CampoAlerta.seleccion('alcance', 'Alcance', [
      'Vivienda',
      'Edificio',
      'Cuadra',
      'Colonia',
      'Zona amplia',
      'Desconocido',
    ]),
    CampoAlerta.siNo('riesgo', '¿Hay personas en riesgo inmediato?'),
    CampoAlerta.siNo('instalaciones', '¿Hay instalaciones críticas afectadas?'),
    CampoAlerta.texto(
      'riesgos',
      'Riesgos derivados reportados',
      largo: true,
      opcional: true,
    ),
    CampoAlerta.siNo('dependencia', '¿Se requiere apoyo de otra dependencia?'),
  ],
  'Concentración masiva': [
    CampoAlerta.seleccion('evento', 'Tipo de evento', [
      'Concierto',
      'Evento deportivo',
      'Feria',
      'Marcha',
      'Celebración',
      'Otro',
    ]),
    CampoAlerta.texto('nombre_evento', 'Nombre del evento', opcional: true),
    CampoAlerta.texto('lugar', 'Lugar'),
    CampoAlerta.cantidad(
      'asistencia',
      'Asistencia estimada',
      opcional: true,
      unidad: 'personas',
    ),
    CampoAlerta.fechaYHora(
      'fecha_horario',
      'Fecha y horario del evento',
      opcional: true,
    ),
    CampoAlerta.seleccion('apoyo', 'Tipo de apoyo solicitado', [
      'Prevención',
      'Cobertura de emergencia',
      'Atención médica',
      'Incendios',
      'Otro',
    ]),
    CampoAlerta.siNo('emergencia', '¿Hay una emergencia activa?'),
    CampoAlerta.texto(
      'observaciones_acceso',
      'Observaciones de acceso o concentración',
      largo: true,
      opcional: true,
    ),
  ],
  'Animales peligrosos': [
    CampoAlerta.texto('animal', 'Tipo de animal', permiteDesconocido: true),
    CampoAlerta.cantidad(
      'cantidad',
      'Número aproximado de animales',
      opcional: true,
      unidad: 'animales',
    ),
    CampoAlerta.texto('ubicacion', 'Ubicación'),
    CampoAlerta.seleccion('situacion', 'Situación', [
      'Animal suelto',
      'Animal atrapado',
      'Animal agresivo',
      'Animal en zona concurrida',
      'Otro',
    ]),
    CampoAlerta.siNo('lesionadas', '¿Hay personas lesionadas?'),
    CampoAlerta.siNo(
      'riesgo',
      '¿El animal representa un riesgo inmediato para personas?',
    ),
    CampoAlerta.siNo('apoyo', '¿Se requiere apoyo especializado?'),
  ],
  'Otro': [
    CampoAlerta.texto('tipo_servicio', 'Tipo de servicio solicitado'),
    CampoAlerta.texto('motivo', 'Motivo de la solicitud', largo: true),
    CampoAlerta.texto('ubicacion', 'Ubicación'),
    CampoAlerta.fechaYHora(
      'fecha_hora',
      'Fecha y hora requeridas',
      opcional: true,
    ),
    CampoAlerta.texto('recursos', 'Recursos solicitados', opcional: true),
    CampoAlerta.seleccion('tipo_atencion', 'Tipo de atención', [
      'Preventivo',
      'Incidente activo',
      'Desconocido',
    ]),
    CampoAlerta.texto(
      'observaciones',
      'Observaciones',
      largo: true,
      opcional: true,
    ),
  ],
};
