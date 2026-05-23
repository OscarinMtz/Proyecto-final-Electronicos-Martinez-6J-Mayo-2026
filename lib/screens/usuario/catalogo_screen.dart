import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../models/producto.dart';
import '../../models/categoria.dart';
import '../../providers/carrito_provider.dart';
import 'detalle_producto.dart';

class CatalogoScreen extends StatefulWidget {
  const CatalogoScreen({super.key});
  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  String _categoriaSeleccionada = 'Todos';
  String _busqueda = '';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [

      // ── Barra de búsqueda ────────────
      Container(
        color: kCard,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: TextField(
          controller: _searchCtrl,
          onChanged: (v) => setState(() => _busqueda = v.toLowerCase()),
          decoration: kInputDecoration(
            'Buscar productos...',
            icon: Icons.search,
          ).copyWith(
            suffixIcon: _busqueda.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _busqueda = '');
                  })
              : null,
          ),
        ),
      ),

      // ── Chips de categorías ──────────
      Container(
        color: kCard,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('categorias').snapshots(),
          builder: (context, snap) {
            final cats = <Categoria>[];
            if (snap.hasData) {
              cats.addAll(snap.data!.docs
                  .map((d) => Categoria.fromDoc(d)));
            }
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                // Chip "Todos"
                _CategoriaChip(
                  label: 'Todos',
                  icono: Icons.apps,
                  seleccionado: _categoriaSeleccionada == 'Todos',
                  onTap: () => setState(() =>
                    _categoriaSeleccionada = 'Todos'),
                ),
                const SizedBox(width: 8),
                ...cats.map((c) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _CategoriaChip(
                    label: c.nombre,
                    icono: c.iconData,
                    seleccionado:
                      _categoriaSeleccionada == c.nombre,
                    onTap: () => setState(() =>
                      _categoriaSeleccionada = c.nombre),
                  ),
                )),
              ]),
            );
          },
        ),
      ),

      const Divider(height: 1),

      // ── Grid de productos ────────────
      Expanded(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('productos')
              .where('disponible', isEqualTo: true)
              .where('es_proximo', isEqualTo: false)
              .snapshots(),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Center(
                child: CircularProgressIndicator());
            }

            var productos = snap.data!.docs
                .map((d) => Producto.fromDoc(d))
                .toList();

            // Filtrar por categoría
            if (_categoriaSeleccionada != 'Todos') {
              productos = productos.where((p) =>
                p.nombreCategoria == _categoriaSeleccionada
              ).toList();
            }

            // Filtrar por búsqueda
            if (_busqueda.isNotEmpty) {
              productos = productos.where((p) =>
                p.nombre.toLowerCase().contains(_busqueda) ||
                p.marca.toLowerCase().contains(_busqueda)
              ).toList();
            }

            if (productos.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off,
                      size: 64, color: kMuted),
                    const SizedBox(height: 16),
                    const Text('Sin productos',
                      style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600,
                        color: kSecondary)),
                    const SizedBox(height: 8),
                    const Text('Intenta con otra categoría o búsqueda',
                      style: TextStyle(
                        fontSize: 13, color: kMuted)),
                  ],
                ),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  // ✨ CORRECCIÓN 1: Se incrementa el ratio para compactar verticalmente la tarjeta
                  childAspectRatio: 0.82,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16),
              itemCount: productos.length,
              itemBuilder: (context, i) =>
                _ProductoCard(producto: productos[i]),
            );
          },
        ),
      ),
    ]);
  }
}

// ═══════════════════════════════════════
// CHIP DE CATEGORÍA
// ═══════════════════════════════════════
class _CategoriaChip extends StatelessWidget {
  final String label;
  final IconData icono;
  final bool seleccionado;
  final VoidCallback onTap;

  const _CategoriaChip({
    required this.label,
    required this.icono,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: seleccionado ? kPrimary : kCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: seleccionado ? kPrimary : kBorder,
            width: 1.5),
          boxShadow: seleccionado ? kShadowSm : [],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icono,
            size: 16,
            color: seleccionado ? Colors.white : kSecondary),
          const SizedBox(width: 6),
          Text(label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: seleccionado ? Colors.white : kSecondary)),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════
// CARD DE PRODUCTO Rediseñada
// ═══════════════════════════════════════
class _ProductoCard extends StatelessWidget {
  final Producto producto;
  const _ProductoCard({required this.producto});

  @override
  Widget build(BuildContext context) {
    final carrito = context.watch<CarritoProvider>();
    final enCarrito = carrito.estaEnCarrito(producto.id);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetalleProducto(producto: producto))),
      child: Container(
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kBorder, width: 0.8),
          boxShadow: kShadowSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Contenedor de la Imagen
            Expanded(
              flex: 5,
              child: Stack(children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  // ✨ CORRECCIÓN 2: Fondo claro para enmarcar estéticamente el producto
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.03),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(14)),
                  ),
                  padding: const EdgeInsets.all(12), // Evita que la imagen toque los bordes
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: producto.imagenUrl.isNotEmpty
                      ? Image.network(
                          producto.imagenUrl,
                          // ✨ CORRECCIÓN 3: BoxFit.contain para que se visualice COMPLETO sin cortes feos
                          fit: BoxFit.contain, 
                          errorBuilder: (_, __, ___) =>
                            _placeholder())
                      : _placeholder(),
                  ),
                ),

                // Badge categoría
                Positioned(
                  top: 8, left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: kPrimary.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(6)),
                    child: Text(
                      producto.nombreCategoria,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600)))),
              ]),
            ),

            // Info del Producto
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(producto.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: kDark)),
                    const SizedBox(height: 2),
                    Text(producto.marca,
                      style: const TextStyle(
                        fontSize: 11, color: kSecondary)),
                    const Spacer(),

                    // Precio y Acciones
                    Row(
                      mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment:
                            CrossAxisAlignment.start,
                          children: [
                            Text(
                              '\$${producto.precioBase.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: kPrimary)),
                            Text(
                              'c/IVA \$${producto.precioConIva.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 9,
                                color: kMuted)),
                          ],
                        ),

                        // Botón agregar carrito
                        GestureDetector(
                          onTap: () {
                            carrito.agregar(producto);
                            ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(
                                content: Text(
                                  '${producto.nombre} agregado'),
                                duration: const Duration(
                                  seconds: 1),
                                behavior:
                                  SnackBarBehavior.floating));
                          },
                          child: AnimatedContainer(
                            duration:
                              const Duration(milliseconds: 200),
                            width: 32, height: 32,
                            decoration: BoxDecoration(
                              color: enCarrito
                                ? kSuccess : kPrimary,
                              borderRadius:
                                BorderRadius.circular(8)),
                            child: Icon(
                              enCarrito
                                ? Icons.check
                                : Icons.add,
                              color: Colors.white,
                              size: 16)),
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

  Widget _placeholder() {
    return Container(
      color: kPrimaryLight,
      child: const Center(
        child: Icon(Icons.devices,
          size: 36, color: kPrimary)));
  }
}