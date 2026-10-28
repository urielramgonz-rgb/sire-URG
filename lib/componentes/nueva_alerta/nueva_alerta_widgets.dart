part of '../../pantallas/pantalla_nueva_alerta.dart';

class _IndicadorProgreso extends StatelessWidget {
  const _IndicadorProgreso({required this.pasoActual, required this.titulos});

  final int pasoActual;
  final List<String> titulos;

  @override
  Widget build(BuildContext context) {
    final total = titulos.length;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'PASO ${pasoActual + 1} DE $total',
                style: const TextStyle(
                  color: ColoresApp.azulMarino,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: .5,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  titulos[pasoActual],
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ColoresApp.atenuado,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (pasoActual + 1) / total,
              minHeight: 7,
              backgroundColor: ColoresApp.fondo,
              color: ColoresApp.azulMarino,
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownSire<T> extends StatelessWidget {
  const _DropdownSire({
    required this.valor,
    required this.sugerencia,
    required this.opciones,
    required this.alCambiar,
    this.habilitado = true,
  });

  final T? valor;
  final String sugerencia;
  final List<MapEntry<T, String>> opciones;
  final ValueChanged<T?> alCambiar;
  final bool habilitado;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: habilitado ? Colors.white : ColoresApp.fondo,
        border: Border.all(color: ColoresApp.linea, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: valor,
          hint: Text(sugerencia),
          icon: const Icon(Icons.arrow_drop_down, color: ColoresApp.azulMarino),
          style: const TextStyle(fontSize: 17, color: ColoresApp.tinta),
          onChanged: habilitado ? alCambiar : null,
          items: opciones
              .map(
                (opcion) => DropdownMenuItem<T>(
                  value: opcion.key,
                  child: Text(opcion.value),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _TarjetaCategoria extends StatelessWidget {
  const _TarjetaCategoria({
    required this.titulo,
    required this.icono,
    required this.seleccionada,
    required this.alTocar,
  });

  final String titulo;
  final IconData icono;
  final bool seleccionada;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: alTocar,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(minHeight: 88),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: seleccionada ? ColoresApp.azulClaro : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: seleccionada ? ColoresApp.azulMarino : ColoresApp.linea,
              width: seleccionada ? 2 : 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(icono, color: ColoresApp.azulMarino, size: 26),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  titulo,
                  style: TextStyle(
                    color: ColoresApp.azulMarino,
                    fontSize: 12.5,
                    fontWeight: seleccionada
                        ? FontWeight.bold
                        : FontWeight.w600,
                  ),
                ),
              ),
              if (seleccionada)
                const Icon(
                  Icons.check_circle,
                  color: ColoresApp.azulMarino,
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TarjetaUnidadTripulacion extends StatelessWidget {
  const _TarjetaUnidadTripulacion({
    required this.unidad,
    required this.estado,
    required this.seleccionada,
    required this.activa,
    required this.alAbrir,
    required this.alAlternar,
  });

  final String unidad;
  final String estado;
  final bool seleccionada;
  final bool activa;
  final VoidCallback alAbrir;
  final VoidCallback alAlternar;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$unidad, $estado',
      selected: seleccionada,
      child: Container(
        constraints: const BoxConstraints(minHeight: 76),
        decoration: BoxDecoration(
          color: activa ? ColoresApp.azulClaro : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: activa ? ColoresApp.azulMarino : ColoresApp.linea,
            width: activa ? 2 : 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: alAbrir,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        unidad,
                        style: const TextStyle(
                          color: ColoresApp.azulMarino,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        estado,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: seleccionada && estado == 'Personal registrado'
                              ? ColoresApp.verde
                              : ColoresApp.atenuado,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Checkbox(
              value: seleccionada,
              onChanged: (_) => alAlternar(),
              activeColor: ColoresApp.rojo,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}

class _ResumenEmergencia extends StatelessWidget {
  const _ResumenEmergencia({required this.categoria, required this.subtipo});

  final String categoria;
  final String subtipo;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ChipOpcion(categoria, seleccionado: true),
        ChipOpcion(subtipo, colorSeleccionado: ColoresApp.azulMarino),
      ],
    );
  }
}

class _TarjetaResumenPaso extends StatelessWidget {
  const _TarjetaResumenPaso({required this.titulo, required this.datos});

  final String titulo;
  final List<MapEntry<String, String>> datos;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ColoresApp.fondo,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColoresApp.linea),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              color: ColoresApp.azulMarino,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < datos.length; i++) ...[
            if (i > 0) const Divider(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    datos[i].key,
                    style: const TextStyle(
                      color: ColoresApp.atenuado,
                      fontSize: 12.5,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: Text(
                    datos[i].value,
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      color: ColoresApp.tinta,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _NavegacionPasos extends StatelessWidget {
  const _NavegacionPasos({
    required this.puedeRetroceder,
    required this.esUltimoPaso,
    required this.alRetroceder,
    required this.alContinuar,
  });

  final bool puedeRetroceder;
  final bool esUltimoPaso;
  final VoidCallback alRetroceder;
  final VoidCallback alContinuar;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: ColoresApp.linea)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Row(
            children: [
              Expanded(
                child: BotonSire(
                  etiqueta: 'ANTERIOR',
                  color: ColoresApp.azulMarino,
                  conBorde: true,
                  altura: 52,
                  tamanoFuente: 14,
                  alPresionar: puedeRetroceder ? alRetroceder : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BotonSire(
                  etiqueta: esUltimoPaso
                      ? 'REGISTRAR Y VER BITÁCORA'
                      : 'CONTINUAR',
                  color: ColoresApp.rojo,
                  altura: 52,
                  tamanoFuente: esUltimoPaso ? 12.5 : 14,
                  alPresionar: alContinuar,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectorPrioridad extends StatelessWidget {
  const _SelectorPrioridad({
    required this.prioridadActual,
    required this.alSeleccionar,
  });

  final String prioridadActual;
  final ValueChanged<String> alSeleccionar;

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
                child: InkWell(
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
      case 'Baja':
        return ColoresApp.verde;
      case 'Media':
        return ColoresApp.ambar;
      case 'Alta':
        return ColoresApp.rojo;
      default:
        return Colors.white;
    }
  }
}
