import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../models/producto.dart';
import '../../providers/carrito_provider.dart';

class ProximosScreen extends StatefulWidget {
  const ProximosScreen({super.key});
  @override
  State<ProximosScreen> createState() => _ProximosScreenState();
}

class _ProximosScreenState extends State<ProximosScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Column(children: [
        // ── Header ──────────────────────
        Container(
          color: kCard,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Próximos lanzamientos',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: kDark)),
              const SizedBox(height: 4),
              const Text(
                'Reserva antes de que salgan al mercado',
                style: TextStyle(
                  fontSize: 13, color: kSecondary)),
              const SizedBox(height: 12),
              TabBar(
                controller: _tabCtrl,
                labelColor: kPrimary,
                unselectedLabelColor: kSecondary,
                indicatorColor: kPrimary,
                indicatorWeight: 3,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 14),
                tabs: const [
                  Tab(text: 'Próximos'),
                  Tab(text: 'Mis reservas'),
                ]),
            ]),
        ),

        // ── Tabs ────────────────────────
        Expanded(
          child: TabBarView(
            controller: _tabCtrl,
            children: const [
              _ProximosTab(),
              _MisReservasTab(),
            ]),
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════
// TAB PRÓXIMOS
// ═══════════════════════════════════════
class _ProximosTab extends StatelessWidget {
  const _ProximosTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('productos')
          .where('es_proximo', isEqualTo: true)
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snap.hasData || snap.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90, height: 90,
                  decoration: const BoxDecoration(
                    color: kPrimaryLight,
                    shape: BoxShape.circle),
                  child: const Icon(Icons.new_releases_outlined,
                    size: 44, color: kPrimary)),
                const SizedBox(height: 16),
                const Text('Sin lanzamientos próximos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: kDark)),
                const SizedBox(height: 8),
                const Text('Vuelve pronto para ver novedades',
                  style: TextStyle(
                    fontSize: 13, color: kSecondary)),
              ],
            ),
          );
        }

        final productos = snap.data!.docs
            .map((d) => Producto.fromDoc(d))
            .toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: productos.length,
          itemBuilder: (context, i) =>
            _ProximoCard(producto: productos[i]),
        );
      },
    );
  }
}

// ═══════════════════════════════════════
// CARD PRODUCTO PRÓXIMO
// ═══════════════════════════════════════
class _ProximoCard extends StatefulWidget {
  final Producto producto;
  const _ProximoCard({required this.producto});
  @override
  State<_ProximoCard> createState() => _ProximoCardState();
}

class _ProximoCardState extends State<_ProximoCard> {
  bool _reservando = false;
  bool _yaReservo  = false;

  @override
  void initState() {
    super.initState();
    _verificarReserva();
  }

  Future<void> _verificarReserva() async {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    final snap = await FirebaseFirestore.instance
        .collection('pedidos')
        .where('email_cliente', isEqualTo: email)
        .where('id_producto', isEqualTo: widget.producto.id)
        .where('estado', isEqualTo: 'Reservado')
        .get();
    if (mounted) setState(() => _yaReservo = snap.docs.isNotEmpty);
  }

  // 🔥 SOLUCIÓN DIRECTA: Obliga a escribir en Firestore al hacer clic
  Future<void> _reservar() async {
    setState(() => _reservando = true);
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    
    try {
      // 1. Intentamos llamar al proveedor por si maneja algo de stock local
      final carrito = context.read<CarritoProvider>();
      await carrito.reservar(widget.producto);

      // 2. FORZAMOS la creación del documento en la colección de 'pedidos'
      await FirebaseFirestore.instance.collection('pedidos').add({
        'email_cliente': email,
        'id_producto': widget.producto.id,
        'nombre_producto': widget.producto.nombre,
        'imagen_url': widget.producto.imagenUrl,
        'estado': 'Reservado',
        'fecha_reserva': Timestamp.now(),
      });

      if (mounted) {
        setState(() {
          _reservando = false;
          _yaReservo = true;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Reserva realizada para ${widget.producto.nombre}!'),
          backgroundColor: kSuccess,
          behavior: SnackBarBehavior.floating));
          
    } catch (e) {
      if (mounted) setState(() => _reservando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al reservar: $e'),
          backgroundColor: kDanger,
          behavior: SnackBarBehavior.floating));
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.producto;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
        boxShadow: kShadowMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(children: [
            Container(
              height: 180,
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.grey.withOpacity(0.03), Colors.white],
                ),
              ),
              child: p.imagenUrl.isNotEmpty
                ? Image.network(
                    p.imagenUrl,
                    fit: BoxFit.contain, 
                    errorBuilder: (_, __, ___) => _placeholder())
                : _placeholder(),
            ),

            // Badge PRÓXIMO
            Positioned(
              top: 12, left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFF2563EB)]),
                  borderRadius: BorderRadius.circular(20)),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.new_releases,
                      size: 12, color: Colors.white),
                    SizedBox(width: 4),
                    Text('PRÓXIMO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5)),
                  ]))),

            // Fecha lanzamiento
            if (p.fechaLanzamiento != null)
              Positioned(
                top: 12, right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_month,
                        size: 12, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(p.fechaLanzamiento!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500)),
                    ]))),
          ]),

          // Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Categoría
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: kPrimaryLight,
                    borderRadius: BorderRadius.circular(6)),
                  child: Text(p.nombreCategoria,
                    style: const TextStyle(
                      color: kPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600))),
                const SizedBox(height: 8),

                // Nombre y marca
                Text(p.nombre,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: kDark)),
                const SizedBox(height: 2),
                Text(p.marca,
                  style: const TextStyle(
                    fontSize: 13, color: kSecondary)),
                const SizedBox(height: 10),

                // Descripción
                if (p.descripcionGeneral.isNotEmpty)
                  Text(p.descripcionGeneral,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: kSecondary,
                      height: 1.5)),

                const SizedBox(height: 14),

                // Precio estimado
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Precio estimado',
                          style: TextStyle(
                            fontSize: 11, color: kMuted)),
                        Text(
                          p.precioBase > 0
                            ? '\$${p.precioBase.toStringAsFixed(2)}'
                            : 'Por anunciar',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: p.precioBase > 0
                              ? kPrimary : kSecondary)),
                      ]),

                    // Botón reservar
                    SizedBox(
                      width: 140,
                      child: ElevatedButton.icon(
                        onPressed: _yaReservo || _reservando
                          ? null : _reservar,
                        icon: _reservando
                          ? const SizedBox(
                              width: 14, height: 14,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2))
                          : Icon(
                              _yaReservo
                                ? Icons.check_circle
                                : Icons.bookmark_add_outlined,
                              size: 16),
                        label: Text(
                          _yaReservo ? 'Reservado' : 'Reservar',
                          style: const TextStyle(fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _yaReservo ? kSuccess : kPrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                      ),
                    ),
                  ]),
              ]),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return const Center(
      child: Icon(Icons.devices, size: 54, color: kPrimary));
  }
}

// ═══════════════════════════════════════
// TAB MIS RESERVAS
// ═══════════════════════════════════════
class _MisReservasTab extends StatelessWidget {
  const _MisReservasTab();

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('pedidos')
          .where('email_cliente', isEqualTo: email)
          .where('estado', isEqualTo: 'Reservado')
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snap.hasData || snap.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90, height: 90,
                  decoration: const BoxDecoration(
                    color: kPrimaryLight,
                    shape: BoxShape.circle),
                  child: const Icon(Icons.bookmark_outline,
                    size: 44, color: kPrimary)),
                const SizedBox(height: 16),
                const Text('Sin reservas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: kDark)),
                const SizedBox(height: 8),
                const Text(
                  'Reserva productos próximos\npara ser el primero en tenerlos',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13, color: kSecondary)),
              ],
            ),
          );
        }

        final docs = snap.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final d = docs[i].data() as Map<String, dynamic>;
            
            final nombreProducto = d['nombre_producto'] ?? d['producto_nombre'] ?? 'Producto Reservado';
            final imagenUrl = d['imagen_url'] ?? d['producto_imagen'] ?? '';
            final estadoReserva = d['estado'] ?? 'Reservado';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: kBorder),
                boxShadow: kShadowSm),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: Container(
                  width: 56,
                  height: 56,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: kBorder.withOpacity(0.5)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: imagenUrl.isNotEmpty
                      ? Image.network(
                          imagenUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => _miniPlaceholder())
                      : _miniPlaceholder()),
                ),
                title: Text(nombreProducto,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14, color: kDark)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: kSuccess.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.bookmark,
                              size: 11, color: kSuccess),
                            const SizedBox(width: 4),
                            Text(estadoReserva,
                              style: const TextStyle(
                                color: kSuccess,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                          ])),
                    ]),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline,
                    color: kDanger, size: 20),
                  onPressed: () => _cancelarReserva(
                    context, docs[i].id, nombreProducto),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _miniPlaceholder() {
    return const Center(
      child: Icon(Icons.devices, size: 24, color: kPrimary));
  }

  void _cancelarReserva(BuildContext context, String id, String nombre) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancelar reserva'),
        content: Text('¿Cancelar la reserva de "$nombre"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kDanger),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('pedidos').doc(id).delete();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Reserva cancelada'),
                  backgroundColor: kDanger));
            },
            child: const Text('Cancelar reserva')),
        ],
      ),
    );
  }
}