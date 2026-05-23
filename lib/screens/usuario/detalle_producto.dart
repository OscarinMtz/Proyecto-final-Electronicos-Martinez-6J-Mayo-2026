import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../models/producto.dart';
import '../../providers/carrito_provider.dart';
import 'carrito_screen.dart';

class DetalleProducto extends StatefulWidget {
  final Producto producto;
  const DetalleProducto({super.key, required this.producto});
  @override
  State<DetalleProducto> createState() => _DetalleProductoState();
}

class _DetalleProductoState extends State<DetalleProducto> {
  int _cantidad = 1;

  @override
  Widget build(BuildContext context) {
    final carrito   = context.watch<CarritoProvider>();
    final producto  = widget.producto;
    final enCarrito = carrito.estaEnCarrito(producto.id);

    return Scaffold(
      backgroundColor: kBg,
      body: CustomScrollView(
        slivers: [

          // ── AppBar con imagen controlada ──────────
          SliverAppBar(
            expandedHeight: 280, // Un poco más compacto y estético
            pinned: true,
            backgroundColor: kPrimary,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.arrow_back,
                  color: Colors.white)),
            ),
            actions: [
              // Botón carrito
              Stack(alignment: Alignment.topRight, children: [
                GestureDetector(
                  onTap: () => Navigator.push(context,
                    MaterialPageRoute(
                      builder: (_) => const CarritoScreen())),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.shopping_cart_outlined,
                      color: Colors.white)),
                ),
                if (carrito.totalItems > 0)
                  Positioned(
                    top: 6, right: 6,
                    child: Container(
                      width: 16, height: 16,
                      decoration: const BoxDecoration(
                        color: kDanger,
                        shape: BoxShape.circle),
                      child: Center(
                        child: Text('${carrito.totalItems}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700))))),
              ]),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                // Fondo limpio y premium para enmarcar el producto electrónico
                decoration: BoxDecoration(
                  color: Colors.white,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.grey.withOpacity(0.05),
                      Colors.white,
                    ],
                  ),
                ),
                padding: const EdgeInsets.only(top: kToolbarHeight + 10, bottom: 20, left: 24, right: 24),
                child: producto.imagenUrl.isNotEmpty
                  ? Image.network(
                      producto.imagenUrl,
                      // ✨ CORRECCIÓN CRÍTICA: Se visualiza el producto completo sin cortes gigantescos
                      fit: BoxFit.contain, 
                      errorBuilder: (_, __, ___) => _placeholder())
                  : _placeholder(),
              ),
            ),
          ),

          // ── Contenido ─────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: kBg,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24))),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Categoría badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: kPrimaryLight,
                        borderRadius: BorderRadius.circular(6)),
                      child: Text(producto.nombreCategoria,
                        style: const TextStyle(
                          color: kPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600))),
                    const SizedBox(height: 10),

                    // Nombre y marca
                    Text(producto.nombre,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: kDark)),
                    const SizedBox(height: 4),
                    Text(producto.marca,
                      style: const TextStyle(
                        fontSize: 14, color: kSecondary)),
                    const SizedBox(height: 20),

                    // Precios
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: kCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: kBorder)),
                      child: Row(children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                              CrossAxisAlignment.start,
                            children: [
                              const Text('Precio base',
                                style: TextStyle(
                                  fontSize: 12, color: kSecondary)),
                              const SizedBox(height: 4),
                              Text(
                                '\$${producto.precioBase.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: kDark)),
                            ])),
                        Container(
                          width: 1, height: 40,
                          color: kBorder),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Column(
                              crossAxisAlignment:
                                CrossAxisAlignment.start,
                              children: [
                                const Text('Con IVA (8%)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: kSecondary)),
                                const SizedBox(height: 4),
                                Text(
                                  '\$${producto.precioConIva.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: kPrimary)),
                              ]))),
                      ]),
                    ),
                    const SizedBox(height: 20),

                    // Descripción
                    const Text('Descripción',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: kDark)),
                    const SizedBox(height: 8),
                    Text(
                      producto.descripcionGeneral.isNotEmpty
                        ? producto.descripcionGeneral
                        : 'Sin descripción disponible.',
                      style: const TextStyle(
                        fontSize: 14,
                        color: kSecondary,
                        height: 1.6)),
                    const SizedBox(height: 24),

                    // Selector de cantidad
                    const Text('Cantidad',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: kDark)),
                    const SizedBox(height: 10),
                    Row(children: [
                      _btnCantidad(
                        icon: Icons.remove,
                        onTap: () {
                          if (_cantidad > 1)
                            setState(() => _cantidad--);
                        }),
                      const SizedBox(width: 20),
                      Text('$_cantidad',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: kDark)),
                      const SizedBox(width: 20),
                      _btnCantidad(
                        icon: Icons.add,
                        onTap: () =>
                          setState(() => _cantidad++)),
                    ]),
                    const SizedBox(height: 12),

                    // Total estimado
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: kPrimaryLight,
                        borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total estimado (c/IVA)',
                            style: TextStyle(
                              fontSize: 13,
                              color: kPrimary,
                              fontWeight: FontWeight.w500)),
                          Text(
                            '\$${(producto.precioConIva * _cantidad).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: kPrimary)),
                        ])),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // ── Bottom bar ────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: kCard,
          boxShadow: kShadowLg),
        child: Row(children: [

          // Ver carrito
          if (enCarrito)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(context,
                  MaterialPageRoute(
                    builder: (_) => const CarritoScreen())),
                icon: const Icon(Icons.shopping_cart, size: 18),
                label: const Text('Ver carrito'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: kPrimary, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
              ),
            ),

          if (enCarrito) const SizedBox(width: 12),

          // Agregar al carrito
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () {
                for (var i = 0; i < _cantidad; i++) {
                  carrito.agregar(producto);
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '$_cantidad × ${producto.nombre} agregado al carrito'),
                    action: SnackBarAction(
                      label: 'Ver carrito',
                      textColor: Colors.white,
                      onPressed: () => Navigator.push(context,
                        MaterialPageRoute(
                          builder: (_) => const CarritoScreen()))),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2)));
              },
              icon: Icon(
                enCarrito ? Icons.add_shopping_cart : Icons.shopping_cart,
                size: 18),
              label: Text(
                enCarrito ? 'Agregar más' : 'Agregar al carrito'),
              style: kPrimaryButton,
            ),
          ),
        ]),
      ),
    );
  }

  Widget _placeholder() {
    return const Center(
      child: Icon(Icons.devices,
        size: 70, color: kPrimary));
  }

  Widget _btnCantidad({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: kBorder, width: 1.5)),
        child: Icon(icon, size: 18, color: kDark)),
    );
  }
}