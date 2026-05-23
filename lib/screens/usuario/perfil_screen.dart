import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';

// Importaciones de tus pantallas existentes
import 'mis_pedidos_screen.dart';
import 'proximos_screen.dart'; 

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});
  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  bool _editando = false;
  final _nombreCtrl = TextEditingController();
  final _telCtrl    = TextEditingController();
  final _dniCtrl    = TextEditingController();

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _telCtrl.dispose();
    _dniCtrl.dispose();
    super.dispose();
  }

  void _iniciarEdicion(Map<String, dynamic> datos) {
    _nombreCtrl.text = datos['nombre_completo'] ?? '';
    _telCtrl.text    = datos['telefono']        ?? '';
    _dniCtrl.text    = datos['dni']             ?? '';
    setState(() => _editando = true);
  }

  Future<void> _guardar(AppAuthProvider auth) async {
    final datos = auth.datosUsuario;
    if (datos == null) return;
    final ok = await auth.actualizarPerfil(
      docId:    datos['id'],
      nombre:   _nombreCtrl.text,
      telefono: _telCtrl.text,
      dni:      _dniCtrl.text,
    );
    if (ok && mounted) {
      setState(() => _editando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado correctamente'),
          backgroundColor: kSuccess));
    }
  }

  // 🔥 FUNCIÓN PARA ABRIR LAS PANTALLAS CON BOTÓN DE REGRESAR INCLUIDO
  void _abrirPantallaFlotante(Widget pantalla) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Para que use toda la pantalla si es necesario
      backgroundColor: kBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Stack(
          children: [
            // Contenedor de la pantalla original tuya
            Padding(
              padding: const EdgeInsets.only(top: 60), // Espacio para el botón de cerrar
              child: pantalla,
            ),
            // Botón de regresar elegante en la parte superior derecha
            Positioned(
              top: 15,
              right: 15,
              child: CircleAvatar(
                backgroundColor: kDark.withOpacity(0.1),
                child: IconButton(
                  icon: const Icon(Icons.close, color: kDark),
                  onPressed: () => Navigator.pop(context), // Cierra el modal y regresa al perfil
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth  = context.watch<AppAuthProvider>();
    final datos = auth.datosUsuario ?? {};
    final nombre = datos['nombre_completo'] ?? 'Usuario';
    final email  = datos['email'] ?? '';
    final tel    = datos['telefono'] ?? '';
    final dni    = datos['dni'] ?? '';
    final inicial = nombre.isNotEmpty ? nombre[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: kBg,
      body: SingleChildScrollView(
        child: Column(children: [

          // ── Header ──────────────────
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1D4ED8),
                         Color(0xFF2563EB),
                         Color(0xFF0EA5E9)]),
            ),
            padding: const EdgeInsets.fromLTRB(20, 48, 20, 32),
            child: Column(children: [
              Container(
                width: 88, height: 88,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 3)),
                child: Center(
                  child: Text(inicial,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)))),
              const SizedBox(height: 14),
              Text(nombre,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
              const SizedBox(height: 4),
              Text(email,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.8))),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3))),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_user_outlined,
                      size: 14, color: Colors.white),
                    SizedBox(width: 6),
                    Text('Cliente verificado',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w600)),
                  ])),
            ]),
          ),

          // ── Estadísticas ─────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('pedidos')
                  .where('email_cliente', isEqualTo: email)
                  .snapshots(),
              builder: (context, snap) {
                final pedidos = snap.data?.docs ?? [];
                final total = pedidos.fold<double>(0, (s, d) {
                  final data = d.data() as Map<String, dynamic>;
                  return s + ((data['total_neto'] as num?)
                    ?.toDouble() ?? 0);
                });
                return Row(children: [
                  _StatBox(
                    valor: '${pedidos.length}',
                    label: 'Pedidos',
                    icon: Icons.receipt_long_outlined,
                    color: kPrimary),
                  const SizedBox(width: 12),
                  _StatBox(
                    valor: '\$${total.toStringAsFixed(0)}',
                    label: 'Total gastado',
                    icon: Icons.attach_money,
                    color: kSuccess),
                  const SizedBox(width: 12),
                  _StatBox(
                    valor: pedidos.isEmpty ? '—'
                      : (pedidos.first.data()
                          as Map<String, dynamic>)['estado'] ?? '—',
                    label: 'Último estado',
                    icon: Icons.local_shipping_outlined,
                    color: kAccent),
                ]);
              },
            ),
          ),

          // ── Datos personales ─────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: kBorder),
                boxShadow: kShadowSm),
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Row(
                    mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Datos personales',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: kDark)),
                      if (!_editando)
                        TextButton.icon(
                          onPressed: () => _iniciarEdicion(datos),
                          icon: const Icon(Icons.edit_outlined,
                            size: 16),
                          label: const Text('Editar'),
                        )
                      else
                        Row(children: [
                          TextButton(
                            onPressed: () =>
                              setState(() => _editando = false),
                            child: const Text('Cancelar',
                              style: TextStyle(color: kSecondary))),
                          const SizedBox(width: 4),
                          ElevatedButton(
                            onPressed: auth.loading
                              ? null : () => _guardar(auth),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kSuccess,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                              minimumSize: Size.zero,
                              tapTargetSize:
                                MaterialTapTargetSize.shrinkWrap),
                            child: auth.loading
                              ? const SizedBox(
                                  width: 16, height: 16,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2))
                              : const Text('Guardar',
                                  style: TextStyle(fontSize: 13))),
                        ]),
                    ])),

                const Divider(height: 1),

                if (_editando) ...[
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(children: [
                      TextField(
                        controller: _nombreCtrl,
                        decoration: kInputDecoration(
                          'Nombre completo',
                          icon: Icons.person_outline)),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _telCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: kInputDecoration(
                          'Teléfono',
                          icon: Icons.phone_outlined)),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _dniCtrl,
                        decoration: kInputDecoration(
                          'RFC / DNI',
                          icon: Icons.badge_outlined)),
                    ])),
                ] else ...[
                  _InfoFila(
                    icon: Icons.person_outline,
                    label: 'Nombre',
                    valor: nombre),
                  _InfoFila(
                    icon: Icons.email_outlined,
                    label: 'Correo',
                    valor: email),
                  _InfoFila(
                    icon: Icons.phone_outlined,
                    label: 'Teléfono',
                    valor: tel.isNotEmpty ? tel : 'Sin registrar'),
                  _InfoFila(
                    icon: Icons.badge_outlined,
                    label: 'RFC / DNI',
                    valor: dni.isNotEmpty ? dni : 'Sin registrar',
                    ultimo: true),
                ],
              ]),
            ),
          ),

          // ── Acciones (AHORA SÍ DAN OPCIÓN DE REGRESAR 🚀) ─────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            child: Container(
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: kBorder),
                boxShadow: kShadowSm),
              child: Column(children: [
                _AccionFila(
                  icon: Icons.receipt_long_outlined,
                  label: 'Mis pedidos',
                  color: kPrimary,
                  onTap: () {
                    // Abre tus pedidos en un modal deslizable con su botón de salir
                    _abrirPantallaFlotante(const MisPedidosScreen());
                  }),
                const Divider(height: 1, indent: 52),
                _AccionFila(
                  icon: Icons.new_releases_outlined,
                  label: 'Mis reservas',
                  color: kAccent,
                  onTap: () {
                    // Abre tus reservas en un modal deslizable con su botón de salir
                    _abrirPantallaFlotante(const ProximosScreen());
                  }),
                const Divider(height: 1, indent: 52),
                _AccionFila(
                  icon: Icons.help_outline,
                  label: 'Ayuda y soporte',
                  color: kSecondary,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Soporte técnico: contacto@electroshop.com')));
                  }),
                const Divider(height: 1, indent: 52),
                _AccionFila(
                  icon: Icons.logout,
                  label: 'Cerrar sesión',
                  color: kDanger,
                  onTap: () => auth.logout(context)),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════
// WIDGETS HELPER
// ═══════════════════════════════════════
class _StatBox extends StatelessWidget {
  final String valor;
  final String label;
  final IconData icon;
  final Color color;
  const _StatBox({
    required this.valor,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kBorder),
          boxShadow: kShadowSm),
        child: Column(children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(valor,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color)),
          const SizedBox(height: 2),
          Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10, color: kSecondary)),
        ]),
      ),
    );
  }
}

class _InfoFila extends StatelessWidget {
  final IconData icon;
  final String label;
  final String valor;
  final bool ultimo;
  const _InfoFila({
    required this.icon,
    required this.label,
    required this.valor,
    this.ultimo = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 12),
        child: Row(children: [
          Icon(icon, size: 18, color: kSecondary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                style: const TextStyle(
                  fontSize: 11, color: kMuted)),
              const SizedBox(height: 2),
              Text(valor,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: kDark)),
            ]),
        ])),
      if (!ultimo) const Divider(height: 1, indent: 46),
    ]);
  }
}

class _AccionFila extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _AccionFila({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 18, color: color)),
      title: Text(label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: color == kDanger ? kDanger : kDark)),
      trailing: const Icon(Icons.chevron_right,
        size: 18, color: kMuted),
    );
  }
}