part 'configuracion_campos_alerta/incendio.dart';
part 'configuracion_campos_alerta/rescate.dart';
part 'configuracion_campos_alerta/accidentes.dart';
part 'configuracion_campos_alerta/material_peligroso.dart';
part 'configuracion_campos_alerta/agente_perturbador.dart';
part 'configuracion_campos_alerta/servicio_especial.dart';

/// Tipos de control usados en los formularios específicos de cada emergencia.
enum TipoCampoAlerta {
  textoCorto,
  textoLargo,
  seleccion,
  cantidad,
  seleccionMultipleLibre,
  hora,
  fechaYHora,
}

/// Definición declarativa de un campo de una subcategoría.
class CampoAlerta {
  const CampoAlerta._(
    this.id,
    this.etiqueta,
    this.tipo, {
    this.opciones = const [],
    this.obligatorio = true,
    this.permiteDesconocido = false,
    this.unidadFija,
    this.unidades,
    this.decimal = false,
  });

  const CampoAlerta.texto(
    String id,
    String etiqueta, {
    bool largo = false,
    bool opcional = false,
    bool permiteDesconocido = false,
  }) : this._(
         id,
         etiqueta,
         largo ? TipoCampoAlerta.textoLargo : TipoCampoAlerta.textoCorto,
         obligatorio: !opcional,
         permiteDesconocido: permiteDesconocido,
       );

  const CampoAlerta.seleccion(
    String id,
    String etiqueta,
    List<String> opciones, {
    bool opcional = false,
  }) : this._(
         id,
         etiqueta,
         TipoCampoAlerta.seleccion,
         opciones: opciones,
         obligatorio: !opcional,
       );

  const CampoAlerta.siNo(String id, String etiqueta, {bool opcional = false})
    : this._(
        id,
        etiqueta,
        TipoCampoAlerta.seleccion,
        opciones: const ['Sí', 'No', 'Desconocido'],
        obligatorio: !opcional,
      );

  const CampoAlerta.cantidad(
    String id,
    String etiqueta, {
    bool opcional = false,
    String? unidad,
    List<String>? unidades,
    bool decimal = false,
  }) : this._(
         id,
         etiqueta,
         TipoCampoAlerta.cantidad,
         obligatorio: !opcional,
         unidadFija: unidad,
         unidades: unidades,
         decimal: decimal,
       );

  const CampoAlerta.seleccionMultipleLibre(
    String id,
    String etiqueta, {
    bool opcional = false,
  }) : this._(
         id,
         etiqueta,
         TipoCampoAlerta.seleccionMultipleLibre,
         obligatorio: !opcional,
       );

  const CampoAlerta.hora(String id, String etiqueta, {bool opcional = false})
    : this._(id, etiqueta, TipoCampoAlerta.hora, obligatorio: !opcional);

  const CampoAlerta.fechaYHora(
    String id,
    String etiqueta, {
    bool opcional = false,
  }) : this._(id, etiqueta, TipoCampoAlerta.fechaYHora, obligatorio: !opcional);

  final String id;
  final String etiqueta;
  final TipoCampoAlerta tipo;
  final List<String> opciones;
  final bool obligatorio;
  final bool permiteDesconocido;
  final String? unidadFija;
  final List<String>? unidades;
  final bool decimal;
}

/// Catálogo explícito de subcategorías y campos para las 41 combinaciones.
class ConfiguracionCamposAlerta {
  ConfiguracionCamposAlerta._();

  static const Map<String, Map<String, List<CampoAlerta>>> porCategoria = {
    'INCENDIO': _camposIncendio,
    'RESCATE': _camposRescate,
    'ACCIDENTES': _camposAccidentes,
    'MAT. PELIGROSO': _camposMaterialPeligroso,
    'AGENTE PERTURBADOR': _camposAgentePerturbador,
    'SERVICIO ESPECIAL': _camposServicioEspecial,
  };
}
