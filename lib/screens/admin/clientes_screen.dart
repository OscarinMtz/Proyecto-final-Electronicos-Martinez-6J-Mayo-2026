import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants.dart';

class ClientesAdminScreen extends StatefulWidget {
  const ClientesAdminScreen({super.key});
  @override
  State<ClientesAdminScreen> createState() =>
      _ClientesAdminScreenState();
}

class _ClientesAdminScreenState extends State<ClientesAdminScreen> {
  String _busqueda = '';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _verDetalle(BuildContext ctx, Map<String, dynamic> d, String id) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(ctx).size.height * 0.75,
        decoration: const BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24))),
        child: Column(children: [
          // Handle
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Column(children: [
              Center(child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: kBorder,
                  borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Detalle del cliente',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: kDark)),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close,
                      color: kSecondary)),
                ]),
            ])),
          const Divider(),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Avatar y nombre
                  Center(
                    child: Column(children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: kPrimaryLight,
                        child: Text(
                          (d['nombre_completo'] ?? 'C')[0]
                            .toUpperCase(),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: kPrimary))),
                      const SizedBox(height: 12),
                      Text(d['nombre_completo'] ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: kDark)),
                      const SizedBox(height: 4),
                      Text(d['email'] ?? '',
                        style: const TextStyle(
                          fontSize: 13, color: kSecondary)),
                    ])),
                  const SizedBox(height: 24),

                  // Datos
                  _seccion('Información personal'),
                  _infoFila(Icons.phone_outlined,
                    'Teléfono',
                    d['telefono'] ?? 'Sin registrar'),
                  _infoFila(Icons.badge_outlined,
                    'RFC / DNI',
                    d['dni'] ?? 'Sin registrar'),
                  const SizedBox(height: 16),

                  // Pedidos del cliente
                  _seccion('Pedidos'),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('pedidos')
                        .where('email_cliente',
                          isEqualTo: d['email'])
                        .orderBy('fecha_pedido',
                          descending: true)
                        .snapshots(),
                    builder: (_, snap) {
                      if (!snap.hasData) return const Center(
                        child: CircularProgressIndicator());
                      final pedidos = snap.data!.docs;
                      if (pedidos.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: kBg,
                            borderRadius:
                              BorderRadius.circular(10),
                            border: Border.all(color: kBorder)),
                          child: const Center(
                            child: Text('Sin pedidos aún',
                              style: TextStyle(
                                color: kSecondary))));
                      }
                      final totalGastado = pedidos.fold<double>(
                        0, (s, p) {
                          final data = p.data()
                            as Map<String, dynamic>;
                          return s + ((data['total_neto'] as num?)
                            ?.toDouble() ?? 0);
                        });

                      return Column(children: [
                        // Resumen
                        Row(children: [
                          _miniStat('${pedidos.length}',
                            'Pedidos', kPrimary),
                          const SizedBox(width: 12),
                          _miniStat(
                            '\$${totalGastado.toStringAsFixed(0)}',
                            'Total gastado', kSuccess),
                        ]),
                        const SizedBox(height: 12),
                        // Lista pedidos
                        ...pedidos.take(3).map((p) {
                          final pd = p.data()
                            as Map<String, dynamic>;
                          final estado = pd['estado']
                            ?? 'Pendiente';
                          Color ec;
                          switch (estado) {
                            case 'Pagado':
                              ec = kSuccess; break;
                            case 'Enviado':
                              ec = kAccent; break;
                            case 'Cancelado':
                              ec = kDanger; break;
                            default:
                              ec = kWarning;
                          }
                          return Container(
                            margin: const EdgeInsets.only(
                              bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: kBg,
                              borderRadius:
                                BorderRadius.circular(10),
                              border: Border.all(
                                color: kBorder)),
                            child: Row(
                              mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Pedido #${p.id.substring(0, 8).toUpperCase()}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight:
                                          FontWeight.w600,
                                        color: kDark)),
                                    Text(
                                      '\$${(pd['total_neto'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: kSecondary)),
                                  ]),
                                Container(
                                  padding:
                                    const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4),
                                  decoration: BoxDecoration(
                                    color: ec.withOpacity(0.1),
                                    borderRadius:
                                      BorderRadius.circular(6)),
                                  child: Text(estado,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: ec))),
                              ]));
                        }).toList(), // Cierre del .map()
                      ]);
                    }), // Cierre del StreamBuilder
                ]), // Cierre de la Column de la sección de datos
            )), // Cierre de SingleChildScrollView y Expanded
        ])), // Cierre de la Column principal y del Container
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Column(children: [

        // Búsqueda
        Container(
          color: kCard,
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) =>
              setState(() => _busqueda = v.toLowerCase()),
            decoration: kInputDecoration(
              'Buscar por nombre o email...',
              icon: Icons.search).copyWith(
              suffixIcon: _busqueda.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      _searchCtrl.clear();
                      setState(() => _busqueda = '');
                    })
                : null)),
        ),
        const Divider(height: 1),

        // Lista
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('clientes').snapshots(),
            builder: (context, snap) {
              if (!snap.hasData) return const Center(
                child: CircularProgressIndicator());

              var docs = snap.data!.docs;

              if (_busqueda.isNotEmpty) {
                docs = docs.where((d) {
                  final data = d.data() as Map<String, dynamic>;
                  return (data['nombre_completo'] ?? '')
                      .toString().toLowerCase()
                      .contains(_busqueda) ||
                    (data['email'] ?? '')
                      .toString().toLowerCase()
                      .contains(_busqueda);
                }).toList();
              }

              if (docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          color: kPrimaryLight,
                          shape: BoxShape.circle),
                        child: const Icon(Icons.people_outline,
                          size: 40, color: kPrimary)),
                      const SizedBox(height: 16),
                      const Text('Sin clientes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: kDark)),
                      const SizedBox(height: 8),
                      const Text(
                        'Los clientes aparecen al registrarse',
                        style: TextStyle(color: kSecondary)),
                    ]));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                itemBuilder: (context, i) {
                  final d = docs[i].data()
                      as Map<String, dynamic>;
                  final nombre = d['nombre_completo'] ?? '';
                  final email  = d['email']           ?? '';
                  final tel    = d['telefono']        ?? '';
                  final inicial = nombre.isNotEmpty
                    ? nombre[0].toUpperCase() : 'C';

                  return GestureDetector(
                    onTap: () =>
                      _verDetalle(context, d, docs[i].id),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: kCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: kBorder),
                        boxShadow: kShadowSm),
                      child: ListTile(
                        contentPadding:
                          const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor: kPrimaryLight,
                          child: Text(inicial,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: kPrimary))),
                        title: Text(nombre,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: kDark)),
                        subtitle: Column(
                          crossAxisAlignment:
                            CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 2),
                            Text(email,
                              style: const TextStyle(
                                fontSize: 12,
                                color: kSecondary)),
                            if (tel.isNotEmpty)
                              Text(tel,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: kMuted)),
                          ]),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Contador pedidos
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('pedidos')
                                  .where('email_cliente',
                                    isEqualTo: email)
                                  .snapshots(),
                              builder: (_, s) {
                                final count =
                                  s.data?.docs.length ?? 0;
                                return Container(
                                  padding:
                                    const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4),
                                  decoration: BoxDecoration(
                                    color: kPrimaryLight,
                                    borderRadius:
                                      BorderRadius.circular(8)),
                                  child: Text(
                                    '$count pedidos',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: kPrimary)));
                              }),
                            const SizedBox(width: 4),
                            const Icon(Icons.chevron_right,
                              color: kMuted),
                          ]),
                      )));
                });
            })),
      ]),
    );
  }

  Widget _seccion(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(titulo,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: kDark)));
  }

  Widget _infoFila(IconData icon, String label, String valor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kBorder)),
      child: Row(children: [
        Icon(icon, size: 16, color: kSecondary),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
              style: const TextStyle(
                fontSize: 11, color: kMuted)),
            Text(valor,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: kDark)),
          ]),
      ]));
  }

  Widget _miniStat(String valor, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: color.withOpacity(0.2))),
        child: Column(children: [
          Text(valor,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color)),
          Text(label,
            style: const TextStyle(
              fontSize: 11, color: kSecondary)),
        ])));
  }
}