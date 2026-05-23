import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';
import 'categorias_screen.dart';
import 'productos_screen.dart';
import 'empleados_screen.dart';
import 'clientes_screen.dart';
import 'pedidos_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _idx = 0;

  final _screens = const [
    _AdminHomeScreen(),
    CategoriasAdminScreen(),
    ProductosAdminScreen(),
    EmpleadosAdminScreen(),
    ClientesAdminScreen(),
    PedidosAdminScreen(),
  ];

  final _items = const [
    _NavItem('Inicio',      Icons.dashboard_outlined,    Icons.dashboard),
    _NavItem('Categorías',  Icons.category_outlined,     Icons.category),
    _NavItem('Productos',   Icons.devices_outlined,      Icons.devices),
    _NavItem('Empleados',   Icons.badge_outlined,        Icons.badge),
    _NavItem('Clientes',    Icons.people_outlined,       Icons.people),
    _NavItem('Pedidos',     Icons.receipt_long_outlined, Icons.receipt_long),
  ];

  @override
  Widget build(BuildContext context) {
    final auth   = context.watch<AppAuthProvider>();
    final datos  = auth.datosUsuario ?? {};
    final nombre = datos['nombre'] ?? 'Admin';
    final rol    = datos['rol']    ?? 'Admin';

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: Row(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.bolt,
              color: Colors.white, size: 20)),
          const SizedBox(width: 10),
          const Text('ElectroAdmin'),
        ]),
        actions: [
          // Notificaciones stock bajo
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('inventario')
                .snapshots(),
            builder: (context, snap) {
              int alertas = 0;
              if (snap.hasData) {
                for (final doc in snap.data!.docs) {
                  final d = doc.data() as Map<String, dynamic>;
                  
                  // CORRECCIÓN: Parseo seguro de String a int para evitar el choque de tipos
                  final stockActualRaw = d['stock_actual'];
                  final actual = stockActualRaw is num 
                      ? stockActualRaw.toInt() 
                      : int.tryParse(stockActualRaw?.toString() ?? '0') ?? 0;

                  final stockMinimoRaw = d['stock_minimo'];
                  final minimo = stockMinimoRaw is num 
                      ? stockMinimoRaw.toInt() 
                      : int.tryParse(stockMinimoRaw?.toString() ?? '0') ?? 0;

                  if (actual < minimo) alertas++;
                }
              }
              return Stack(
                alignment: Alignment.topRight,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () => _mostrarAlertas(context),
                    tooltip: 'Alertas de stock'),
                  if (alertas > 0)
                    Positioned(
                      top: 6, right: 6,
                      child: Container(
                        width: 16, height: 16,
                        decoration: const BoxDecoration(
                          color: kDanger,
                          shape: BoxShape.circle),
                        child: Center(
                          child: Text('$alertas',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700))))),
                ]);
            },
          ),

          // Avatar admin
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => _mostrarPerfil(context, nombre, rol),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white.withOpacity(0.25),
                child: Text(
                  nombre.isNotEmpty
                    ? nombre[0].toUpperCase() : 'A',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700))),
            ),
          ),
        ],
      ),

      // Drawer
      drawer: NavigationDrawer(
        selectedIndex: _idx,
        onDestinationSelected: (i) {
          setState(() => _idx = i);
          Navigator.pop(context);
        },
        children: [
          // Header drawer
          Container(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1D4ED8), Color(0xFF2563EB)])),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white.withOpacity(0.25),
                  child: Text(
                    nombre.isNotEmpty
                      ? nombre[0].toUpperCase() : 'A',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white))),
                const SizedBox(height: 12),
                Text(nombre,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10)),
                  child: Text(rol,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w500))),
              ])),

          const SizedBox(height: 8),

          // Items navegación
          ..._items.asMap().entries.map((e) =>
            NavigationDrawerDestination(
              icon: Icon(e.value.icon),
              selectedIcon: Icon(e.value.iconSelected,
                color: kPrimary),
              label: Text(e.value.label))),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider()),

          // Cerrar sesión
          ListTile(
            leading: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: kDanger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.logout,
                size: 18, color: kDanger)),
            title: const Text('Cerrar sesión',
              style: TextStyle(
                color: kDanger,
                fontWeight: FontWeight.w500)),
            onTap: () {
              Navigator.pop(context);
              auth.logout(context);
            }),
          const SizedBox(height: 16),
        ],
      ),

      body: IndexedStack(index: _idx, children: _screens),
    );
  }

  void _mostrarAlertas(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20))),
        padding: const EdgeInsets.all(20),
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
            const Text('Alertas de stock bajo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: kDark)),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('inventario').snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) return const Center(
                  child: CircularProgressIndicator());
                final alertas = snap.data!.docs.where((d) {
                  final data = d.data() as Map<String, dynamic>;
                  
                  // CORRECCIÓN: Parseo seguro aquí también para la lista de alertas visuales
                  final stockActualRaw = data['stock_actual'];
                  final actual = stockActualRaw is num 
                      ? stockActualRaw.toInt() 
                      : int.tryParse(stockActualRaw?.toString() ?? '0') ?? 0;

                  final stockMinimoRaw = data['stock_minimo'];
                  final minimo = stockMinimoRaw is num 
                      ? stockMinimoRaw.toInt() 
                      : int.tryParse(stockMinimoRaw?.toString() ?? '0') ?? 0;

                  return actual < minimo;
                }).toList();
                if (alertas.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text('Sin alertas de stock 🎉',
                        style: TextStyle(color: kSecondary))));
                }
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: alertas.length,
                  itemBuilder: (_, i) {
                    final d = alertas[i].data()
                        as Map<String, dynamic>;
                    return ListTile(
                      leading: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: kDanger.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8)),
                        child: const Icon(
                          Icons.warning_amber_rounded,
                          color: kDanger, size: 18)),
                      title: Text(
                        d['id_variante'] ?? 'Producto',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13)),
                      subtitle: Text(
                        'Stock: ${d['stock_actual']} / Mínimo: ${d['stock_minimo']}',
                        style: const TextStyle(
                          fontSize: 12, color: kDanger)),
                    );
                  });
              }),
            const SizedBox(height: 16),
          ])));
  }

  void _mostrarPerfil(
    BuildContext context, String nombre, String rol) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Mi perfil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: kPrimaryLight,
              child: Text(
                nombre.isNotEmpty
                  ? nombre[0].toUpperCase() : 'A',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: kPrimary))),
            const SizedBox(height: 12),
            Text(nombre,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: kPrimaryLight,
                borderRadius: BorderRadius.circular(12)),
              child: Text(rol,
                style: const TextStyle(
                  color: kPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13))),
          ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar')),
        ],
      ));
  }
}

// ═══════════════════════════════════════
// HOME SCREEN ADMIN
// ═══════════════════════════════════════
class _AdminHomeScreen extends StatelessWidget {
  const _AdminHomeScreen();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Bienvenida
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1D4ED8), Color(0xFF2563EB)]),
              borderRadius: BorderRadius.circular(16),
              boxShadow: kShadowMd),
            child: Row(children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Panel de Control',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
                    const SizedBox(height: 4),
                    Text('Gestiona tu tienda en tiempo real',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.8))),
                  ])),
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.store,
                  color: Colors.white, size: 28)),
            ])),
          const SizedBox(height: 20),

          // Título estadísticas
          const Text('Estadísticas generales',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: kDark)),
          const SizedBox(height: 12),

          // Grid estadísticas
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: const [
              _StatCard('productos',   'Productos',
                Icons.devices,        kPrimary),
              _StatCard('categorias',  'Categorías',
                Icons.category,       kAccent),
              _StatCard('clientes',    'Clientes',
                Icons.people,         kSuccess),
              _StatCard('pedidos',     'Pedidos',
                Icons.receipt_long,   kWarning),
              _StatCard('empleados',   'Empleados',
                Icons.badge,          Color(0xFF7C3AED)),
              _StatCard('proveedores', 'Proveedores',
                Icons.local_shipping, kDanger),
            ]),
          const SizedBox(height: 20),

          // Últimos pedidos
          const Text('Últimos pedidos',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: kDark)),
          const SizedBox(height: 12),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('pedidos')
                .orderBy('fecha_pedido', descending: true)
                .limit(5)
                .snapshots(),
            builder: (context, snap) {
              if (!snap.hasData) return const Center(
                child: CircularProgressIndicator());
              final docs = snap.data!.docs;
              if (docs.isEmpty) return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kBorder)),
                child: const Center(
                  child: Text('Sin pedidos aún',
                    style: TextStyle(color: kSecondary))));
              return Column(
                children: docs.map((doc) {
                  final d = doc.data() as Map<String, dynamic>;
                  final estado = d['estado'] ?? 'Pendiente';
                  Color ec;
                  switch (estado) {
                    case 'Pagado':    ec = kSuccess; break;
                    case 'Enviado':   ec = kAccent;  break;
                    case 'Cancelado': ec = kDanger;  break;
                    default:          ec = kWarning;
                  }

                  // CORRECCIÓN: Parseo seguro de String a double para el total_neto del pedido
                  final totalNetoRaw = d['total_neto'];
                  final totalNeto = totalNetoRaw is num 
                      ? totalNetoRaw.toDouble() 
                      : double.tryParse(totalNetoRaw?.toString() ?? '0.0') ?? 0.0;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: kCard,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: kBorder)),
                    child: Row(children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: kPrimaryLight,
                          borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.receipt,
                          size: 18, color: kPrimary)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                            CrossAxisAlignment.start,
                          children: [
                            Text(
                              d['nombre_cliente'] ?? 'Cliente',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: kDark)),
                            Text(
                              '\$${totalNeto.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: kSecondary)),
                          ])),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: ec.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6)),
                        child: Text(estado,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: ec))),
                    ]));
                }).toList());
            }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════
// STAT CARD
// ═══════════════════════════════════════
class _StatCard extends StatelessWidget {
  final String collection;
  final String title;
  final IconData icon;
  final Color color;
  const _StatCard(
    this.collection, this.title, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(collection).snapshots(),
      builder: (context, snap) {
        final count = snap.data?.docs.length ?? 0;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: kCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kBorder),
            boxShadow: kShadowSm),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8)),
                    child: Icon(icon, color: color, size: 18)),
                  Text('$count',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: color)),
                ]),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: kSecondary))),
            ]),
        );
      },
    );
  }
}

// ═══════════════════════════════════════
// MODELO NAV ITEM
// ═══════════════════════════════════════
class _NavItem {
  final String label;
  final IconData icon;
  final IconData iconSelected;
  const _NavItem(this.label, this.icon, this.iconSelected);
}