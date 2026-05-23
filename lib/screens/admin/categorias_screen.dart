import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants.dart';
import '../../models/categoria.dart';

class CategoriasAdminScreen extends StatelessWidget {
  const CategoriasAdminScreen({super.key});

  static const _iconos = [
    {'label': 'Laptops',   'value': 'laptop'},
    {'label': 'Mouse',     'value': 'mouse'},
    {'label': 'Monitor',   'value': 'monitor'},
    {'label': 'Audífonos', 'value': 'headphones'},
    {'label': 'Celular',   'value': 'phone'},
    {'label': 'Tablet',    'value': 'tablet'},
    {'label': 'Teclado',   'value': 'keyboard'},
    {'label': 'Cámara',    'value': 'camera'},
    {'label': 'Bocina',    'value': 'speaker'},
    {'label': 'TV',        'value': 'tv'},
    {'label': 'General',   'value': 'devices'},
  ];

  void _abrirFormulario(BuildContext ctx, [Categoria? cat]) {
    final nombreCtrl = TextEditingController(text: cat?.nombre ?? '');
    final descCtrl   = TextEditingController(text: cat?.descripcion ?? '');
    String iconoSel  = cat?.icono ?? 'devices';

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, ss) {
            return Padding(
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
                    Center(
                      child: Container(
                        width: 40, height: 4,
                        decoration: BoxDecoration(
                          color: kBorder,
                          borderRadius: BorderRadius.circular(2)))),
                    const SizedBox(height: 16),
                    Text(
                      cat == null ? 'Nueva categoría' : 'Editar categoría',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: kDark)),
                    const SizedBox(height: 20),
                    TextField(
                      controller: nombreCtrl,
                      decoration: kInputDecoration(
                        'Nombre de categoría',
                        icon: Icons.category_outlined)),
                    const SizedBox(height: 14),
                    TextField(
                      controller: descCtrl,
                      maxLines: 2,
                      decoration: kInputDecoration(
                        'Descripción',
                        icon: Icons.description_outlined)),
                    const SizedBox(height: 16),
                    const Text('Ícono',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: kSecondary)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: _iconos.map((i) {
                        final sel = iconoSel == i['value'];
                        final tempCat = Categoria(
                          id: '', nombre: '',
                          descripcion: '', icono: i['value']!);
                        return GestureDetector(
                          onTap: () => ss(() => iconoSel = i['value']!),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: sel ? kPrimary : kBg,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: sel ? kPrimary : kBorder,
                                width: 1.5)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(tempCat.iconData,
                                  size: 16,
                                  color: sel ? Colors.white : kSecondary),
                                const SizedBox(width: 6),
                                Text(i['label']!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: sel ? Colors.white : kSecondary)),
                              ])));
                      }).toList()),
                    const SizedBox(height: 24),
                    Row(children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: kBorder),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                          child: const Text('Cancelar',
                            style: TextStyle(color: kSecondary)))),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (nombreCtrl.text.trim().isEmpty) return;
                            final data = {
                              'nombre':      nombreCtrl.text.trim(),
                              'descripcion': descCtrl.text.trim(),
                              'icono':       iconoSel,
                            };
                            if (cat == null) {
                              await FirebaseFirestore.instance
                                  .collection('categorias').add(data);
                            } else {
                              await FirebaseFirestore.instance
                                  .collection('categorias')
                                  .doc(cat.id).update(data);
                            }
                            Navigator.pop(context);
                          },
                          style: kPrimaryButton,
                          child: Text(cat == null
                            ? 'Crear categoría' : 'Guardar cambios'))),
                    ]),
                  ])));
          });
      });
  }

  void _confirmarEliminar(BuildContext ctx, Categoria cat) {
    showDialog(
      context: ctx,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar categoría'),
          content: Text('¿Eliminar "${cat.nombre}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kDanger),
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('categorias').doc(cat.id).delete();
                Navigator.pop(context);
              },
              child: const Text('Eliminar')),
          ]);
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('categorias')
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
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: kPrimaryLight,
                      shape: BoxShape.circle),
                    child: const Icon(Icons.category_outlined,
                      size: 40, color: kPrimary)),
                  const SizedBox(height: 16),
                  const Text('Sin categorías',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: kDark)),
                  const SizedBox(height: 8),
                  const Text('Agrega tu primera categoría',
                    style: TextStyle(color: kSecondary)),
                ]));
          }
          final cats = snap.data!.docs
              .map((d) => Categoria.fromDoc(d)).toList();
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cats.length,
            itemBuilder: (context, i) {
              final cat = cats[i];
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
                      color: kPrimaryLight,
                      borderRadius: BorderRadius.circular(12)),
                    child: Icon(cat.iconData,
                      color: kPrimary, size: 24)),
                  title: Text(cat.nombre,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: kDark)),
                  subtitle: Text(
                    cat.descripcion.isNotEmpty
                      ? cat.descripcion : 'Sin descripción',
                    style: const TextStyle(
                      fontSize: 12, color: kSecondary)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('productos')
                            .where('nombre_categoria',
                              isEqualTo: cat.nombre)
                            .snapshots(),
                        builder: (_, s) {
                          final count = s.data?.docs.length ?? 0;
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: kPrimaryLight,
                              borderRadius: BorderRadius.circular(8)),
                            child: Text('$count prod.',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: kPrimary)));
                        }),
                      const SizedBox(width: 4),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert,
                          color: kSecondary),
                        onSelected: (v) {
                          if (v == 'editar') {
                            _abrirFormulario(context, cat);
                          } else {
                            _confirmarEliminar(context, cat);
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
                    ])));
            });
        }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(context),
        icon: const Icon(Icons.add),
        label: const Text('Nueva categoría')),
    );
  }
}