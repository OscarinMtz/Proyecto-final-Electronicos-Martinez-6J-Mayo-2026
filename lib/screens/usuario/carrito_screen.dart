import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/carrito_provider.dart';
import 'pago_screen.dart';

class CarritoScreen extends StatelessWidget {
  const CarritoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final carrito = context.watch<CarritoProvider>();

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: Text('Carrito (${carrito.totalItems})'),
        actions: [
          if (!carrito.vacio)
            TextButton.icon(
              onPressed: () => _confirmarVaciar(context, carrito),
              icon: const Icon(Icons.delete_outline,
                color: Colors.white, size: 18),
              label: const Text('Vaciar',
                style: TextStyle(color: Colors.white)),
            ),
        ],
      ),

      body: carrito.vacio
        ? _carritoVacio(context)
        : Column(children: [

            // ── Lista de items ───────────
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: carrito.items.length,
                itemBuilder: (context, i) {
                  final item = carrito.items[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: kCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: kBorder),
                      boxShadow: kShadowSm),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(children: [

                        // Imagen
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: item.producto.imagenUrl.isNotEmpty
                            ? Image.network(
                                item.producto.imagenUrl,
                                width: 70, height: 70,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                  _imgPlaceholder())
                            : _imgPlaceholder()),

                        const SizedBox(width: 12),

                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                              CrossAxisAlignment.start,
                            children: [
                              Text(item.producto.nombre,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: kDark)),
                              const SizedBox(height: 2),
                              Text(item.producto.marca,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: kSecondary)),
                              const SizedBox(height: 6),
                              Text(
                                '\$${item.producto.precioBase.toStringAsFixed(2)} c/u',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: kPrimary)),
                            ])),

                        // Controles cantidad
                        Column(
                          children: [
                            // Eliminar
                            GestureDetector(
                              onTap: () =>
                                carrito.eliminar(item.producto.id),
                              child: const Icon(Icons.close,
                                size: 18, color: kMuted)),
                            const SizedBox(height: 8),

                            // Contador
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: kBorder),
                                borderRadius:
                                  BorderRadius.circular(8)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _btnQ(
                                    icon: Icons.remove,
                                    onTap: () => carrito.quitar(
                                      item.producto.id)),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                    child: Text('${item.cantidad}',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight:
                                          FontWeight.w700,
                                        color: kDark))),
                                  _btnQ(
                                    icon: Icons.add,
                                    onTap: () => carrito.agregar(
                                      item.producto)),
                                ])),
                            const SizedBox(height: 8),

                            // Subtotal item
                            Text(
                              '\$${item.subtotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: kDark)),
                          ]),
                      ]),
                    ),
                  );
                },
              ),
            ),

            // ── Resumen de totales ───────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              decoration: BoxDecoration(
                color: kCard,
                boxShadow: kShadowLg,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20))),
              child: Column(children: [

                // Línea decorativa
                Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: kBorder,
                    borderRadius: BorderRadius.circular(2))),

                _filaTotal('Subtotal',
                  '\$${carrito.subtotal.toStringAsFixed(2)}'),
                const SizedBox(height: 8),
                _filaTotal('IVA (8%)',
                  '\$${carrito.iva.toStringAsFixed(2)}',
                  color: kSecondary),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider()),
                _filaTotal('Total',
                  '\$${carrito.total.toStringAsFixed(2)}',
                  grande: true),
                const SizedBox(height: 20),

                // Botón pagar
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PagoScreen())),
                    icon: const Icon(Icons.lock_outline, size: 20),
                    label: const Text('Proceder al pago',
                      style: TextStyle(fontSize: 16)),
                    style: kPrimaryButton,
                  ),
                ),

                const SizedBox(height: 12),

                // Seguir comprando
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Seguir comprando',
                      style: TextStyle(color: kSecondary)),
                  ),
                ),
              ]),
            ),
          ]),
    );
  }

  // ── Carrito vacío ──────────────────────
  Widget _carritoVacio(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              color: kPrimaryLight,
              shape: BoxShape.circle),
            child: const Icon(Icons.shopping_cart_outlined,
              size: 48, color: kPrimary)),
          const SizedBox(height: 20),
          const Text('Tu carrito está vacío',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: kDark)),
          const SizedBox(height: 8),
          const Text('Agrega productos desde el catálogo',
            style: TextStyle(fontSize: 14, color: kSecondary)),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.devices_outlined),
            label: const Text('Ver catálogo'),
            style: kPrimaryButton,
          ),
        ],
      ),
    );
  }

  Widget _imgPlaceholder() {
    return Container(
      width: 70, height: 70,
      color: kPrimaryLight,
      child: const Icon(Icons.devices,
        color: kPrimary, size: 32));
  }

  Widget _btnQ({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 16, color: kDark)));
  }

  Widget _filaTotal(
    String label,
    String valor, {
    Color color = kDark,
    bool grande = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
          style: TextStyle(
            fontSize: grande ? 16 : 14,
            fontWeight: grande
              ? FontWeight.w700 : FontWeight.w400,
            color: grande ? kDark : kSecondary)),
        Text(valor,
          style: TextStyle(
            fontSize: grande ? 20 : 14,
            fontWeight: FontWeight.w700,
            color: grande ? kPrimary : color)),
      ]);
  }

  void _confirmarVaciar(
    BuildContext context,
    CarritoProvider carrito,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Vaciar carrito'),
        content: const Text(
          '¿Eliminar todos los productos del carrito?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kDanger),
            onPressed: () {
              carrito.limpiar();
              Navigator.pop(context);
            },
            child: const Text('Vaciar')),
        ],
      ),
    );
  }
}