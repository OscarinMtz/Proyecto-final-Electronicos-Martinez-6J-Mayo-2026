import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants.dart';

class EmpleadosAdminScreen extends StatelessWidget {
  const EmpleadosAdminScreen({super.key});

  static const _roles = ['Admin', 'Vendedor', 'Almacenista'];

  Color _colorRol(String rol) {
    switch (rol) {
      case 'Admin':       return kPrimary;
      case 'Vendedor':    return kSuccess;
      case 'Almacenista': return kWarning;
      default:            return kSecondary;
    }
  }

  IconData _iconRol(String rol) {
    switch (rol) {
      case 'Admin':       return Icons.admin_panel_settings;
      case 'Vendedor':    return Icons.point_of_sale;
      case 'Almacenista': return Icons.warehouse;
      default:            return Icons.person;
    }
  }

  // Función interna para parsear de forma segura cualquier número que venga como String o num
  double _parseSecureDouble(dynamic valor) {
    if (valor == null) return 0.0;
    if (valor is num) return valor.toDouble();
    if (valor is String) {
      return double.tryParse(valor) ?? 0.0;
    }
    return 0.0;
  }

  void _abrirFormulario(BuildContext ctx,
      [Map<String, dynamic>? data, String? id]) {
    final nombreCtrl = TextEditingController(
        text: data?['nombre'] ?? '');
    final emailCtrl  = TextEditingController(
        text: data?['email'] ?? '');
    final passCtrl   = TextEditingController();
    final comCtrl    = TextEditingController(
        text: data?['comision_pct']?.toString() ?? '0');
    String rol = data?['rol'] ?? 'Vendedor';

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, ss) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24))),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: kBorder,
                    borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                  children: [
                    Text(id == null
                      ? 'Nuevo empleado'
                      : 'Editar empleado',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: kDark)),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close,
                        color: kSecondary)),
                  ]),
                const SizedBox(height: 20),

                // Nombre
                TextField(
                  controller: nombreCtrl,
                  decoration: kInputDecoration(
                    'Nombre completo',
                    icon: Icons.person_outline)),
                const SizedBox(height: 14),

                // Email (solo al crear)
                if (id == null) ...[
                  TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: kInputDecoration(
                      'Correo electrónico',
                      icon: Icons.email_outlined)),
                  const SizedBox(height: 14),

                  // Contraseña (solo al crear)
                  TextField(
                    controller: passCtrl,
                    obscureText: true,
                    decoration: kInputDecoration(
                      'Contraseña (mín. 6 caracteres)',
                      icon: Icons.lock_outline)),
                  const SizedBox(height: 14),
                ],

                // Comisión
                TextField(
                  controller: comCtrl,
                  keyboardType:
                    const TextInputType.numberWithOptions(
                      decimal: true),
                  decoration: kInputDecoration(
                    'Comisión (%)',
                    icon: Icons.percent)),
                const SizedBox(height: 16),

                // Selector de rol
                const Text('Rol del empleado',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: kSecondary)),
                const SizedBox(height: 10),
                Row(children: _roles.map((r) {
                  final sel = rol == r;
                  final color = _colorRol(r);
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => ss(() => rol = r),
                      child: AnimatedContainer(
                        duration: const Duration(
                          milliseconds: 200),
                        margin: EdgeInsets.only(
                          right: r != _roles.last ? 8 : 0),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12),
                        decoration: BoxDecoration(
                          color: sel
                            ? color.withOpacity(0.1)
                            : kBg,
                          borderRadius:
                            BorderRadius.circular(10),
                          border: Border.all(
                            color: sel ? color : kBorder,
                            width: 1.5)),
                        child: Column(children: [
                          Icon(_iconRol(r),
                            size: 20,
                            color: sel ? color : kSecondary),
                          const SizedBox(height: 4),
                          Text(r,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: sel ? color : kSecondary)),
                        ]))));
                }).toList()),
                const SizedBox(height: 24),

                // Botones
                Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 14),
                        side: const BorderSide(color: kBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                            BorderRadius.circular(10))),
                      child: const Text('Cancelar',
                        style: TextStyle(color: kSecondary)))),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (nombreCtrl.text.trim().isEmpty) return;
                        try {
                          if (id == null) {
                            // Crear usuario en Auth
                            final cred = await FirebaseAuth
                                .instance
                                .createUserWithEmailAndPassword(
                                  email: emailCtrl.text.trim(),
                                  password: passCtrl.text);
                            // Guardar en Firestore
                            await FirebaseFirestore.instance
                                .collection('empleados').add({
                              'uid':     cred.user!.uid,
                              'nombre': nombreCtrl.text.trim(),
                              'email':  emailCtrl.text.trim(),
                              'rol':    rol,
                              'comision_pct':
                                double.tryParse(comCtrl.text)
                                  ?? 0,
                            });
                          } else {
                            await FirebaseFirestore.instance
                                .collection('empleados')
                                .doc(id).update({
                              'nombre': nombreCtrl.text.trim(),
                              'rol':    rol,
                              'comision_pct':
                                double.tryParse(comCtrl.text)
                                  ?? 0,
                            });
                          }
                          Navigator.pop(context);
                        } catch (e) {
                          ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: kDanger));
                        }
                      },
                      style: kPrimaryButton,
                      child: Text(id == null
                        ? 'Crear empleado'
                        : 'Guardar cambios'))),
                ]),
              ])))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('empleados').snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator());
          }

          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: kPrimaryLight,
                      shape: BoxShape.circle),
                    child: const Icon(Icons.badge_outlined,
                      size: 40, color: kPrimary)),
                  const SizedBox(height: 16),
                  const Text('Sin empleados',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: kDark)),
                  const SizedBox(height: 8),
                  const Text('Agrega tu primer empleado',
                    style: TextStyle(color: kSecondary)),
                ]));
          }

          final docs = snap.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final d = docs[i].data() as Map<String, dynamic>;
              final nombre = d['nombre'] ?? 'Sin nombre';
              final email  = d['email']  ?? '';
              final rol    = d['rol']    ?? 'Vendedor';
              
              // CAMBIO AQUÍ: Parseo seguro para evitar la pantalla roja
              final com    = _parseSecureDouble(d['comision_pct']);
              
              final color  = _colorRol(rol);
              final inicial = nombre[0].toUpperCase();

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: kCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kBorder),
                  boxShadow: kShadowSm),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                  leading: Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle),
                    child: Center(
                      child: Text(inicial,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: color)))),
                  title: Text(nombre,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: kDark)),
                  subtitle: Column(
                    crossAxisAlignment:
                      CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(email,
                        style: const TextStyle(
                          fontSize: 12,
                          color: kSecondary)),
                      const SizedBox(height: 4),
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius:
                              BorderRadius.circular(6)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_iconRol(rol),
                                size: 11, color: color),
                              const SizedBox(width: 4),
                              Text(rol,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: color)),
                            ])),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: kBg,
                            borderRadius:
                              BorderRadius.circular(6),
                            border: Border.all(color: kBorder)),
                          child: Text(
                            'Comisión: ${com.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              fontSize: 11,
                              color: kSecondary))),
                      ]),
                    ]),
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert,
                      color: kSecondary),
                    onSelected: (v) {
                      if (v == 'editar') {
                        _abrirFormulario(
                          context, d, docs[i].id);
                      } else {
                        _confirmarEliminar(
                          context, docs[i].id, nombre);
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'editar',
                        child: Row(children: [
                          Icon(Icons.edit_outlined,
                            size: 18, color: kPrimary),
                          SizedBox(width: 10),
                          Text('Editar'),
                        ])),
                      const PopupMenuItem(
                        value: 'eliminar',
                        child: Row(children: [
                          Icon(Icons.delete_outline,
                            size: 18, color: kDanger),
                          SizedBox(width: 10),
                          Text('Eliminar',
                            style: TextStyle(color: kDanger)),
                        ])),
                    ]),
                ));
            });
        }),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(context),
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Nuevo empleado'),
      ),
    );
  }

  void _confirmarEliminar(
    BuildContext ctx, String id, String nombre) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar empleado'),
        content: Text(
          '¿Eliminar a "$nombre"?\n'
          'Su cuenta de acceso permanecerá activa.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kDanger),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('empleados').doc(id).delete();
              Navigator.pop(ctx);
            },
            child: const Text('Eliminar')),
        ]));
  }
}