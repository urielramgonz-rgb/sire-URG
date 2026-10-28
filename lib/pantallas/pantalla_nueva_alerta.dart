import 'package:flutter/material.dart';

import '../tema/colores_app.dart';
import '../componentes/widgets_comunes.dart';
import '../componentes/widgets_formulario.dart';
import '../componentes/barra_superior.dart';
import 'pantalla_bitacora.dart';

/// S3 · Nueva alerta (perfil Central / radio-operador).
class PantallaNuevaAlerta extends StatefulWidget {
  const PantallaNuevaAlerta({super.key});

  @override
  State<PantallaNuevaAlerta> createState() => _PantallaNuevaAlertaState();
}

class _PantallaNuevaAlertaState extends State<PantallaNuevaAlerta> {
  // --- Lógica para las Unidades ---
  final List<String> _unidadesDisponibles = [
    'BYP00', 'BYP01', 'BYP02', 'BYP03', 'BYP04', 'BYP05', 'BYP06'
  ];
  final Set<String> _unidadesSeleccionadas = {'BYP01'};

  // --- Lógica para Prioridad ---
  String _prioridadSeleccionada = 'Alta';

  // --- Lógica para el Solicitante ---
  // CORREGIDO: El valor inicial debe coincidir exactamente con la lista
  String _tipoSolicitante = 'C4 (Central)'; 
  final List<String> _tiposSolicitante = [
    'C4 (Central)',
    'Elemento BYP',
    'Persona (Civil)',
    'Compañía de Gas (Convenio)',
  ];

  // Diccionario con la estructura de la Hoja de Servicio C4
  final Map<String, List<String>> _tiposServicio = {
    'INCENDIO': ['Industrial', 'Comercio', 'Casa habitación', 'Transporte', 'Pastizal', 'Agrícola', 'Basura', 'Bodega', 'Otro'],
    'RESCATE': ['Automovilístico', 'Montaña', 'Acuático', 'BREC', 'Zanjas', 'Cuevas', 'RIT', 'Otro'],
    'ACCIDENTES': ['Aéreos', 'Acuáticos', 'Ferroviarios', 'Terrestres (Choque)', 'Terrestres (Volcadura)', 'Salida de camino', 'Otro'],
    'MAT. PELIGROSO': ['Fuga', 'Derrame', 'Explosión', 'Incendio', 'Tóxico/Infeccioso', 'Radioactivo', 'Corrosivo'],
    'AGENTE PERTURBADOR': ['Sismo', 'Suelo inestable', 'Inundación', 'Tormentas', 'Cables', 'Enjambres'],
    'SERVICIO ESPECIAL': ['Interrupción de servicios', 'Concentración masiva', 'Animales peligrosos', 'Otro'],
  };

  String _categoriaSeleccionada = 'ACCIDENTES';
  String _subcategoriaSeleccionada = 'Terrestres (Choque)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const BarraSuperiorSire(titulo: 'Nueva alerta', mostrarAtras: true),
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const EtiquetaRol.central(),
                      const SizedBox(height: 20),

                      _tituloSeccion(Icons.confirmation_number_outlined, 'Datos del reporte'),
                      _campoConEtiqueta(
                        'Folio C4',
                        const CampoTextoSire(valorInicial: '0154'),
                      ),

                      const SizedBox(height: 12),
                      _tituloSeccion(Icons.person_outline, 'Datos del solicitante'),
                      _campoConEtiqueta(
                        '¿Quién reporta?',
                        _construirDropdownSolicitante(),
                      ),
                      _construirCamposSolicitante(),

                      const SizedBox(height: 12),
                      _tituloSeccion(Icons.local_fire_department_outlined, 'Tipo de servicio'),
                      _campoConEtiqueta('Categoría', _construirDropdownCategoria()),
                      _campoConEtiqueta('Subtipo', _construirDropdownSubcategoria()),

                      const SizedBox(height: 12),
                      _tituloSeccion(Icons.location_on_outlined, 'Ubicación del evento'),
                      _campoConEtiqueta(
                        'Colonia',
                        const CampoTextoSire(valorInicial: 'Insurgentes'),
                      ),
                      _campoConEtiqueta(
                        'Calle',
                        const CampoTextoSire(valorInicial: 'Fray Bernardo de Cossín'),
                      ),
                      _campoConEtiqueta(
                        'Número (exterior/interior)',
                        const CampoTextoSire(valorInicial: '133'),
                      ),
                      _campoConEtiqueta(
                        'Datos adicionales (referencias)',
                        const CampoTextoSire(
                          valorInicial: 'Portón blanco, frente a la plaza',
                        ),
                      ),

                      const SizedBox(height: 12),
                      _tituloSeccion(Icons.local_shipping_outlined, 'Despacho'),
                      const EtiquetaCampo('Unidades que responden'),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _unidadesDisponibles.map((unidad) {
                          final estaSeleccionada = _unidadesSeleccionadas.contains(unidad);
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (estaSeleccionada) {
                                  _unidadesSeleccionadas.remove(unidad);
                                } else {
                                  _unidadesSeleccionadas.add(unidad);
                                }
                              });
                            },
                            child: ChipOpcion(
                              unidad,
                              seleccionado: estaSeleccionada,
                              colorSeleccionado: ColoresApp.rojo,
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 20),
                      const EtiquetaCampo('Prioridad'),
                      const SizedBox(height: 10),
                      _SelectorPrioridad(
                        prioridadActual: _prioridadSeleccionada,
                        alSeleccionar: (nuevaPrioridad) {
                          setState(() {
                            _prioridadSeleccionada = nuevaPrioridad;
                          });
                        },
                      ),

                      const SizedBox(height: 28),
                      BotonSire(
                        etiqueta: 'ENVIAR ALERTA A LA UNIDAD',
                        color: ColoresApp.rojo,
                        alPresionar: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const PantallaBitacora(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      const Center(
                        child: Text(
                          'La unidad recibe los datos exactos al instante',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: ColoresApp.atenuado,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tituloSeccion(IconData icono, String titulo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: ColoresApp.azulClaro,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icono, size: 19, color: ColoresApp.azulMarino),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              titulo,
              style: const TextStyle(
                color: ColoresApp.azulMarino,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _campoConEtiqueta(
    String etiqueta,
    Widget campo, {
    bool requerido = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  etiqueta,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: ColoresApp.atenuado,
                  ),
                ),
              ),
              if (requerido)
                const Text(
                  'Obligatorio',
                  style: TextStyle(
                    color: ColoresApp.rojo,
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 7),
          campo,
        ],
      ),
    );
  }

  // --- WIDGETS DINÁMICOS DEL SOLICITANTE ---

  Widget _construirDropdownSolicitante() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: ColoresApp.azulMarino, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _tipoSolicitante,
          icon: const Icon(Icons.arrow_drop_down, color: ColoresApp.azulMarino),
          style: const TextStyle(fontSize: 17, color: ColoresApp.tinta, fontWeight: FontWeight.bold),
          onChanged: (String? nuevoValor) {
            if (nuevoValor != null) {
              setState(() {
                _tipoSolicitante = nuevoValor;
              });
            }
          },
          items: _tiposSolicitante.map((String tipo) {
            return DropdownMenuItem<String>(
              value: tipo,
              child: Text(tipo),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _construirCamposSolicitante() {
    if (_tipoSolicitante == 'C4 (Central)') {
      return Column(
        children: [
          _campoConEtiqueta(
            'Nombre del reportante (opcional)',
            const CampoTextoSire(valorInicial: 'Operador de turno'),
          ),
          _campoConEtiqueta(
            'Teléfono de contacto (opcional)',
            const CampoTextoSire(valorInicial: '415 000 0000'),
          ),
          const CajaInfo(
            'En reportes de C4 estos datos pueden no estar disponibles.',
            fondo: ColoresApp.ambarClaro,
            colorTexto: ColoresApp.ambarOscuro,
          ),
        ],
      );
    } else if (_tipoSolicitante == 'Elemento BYP' || _tipoSolicitante == 'Persona (Civil)') {
      return Column(
        children: [
          _campoConEtiqueta(
            'Nombre completo',
            const CampoTextoSire(valorInicial: 'Juan Pérez'),
            requerido: true,
          ),
          _campoConEtiqueta(
            'Teléfono',
            const CampoTextoSire(valorInicial: '415 123 4567'),
            requerido: true,
          ),
        ],
      );
    } else if (_tipoSolicitante == 'Compañía de Gas (Convenio)') {
      return Column(
        children: [
          _campoConEtiqueta(
            'Compañía',
            const CampoTextoSire(valorInicial: 'Gas del Centro'),
          ),
          _campoConEtiqueta(
            'Nombre de quien habla',
            const CampoTextoSire(valorInicial: 'Ing. Carlos Ruiz'),
          ),
          _campoConEtiqueta(
            'Nombre de quien reportó',
            const CampoTextoSire(valorInicial: 'María Gómez'),
          ),
          _campoConEtiqueta(
            'Teléfono de quien reportó',
            const CampoTextoSire(valorInicial: '415 888 9999'),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  // --- WIDGETS DEL SERVICIO ---

  Widget _construirDropdownCategoria() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: ColoresApp.linea, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _categoriaSeleccionada,
          icon: const Icon(Icons.arrow_drop_down, color: ColoresApp.azulMarino),
          style: const TextStyle(fontSize: 17, color: ColoresApp.tinta, fontWeight: FontWeight.bold),
          onChanged: (String? nuevoValor) {
            if (nuevoValor != null) {
              setState(() {
                _categoriaSeleccionada = nuevoValor;
                _subcategoriaSeleccionada = _tiposServicio[nuevoValor]!.first;
              });
            }
          },
          items: _tiposServicio.keys.map((String categoria) {
            return DropdownMenuItem<String>(
              value: categoria,
              child: Text(categoria),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _construirDropdownSubcategoria() {
    final subcategorias = _tiposServicio[_categoriaSeleccionada] ?? [];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: ColoresApp.fondo,
        border: Border.all(color: ColoresApp.linea, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _subcategoriaSeleccionada,
          icon: const Icon(Icons.arrow_drop_down, color: ColoresApp.azulMarino),
          style: const TextStyle(fontSize: 17, color: ColoresApp.tinta),
          onChanged: (String? nuevoValor) {
            if (nuevoValor != null) {
              setState(() {
                _subcategoriaSeleccionada = nuevoValor;
              });
            }
          },
          items: subcategorias.map((String subcategoria) {
            return DropdownMenuItem<String>(
              value: subcategoria,
              child: Text(subcategoria),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _SelectorPrioridad extends StatelessWidget {
  final String prioridadActual;
  final ValueChanged<String> alSeleccionar;

  const _SelectorPrioridad({
    required this.prioridadActual,
    required this.alSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    const opciones = ['Baja', 'Media', 'Alta'];

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: ColoresApp.linea, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            for (final opcion in opciones)
              Expanded(
                child: GestureDetector(
                  onTap: () => alSeleccionar(opcion),
                  child: Container(
                    height: 52,
                    alignment: Alignment.center,
                    color: _obtenerColorFondo(opcion),
                    child: Text(
                      opcion,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: opcion == prioridadActual
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: opcion == prioridadActual
                            ? Colors.white
                            : ColoresApp.tinta,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _obtenerColorFondo(String opcion) {
    if (opcion != prioridadActual) return Colors.white;
    
    switch (opcion) {
      case 'Baja': return ColoresApp.verde;
      case 'Media': return ColoresApp.ambar;
      case 'Alta': return ColoresApp.rojo;
      default: return Colors.white;
    }
  }
}
