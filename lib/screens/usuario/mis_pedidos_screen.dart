import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants.dart';
import '../../models/carrito.dart';

class MisPedidosScreen extends StatelessWidget {
  const MisPedidosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Forzamos el email a minúsculas y limpiamos espacios vacíos para evitar fallas
    final email = (FirebaseAuth.instance.currentUser?.email ?? '').toLowerCase().trim();

    return Scaffold(
      backgroundColor: kBg,
      body: StreamBuilder<QuerySnapshot>(
        // ⚡ OPTIMIZADO: Eliminamos el .orderBy de la consulta de Firebase
        // Esto evita por completo el error de "Falta configurar un Índice"
        stream: FirebaseFirestore.instance
            .collection('pedidos')
            .where('email_cliente', isEqualTo: email)
            .snapshots(),
        builder: (context, snap) {
          // Si Firestore devuelve un error, se captura aquí
          if (snap.hasError) {
            debugPrint("❌ ERROR FIRESTORE: ${snap.error}");
            return _errorWidget(snap.error.toString());
          }

          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return _sinPedidos(context);
          }

          // 🛠️ ORDENAMIENTO MANUAL: Ordenamos los pedidos cronológicamente en Dart (de más reciente a más antiguo)
          final docs = snap.data!.docs.toList();
          docs.sort((a, b) {
            final dataA = a.data() as Map<String, dynamic>;
            final dataB = b.data() as Map<String, dynamic>;
            final fechaA = dataA['fecha_pedido'] as Timestamp?;
            final fechaB = dataB['fecha_pedido'] as Timestamp?;
            if (fechaA == null || fechaB == null) return 0;
            return fechaB.compareTo(fechaA); // Descendiente
          });

          // Mapeamos los documentos ya ordenados a nuestro modelo Pedido
          final pedidos = docs.map((d) =>
            Pedido.fromMap(d.id, d.data() as Map<String, dynamic>)).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pedidos.length,
            itemBuilder: (context, i) => _PedidoCard(pedido: pedidos[i]),
          );
        },
      ),
    );
  }

  Widget _sinPedidos(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100, height: 100,
            decoration: const BoxDecoration(
              color: kPrimaryLight,
              shape: BoxShape.circle),
            child: const Icon(Icons.receipt_long_outlined,
              size: 48, color: kPrimary)),
          const SizedBox(height: 20),
          const Text('Sin pedidos aún',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: kDark)),
          const SizedBox(height: 8),
          const Text('Tus compras aparecerán aquí',
            style: TextStyle(fontSize: 14, color: kSecondary)),
        ],
      ),
    );
  }

  Widget _errorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: kDanger),
            const SizedBox(height: 14),
            const Text(
              'Error al cargar los datos',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kDark),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: kSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════
// CARD DE PEDIDO
// ═══════════════════════════════════════
class _PedidoCard extends StatelessWidget {
  final Pedido pedido;
  const _PedidoCard({required this.pedido});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
        boxShadow: kShadowSm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Header ──────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            decoration: const BoxDecoration(
              color: kBg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
              border: Border(bottom: BorderSide(color: kBorder))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pedido.id.length > 8 
                          ? 'Pedido #${pedido.id.substring(0, 8).toUpperCase()}'
                          : 'Pedido #${pedido.id.toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: kDark)),
                    const SizedBox(height: 2),
                    Text(
                      _formatFecha(pedido.fechaPedido),
                      style: const TextStyle(
                        fontSize: 11, color: kSecondary)),
                  ]),
                _EstadoBadge(estado: pedido.estado),
              ],
            ),
          ),

          // ── Items del pedido ─────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...pedido.items.take(3).map((item) => _ItemRow(item: item)),

                // Si hay más de 3 items muestra el indicador recursivo
                if (pedido.items.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '+${pedido.items.length - 3} productos más',
                      style: const TextStyle(
                        fontSize: 12,
                        color: kSecondary,
                        fontStyle: FontStyle.italic))),

                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // Totales del Pedido
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Subtotal: \$${pedido.subtotal.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 12, color: kSecondary)),
                        Text('IVA (8%): \$${pedido.iva.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 12, color: kSecondary)),
                      ]),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Total pagado',
                          style: TextStyle(fontSize: 11, color: kSecondary)),
                        Text(
                          '\$${pedido.total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: kPrimary)),
                      ]),
                  ],
                ),

                const SizedBox(height: 12),

                // Método de pago usado
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: kBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: kBorder)),
                  child: Row(children: [
                    const Icon(Icons.credit_card, size: 16, color: kSecondary),
                    const SizedBox(width: 8),
                    Text(
                      '${pedido.metodoPago} •••• ${pedido.ultimos4}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: kSecondary,
                        fontWeight: FontWeight.w500)),
                  ])),

                // Botón ver detalle
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _verDetalle(context),
                    icon: const Icon(Icons.receipt_outlined, size: 16),
                    label: const Text('Ver detalle completo'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kPrimary,
                      side: const BorderSide(color: kBorder),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _verDetalle(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DetallePedidoSheet(pedido: pedido),
    );
  }

  String _formatFecha(DateTime fecha) {
    final meses = ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'];
    return '${fecha.day} ${meses[fecha.month - 1]} ${fecha.year} '
           '${fecha.hour.toString().padLeft(2,'0')}:${fecha.minute.toString().padLeft(2,'0')}';
  }
}

// ═══════════════════════════════════════
// FILA DE ITEM (PRODUCTOS INDIVIDUALES)
// ═══════════════════════════════════════
class _ItemRow extends StatelessWidget {
  final Map<String, dynamic> item;
  const _ItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          // Resguarda que use indistintamente 'imagen_url' o 'imagenUrl'
          child: (item['imagen_url'] ?? item['imagenUrl'] ?? '').isNotEmpty
            ? Image.network(
                item['imagen_url'] ?? item['imagenUrl'],
                width: 44, height: 44,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder())
            : _placeholder()),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item['nombre'] ?? 'Producto',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: kDark)),
              Text('${item['marca'] ?? ''} · x${item['cantidad'] ?? 1}',
                style: const TextStyle(fontSize: 11, color: kSecondary)),
            ])),
        Text(
          '\$${((item['subtotal'] ?? 0) as num).toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: kDark)),
      ]),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 44, height: 44,
      color: kPrimaryLight,
      child: const Icon(Icons.devices, size: 22, color: kPrimary));
  }
}

// ═══════════════════════════════════════
// BADGE DE ESTADO DEL PEDIDO
// ═══════════════════════════════════════
class _EstadoBadge extends StatelessWidget {
  final String estado;
  const _EstadoBadge({required this.estado});

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    IconData icon;
    switch (estado) {
      case 'Pagado':
      case 'Reservado':
        bg = kSuccess.withOpacity(0.1);
        fg = kSuccess;
        icon = Icons.check_circle_outline;
        break;
      case 'Enviado':
        bg = kAccent.withOpacity(0.1);
        fg = kAccent;
        icon = Icons.local_shipping_outlined;
        break;
      case 'Cancelado':
        bg = kDanger.withOpacity(0.1);
        fg = kDanger;
        icon = Icons.cancel_outlined;
        break;
      default:
        bg = kWarning.withOpacity(0.1);
        fg = kWarning;
        icon = Icons.hourglass_empty;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: fg),
        const SizedBox(width: 4),
        Text(estado,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: fg)),
      ]));
  }
}

// ═══════════════════════════════════════
// BOTTOM SHEET DETALLE COMPLETO
// ═══════════════════════════════════════
class _DetallePedidoSheet extends StatelessWidget {
  final Pedido pedido;
  const _DetallePedidoSheet({required this.pedido});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: kBorder,
                borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),

          Text(
            pedido.id.length > 8 
                ? 'Pedido #${pedido.id.substring(0, 8).toUpperCase()}'
                : 'Pedido #${pedido.id.toUpperCase()}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: kDark)),
          const SizedBox(height: 4),
          _EstadoBadge(estado: pedido.estado),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.35),
            child: ListView(
              shrinkWrap: true,
              children: pedido.items.map((i) => _ItemRow(item: i)).toList())),

          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),

          _fila('Subtotal', '\$${pedido.subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 6),
          _fila('IVA (8%)', '\$${pedido.iva.toStringAsFixed(2)}', color: kSecondary),
          const SizedBox(height: 8),
          _fila('Total pagado', '\$${pedido.total.toStringAsFixed(2)}', grande: true),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kBorder)),
            child: Row(children: [
              const Icon(Icons.credit_card, size: 18, color: kSecondary),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pedido.metodoPago,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: kDark)),
                  Text('Terminada en ${pedido.ultimos4}',
                    style: const TextStyle(fontSize: 11, color: kSecondary)),
                ]),
            ])),
        ],
      ),
    );
  }

  Widget _fila(String label, String valor, {Color color = kDark, bool grande = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
          style: TextStyle(
            fontSize: grande ? 15 : 13,
            fontWeight: grande ? FontWeight.w700 : FontWeight.w400,
            color: grande ? kDark : kSecondary)),
        Text(valor,
          style: TextStyle(
            fontSize: grande ? 18 : 13,
            fontWeight: FontWeight.w700,
            color: grande ? kPrimary : color)),
      ]);
  }
}