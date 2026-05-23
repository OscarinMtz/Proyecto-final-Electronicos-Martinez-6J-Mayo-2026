import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/carrito_provider.dart';
import 'catalogo_screen.dart';
import 'carrito_screen.dart';
import 'mis_pedidos_screen.dart';
import 'proximos_screen.dart';
import 'perfil_screen.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});
  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int _idx = 0;

  final _screens = const [
    CatalogoScreen(),
    ProximosScreen(),
    MisPedidosScreen(),
    PerfilScreen(),
  ];

  final _labels = const [
    'Catálogo',
    'Próximos',
    'Mis Pedidos',
    'Perfil',
  ];

  final _icons = const [
    Icons.devices_outlined,
    Icons.new_releases_outlined,
    Icons.receipt_long_outlined,
    Icons.person_outline,
  ];

  final _iconsSelected = const [
    Icons.devices,
    Icons.new_releases,
    Icons.receipt_long,
    Icons.person,
  ];

  @override
  Widget build(BuildContext context) {
    final carrito = context.watch<CarritoProvider>();
    final auth    = context.watch<AppAuthProvider>();
    final datos   = auth.datosUsuario;
    final nombre  = datos?['nombre_completo'] ?? 'Usuario';

    return Scaffold(
      // ── AppBar ──────────────────────
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
          const Text('ElectroShop'),
        ]),
        actions: [
          // Carrito con badge
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                tooltip: 'Carrito',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CarritoScreen())),
              ),
              if (carrito.totalItems > 0)
                Positioned(
                  top: 6, right: 6,
                  child: Container(
                    width: 18, height: 18,
                    decoration: BoxDecoration(
                      color: kDanger,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: kPrimary, width: 1.5)),
                    child: Center(
                      child: Text(
                        '${carrito.totalItems}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700))))),
            ],
          ),

          // Avatar usuario
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _idx = 3),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white.withOpacity(0.25),
                child: Text(
                  nombre.isNotEmpty
                    ? nombre[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700))),
            ),
          ),

          // Cerrar sesión
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Cerrar sesión',
            onPressed: () => auth.logout(context)),
        ],
      ),

      // ── Body ────────────────────────
      body: IndexedStack(
        index: _idx,
        children: _screens,
      ),

      // ── Bottom Nav ──────────────────
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: kCard,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, -4)),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _idx,
          onDestinationSelected: (i) =>
            setState(() => _idx = i),
          backgroundColor: kCard,
          elevation: 0,
          height: 65,
          destinations: List.generate(4, (i) =>
            NavigationDestination(
              icon: Icon(_icons[i],
                color: i == _idx ? kPrimary : kSecondary),
              selectedIcon: Icon(_iconsSelected[i],
                color: kPrimary),
              label: _labels[i],
            ),
          ),
        ),
      ),
    );
  }
}