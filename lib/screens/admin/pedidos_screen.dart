import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants.dart';

class PedidosAdminScreen extends StatefulWidget {
  const PedidosAdminScreen({super.key});
  @override
  State<PedidosAdminScreen> createState() => _PedidosAdminScreenState();
}

class _PedidosAdminScreenState extends State<PedidosAdminScreen> {
  String _filtroEstado = 'Todos';
  final _estados = ['Todos', 'Pendiente', 'Pagado', 'Enviado', 'Cancelado'];

  // Función de seguridad para transformar Strings o Números de Firestore a Double
  double _parsearPrecio(dynamic valor) {
    if (valor == null) return 0.00;
    if (valor is num) return valor.toDouble();
    return double.tryParse(valor.toString()) ?? 0.00;
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'Pagado':    return kSuccess;
      case 'Enviado':   return kAccent;
      case 'Cancelado': return kDanger;
      default:          return kWarning;
    }
  }

  IconData _iconEstado(String estado) {
    switch (estado) {
      case 'Pagado':    return Icons.check_circle_outline;
      case 'Enviado':   return Icons.local_shipping_outlined;
      case 'Cancelado': return Icons.cancel_outlined;
      default:          return Icons.hourglass_empty;
    }
  }

  void _cambiarEstado(BuildContext ctx, String id, String estadoActual) {
    String nuevoEstado = estadoActual;
    showDialog(
      context: ctx,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, ss) {
            return AlertDialog(
              title: const Text('Cambiar estado'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: _estados
                    .where((e) => e != 'Todos')
                    .map((e) {
                  final sel   = nuevoEstado == e;
                  final color = _colorEstado(e);
                  return GestureDetector(
                    onTap: () => ss(() => nuevoEstado = e),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: sel ? color.withOpacity(0.1) : kBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: sel ? color : kBorder,
                          width: 1.5)),
                      child: Row(children: [
                        Icon(_iconEstado(e),
                          size: 18,
                          color: sel ? color : kSecondary),
                        const SizedBox(width: 10),
                        Text(e,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: sel
                              ? FontWeight.w700 : FontWeight.w400,
                            color: sel ? color : kDark)),
                        const Spacer(),
                        if (sel)
                          Icon(Icons.check_circle,
                            size: 18, color: color),
                      ])));
                }).toList()),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar')),
                ElevatedButton(
                  style: kPrimaryButton,
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('pedidos')
                        .doc(id)
                        .update({'estado': nuevoEstado});
                    
                    if (!mounted) return;
                    
                    Navigator.pop(context);
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(
                        content: Text('Estado actualizado a $nuevoEstado'),
                        backgroundColor: _colorEstado(nuevoEstado)));
                  },
                  child: const Text('Guardar')),
              ]);
          });
      });
  }

  void _verDetalle(BuildContext ctx, Map<String, dynamic> d, String id) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.80,
          decoration: const BoxDecoration(
            color: kCard,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24))),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: kBorder,
                      borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pedido #${id.substring(0, 8).toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: kDark)),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: kSecondary)),
                  ])])),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _badgeEstado(d['estado'] ?? 'Pendiente'),
                        TextButton.icon(
                          onPressed: () => _cambiarEstado(
                            ctx, id, d['estado'] ?? 'Pendiente'),
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Cambiar estado')),
                      ]),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: kBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: kBorder)),
                      child: Row(children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: kPrimaryLight,
                          child: Text(
                            (d['nombre_cliente'] ?? 'C')[0].toUpperCase(),
                            style: const TextStyle(
                              color: kPrimary,
                              fontWeight: FontWeight.w700))),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(d['nombre_cliente'] ?? '',
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: kDark)),
                            Text(d['email_cliente'] ?? '',
                              style: const TextStyle(
                                  fontSize: 12, color: kSecondary)),
                          ]),
                      ])),
                    const SizedBox(height: 16),
                    const Text('Productos',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: kDark)),
                    const SizedBox(height: 10),
                    ...(List<Map<String, dynamic>>.from(
                        d['items'] ?? [])).map((item) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: kBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: kBorder)),
                        child: Row(children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: (item['imagen_url'] ?? '').isNotEmpty
                              ? Image.network(
                                  item['imagen_url'],
                                  width: 44, height: 44,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                    _miniPlaceholder())
                              : _miniPlaceholder()),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['nombre'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: kDark)),
                                Text(
                                  'x${item['cantidad']} · \$${_parsearPrecio(item['precio_base']).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 11, color: kSecondary)),
                              ])),
                          Text(
                            '\$${_parsearPrecio(item['subtotal']).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: kDark)),
                        ]));
                    }),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                    _filaTotales('Subtotal',
                      '\$${_parsearPrecio(d['subtotal']).toStringAsFixed(2)}'),
                    const SizedBox(height: 6),
                    _filaTotales('IVA (8%)',
                      '\$${_parsearPrecio(d['iva']).toStringAsFixed(2)}',
                      color: kSecondary),
                    const SizedBox(height: 8),
                    _filaTotales('Total',
                      '\$${_parsearPrecio(d['total_neto']).toStringAsFixed(2)}',
                      grande: true),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: kBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: kBorder)),
                      child: Row(children: [
                        const Icon(Icons.credit_card,
                          size: 18, color: kSecondary),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(d['metodo_pago'] ?? '',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: kDark)),
                            Text(
                              'Terminada en ${d['ultimos4'] ?? '****'}',
                              style: const TextStyle(
                                fontSize: 11, color: kSecondary)),
                          ]),
                      ])),
                  ],
                ),
              ),
            ),
          ]),
        );
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Column(children: [
        Container(
          color: kCard,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _estados.map((e) {
                final sel   = _filtroEstado == e;
                final color = e == 'Todos' ? kPrimary : _colorEstado(e);
                return GestureDetector(
                  onTap: () => setState(() => _filtroEstado = e),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? color : kBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: sel ? color : kBorder, width: 1.5)),
                    child: Text(e,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: sel ? Colors.white : kSecondary))));
              }).toList()))),
        const Divider(height: 1),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('pedidos')
                .orderBy('fecha_pedido', descending: true)
                .snapshots(),
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              var docs = snap.data!.docs;
              if (_filtroEstado != 'Todos') {
                docs = docs.where((d) {
                  final data = d.data() as Map<String, dynamic>;
                  return data['estado'] == _filtroEstado;
                }).toList();
              }
              if (docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.receipt_long,
                        size: 56, color: kMuted),
                      const SizedBox(height: 12),
                      Text(
                        _filtroEstado == 'Todos'
                          ? 'Sin pedidos aún'
                          : 'Sin pedidos $_filtroEstado',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: kSecondary)),
                    ]));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                itemBuilder: (context, i) {
                  final d     = docs[i].data() as Map<String, dynamic>;
                  final estado = d['estado'] ?? 'Pendiente';
                  final color  = _colorEstado(estado);
                  final items  = List.from(d['items'] ?? []);
                  return GestureDetector(
                    onTap: () => _verDetalle(context, d, docs[i].id),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: kCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: kBorder),
                        boxShadow: kShadowSm),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '#${docs[i].id.substring(0, 8).toUpperCase()}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: kDark)),
                                _badgeEstado(estado),
                              ]),
                            const SizedBox(height: 8),
                            Row(children: [
                              const Icon(Icons.person_outline,
                                size: 14, color: kSecondary),
                              const SizedBox(width: 4),
                              Text(d['nombre_cliente'] ?? '',
                                style: const TextStyle(
                                  fontSize: 13, color: kSecondary)),
                            ]),
                            const SizedBox(height: 4),
                            Text('${items.length} producto(s)',
                              style: const TextStyle(
                                fontSize: 12, color: kMuted)),
                            const SizedBox(height: 10),
                            const Divider(height: 1),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                  children: [
                                    const Text('Total',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: kSecondary)),
                                    Text(
                                      '\$${_parsearPrecio(d['total_neto']).toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: kPrimary)),
                                  ]),
                                OutlinedButton.icon(
                                  onPressed: () => _cambiarEstado(
                                    context, docs[i].id, estado),
                                  icon: Icon(Icons.swap_horiz,
                                    size: 14, color: color),
                                  label: const Text('Estado',
                                    style: TextStyle(fontSize: 12)),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: color,
                                    side: BorderSide(
                                      color: color, width: 1.5),
                                    padding:
                                      const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                        BorderRadius.circular(8)))),
                              ]),
                          ]))));
                });
            })),
      ]),
    );
  }

  Widget _badgeEstado(String estado) {
    final color = _colorEstado(estado);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(_iconEstado(estado), size: 13, color: color),
        const SizedBox(width: 4),
        Text(estado,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color)),
      ]));
  }

  Widget _filaTotales(String label, String valor, {Color color = kDark, bool grande = false}) {
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
      ],
    );
  }

  Widget _miniPlaceholder() {
    return Container(
      width: 44,
      height: 44,
      color: kPrimaryLight,
      child: const Icon(Icons.shopping_bag_outlined, size: 22, color: kPrimary),
    );
  }
}