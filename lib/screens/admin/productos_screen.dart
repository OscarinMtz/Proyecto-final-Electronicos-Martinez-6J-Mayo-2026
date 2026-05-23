import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants.dart';
import '../../models/categoria.dart';

class ProductosAdminScreen extends StatefulWidget {
  const ProductosAdminScreen({super.key});
  @override
  State<ProductosAdminScreen> createState() =>
      _ProductosAdminScreenState();
}

class _ProductosAdminScreenState extends State<ProductosAdminScreen> {
  String _filtroCategoria = 'Todos';
  String _busqueda = '';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _abrirFormulario(BuildContext ctx,
      [Map<String, dynamic>? data, String? id]) {
    final nombreCtrl = TextEditingController(
        text: data?['nombre'] ?? '');
    final marcaCtrl = TextEditingController(
        text: data?['marca'] ?? '');
    final descCtrl = TextEditingController(
        text: data?['descripcion_general'] ?? '');
    final imgCtrl = TextEditingController(
        text: data?['imagen_url'] ?? '');
    final precioCtrl = TextEditingController(
        text: data?['precio_base']?.toString() ?? '');
    final fechaCtrl = TextEditingController(
        text: data?['fecha_lanzamiento'] ?? '');
    String catId     = data?['id_categoria']     ?? '';
    String catNombre = data?['nombre_categoria']  ?? '';
    bool disponible  = data?['disponible']        ?? true;
    bool esProximo   = data?['es_proximo']        ?? false;

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, ss) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.90,
            decoration: const BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24))),
            child: Column(children: [
              // Handle + título
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Column(children: [
                  Center(child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: kBorder,
                      borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                    children: [
                      Text(id == null
                        ? 'Nuevo producto'
                        : 'Editar producto',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: kDark)),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close,
                          color: kSecondary)),
                    ]),
                ])),
              const Divider(),

              // Formulario scrollable
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Nombre
                      TextField(
                        controller: nombreCtrl,
                        decoration: kInputDecoration(
                          'Nombre del producto',
                          icon: Icons.devices_outlined)),
                      const SizedBox(height: 14),

                      // Marca
                      TextField(
                        controller: marcaCtrl,
                        decoration: kInputDecoration(
                          'Marca',
                          icon: Icons.business_outlined)),
                      const SizedBox(height: 14),

                      // Precio
                      TextField(
                        controller: precioCtrl,
                        keyboardType:
                          const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: kInputDecoration(
                          'Precio base (sin IVA)',
                          icon: Icons.attach_money)),
                      const SizedBox(height: 6),
                      Text(
                        precioCtrl.text.isNotEmpty
                          ? 'Con IVA (8%): \$${(double.tryParse(precioCtrl.text) ?? 0) * 1.08}'
                              .replaceAll(RegExp(r'(\.\d{2})\d+'), r'$1')
                          : 'Con IVA (8%): \$0.00',
                        style: const TextStyle(
                          fontSize: 12, color: kSecondary)),
                      const SizedBox(height: 14),

                      // Descripción
                      TextField(
                        controller: descCtrl,
                        maxLines: 3,
                        decoration: kInputDecoration(
                          'Descripción general',
                          icon: Icons.description_outlined)),
                      const SizedBox(height: 14),

                      // URL imagen
                      TextField(
                        controller: imgCtrl,
                        decoration: kInputDecoration(
                          'URL imagen (raw GitHub)',
                          icon: Icons.image_outlined,
                          hint:
                            'https://raw.githubusercontent.com/...')),
                      const SizedBox(height: 8),

                      // Preview imagen
                      if (imgCtrl.text.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            imgCtrl.text,
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                              Container(
                                height: 60,
                                color: kPrimaryLight,
                                child: const Center(
                                  child: Text(
                                    'URL de imagen inválida',
                                    style: TextStyle(
                                      color: kDanger)))))),
                      const SizedBox(height: 14),

                      // Categoría
                      const Text('Categoría',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: kSecondary)),
                      const SizedBox(height: 8),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('categorias').snapshots(),
                        builder: (_, snap) {
                          final cats = snap.data?.docs
                              .map((d) => Categoria.fromDoc(d))
                              .toList() ?? [];
                          return Wrap(
                            spacing: 8, runSpacing: 8,
                            children: cats.map((c) {
                              final sel = catId == c.id;
                              return GestureDetector(
                                onTap: () => ss(() {
                                  catId     = c.id;
                                  catNombre = c.nombre;
                                }),
                                child: AnimatedContainer(
                                  duration: const Duration(
                                    milliseconds: 200),
                                  padding:
                                    const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8),
                                  decoration: BoxDecoration(
                                    color: sel
                                      ? kPrimary : kBg,
                                    borderRadius:
                                      BorderRadius.circular(10),
                                    border: Border.all(
                                      color: sel
                                        ? kPrimary : kBorder,
                                      width: 1.5)),
                                  child: Row(
                                    mainAxisSize:
                                      MainAxisSize.min,
                                    children: [
                                      Icon(c.iconData,
                                        size: 14,
                                        color: sel
                                          ? Colors.white
                                          : kSecondary),
                                      const SizedBox(width: 6),
                                      Text(c.nombre,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight:
                                            FontWeight.w500,
                                          color: sel
                                            ? Colors.white
                                            : kSecondary)),
                                    ])));
                            }).toList());
                        }),
                      const SizedBox(height: 14),

                      // Switches
                      Container(
                        decoration: BoxDecoration(
                          color: kBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: kBorder)),
                        child: Column(children: [
                          SwitchListTile(
                            value: disponible,
                            onChanged: (v) =>
                              ss(() => disponible = v),
                            activeColor: kSuccess,
                            title: const Text('Disponible',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500)),
                            subtitle: const Text(
                              'Visible en el catálogo',
                              style: TextStyle(
                                fontSize: 12)),
                          ),
                          const Divider(height: 1),
                          SwitchListTile(
                            value: esProximo,
                            onChanged: (v) =>
                              ss(() => esProximo = v),
                            activeColor: kPrimary,
                            title: const Text('Producto próximo',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500)),
                            subtitle: const Text(
                              'Aparece en sección próximos',
                              style: TextStyle(fontSize: 12)),
                          ),
                        ])),
                      const SizedBox(height: 14),

                      // Fecha lanzamiento (si es próximo)
                      if (esProximo) ...[
                        TextField(
                          controller: fechaCtrl,
                          decoration: kInputDecoration(
                            'Fecha estimada de lanzamiento',
                            icon: Icons.calendar_month_outlined,
                            hint: 'Ej: Junio 2025')),
                        const SizedBox(height: 14),
                      ],
                    ]))),

              // Botones fijos abajo
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                child: Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 14),
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
                        final datos = {
                          'nombre': nombreCtrl.text.trim(),
                          'marca':  marcaCtrl.text.trim(),
                          'descripcion_general':
                            descCtrl.text.trim(),
                          'imagen_url':    imgCtrl.text.trim(),
                          'id_categoria':  catId,
                          'nombre_categoria': catNombre,
                          'precio_base':
                            double.tryParse(precioCtrl.text) ?? 0,
                          'disponible':    disponible,
                          'es_proximo':    esProximo,
                          'fecha_lanzamiento':
                            esProximo ? fechaCtrl.text.trim() : null,
                        };
                        if (id == null) {
                          await FirebaseFirestore.instance
                              .collection('productos').add(datos);
                        } else {
                          await FirebaseFirestore.instance
                              .collection('productos')
                              .doc(id).update(datos);
                        }
                        Navigator.pop(context);
                      },
                      style: kPrimaryButton,
                      child: Text(id == null
                        ? 'Crear producto'
                        : 'Guardar cambios'))),
                ])),
            ])))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Column(children: [

        // ── Búsqueda y filtro ──────────
        Container(
          color: kCard,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(children: [
            TextField(
              controller: _searchCtrl,
              onChanged: (v) =>
                setState(() => _busqueda = v.toLowerCase()),
              decoration: kInputDecoration(
                'Buscar productos...',
                icon: Icons.search).copyWith(
                suffixIcon: _busqueda.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _busqueda = '');
                      })
                  : null)),
            const SizedBox(height: 10),

            // Chips categorías
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('categorias').snapshots(),
              builder: (_, snap) {
                final cats = <Categoria>[];
                if (snap.hasData) {
                  cats.addAll(snap.data!.docs
                      .map((d) => Categoria.fromDoc(d)));
                }
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    _chip('Todos', null),
                    const SizedBox(width: 8),
                    ...cats.map((c) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _chip(c.nombre, c.nombre))),
                  ]));
              }),
            const SizedBox(height: 10),
          ])),

        const Divider(height: 1),

        // ── Lista productos ────────────
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('productos').snapshots(),
            builder: (context, snap) {
              if (!snap.hasData) return const Center(
                child: CircularProgressIndicator());

              var docs = snap.data!.docs;

              // Filtrar categoría
              if (_filtroCategoria != 'Todos') {
                docs = docs.where((d) {
                  final data = d.data() as Map<String, dynamic>;
                  return data['nombre_categoria'] ==
                    _filtroCategoria;
                }).toList();
              }

              // Filtrar búsqueda
              if (_busqueda.isNotEmpty) {
                docs = docs.where((d) {
                  final data = d.data() as Map<String, dynamic>;
                  return (data['nombre'] ?? '')
                      .toString().toLowerCase()
                      .contains(_busqueda) ||
                    (data['marca'] ?? '')
                      .toString().toLowerCase()
                      .contains(_busqueda);
                }).toList();
              }

              if (docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off,
                        size: 56, color: kMuted),
                      const SizedBox(height: 12),
                      const Text('Sin productos',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: kSecondary)),
                    ]));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                itemBuilder: (context, i) {
                  final d = docs[i].data()
                      as Map<String, dynamic>;
                  final url     = d['imagen_url']        ?? '';
                  final nombre  = d['nombre']            ?? '';
                  final marca   = d['marca']             ?? '';
                  final precio  = (d['precio_base'] as num?)
                      ?.toDouble() ?? 0;
                  final cat     = d['nombre_categoria']  ?? '';
                  final disp    = d['disponible']        ?? true;
                  final prox    = d['es_proximo']        ?? false;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: kCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: kBorder),
                      boxShadow: kShadowSm),
                    child: Row(children: [

                      // Imagen
                      ClipRRect(
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(14)),
                        child: url.isNotEmpty
                          ? Image.network(url,
                              width: 90, height: 90,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                _imgPlaceholder())
                          : _imgPlaceholder()),

                      // Info
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment:
                              CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Expanded(
                                  child: Text(nombre,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: kDark))),
                                // Badges estado
                                if (prox)
                                  _badge('Próximo',
                                    const Color(0xFF7C3AED))
                                else if (!disp)
                                  _badge('Oculto', kSecondary),
                              ]),
                              const SizedBox(height: 2),
                              Text('$marca · $cat',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: kSecondary)),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '\$${precio.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: kPrimary)),
                                      Text(
                                        'c/IVA \$${(precio * 1.08).toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: kMuted)),
                                    ]),
                                  Row(children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        size: 18, color: kPrimary),
                                      onPressed: () =>
                                        _abrirFormulario(
                                          context, d, docs[i].id)),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        size: 18, color: kDanger),
                                      onPressed: () =>
                                        _confirmarEliminar(
                                          context,
                                          docs[i].id, nombre)),
                                  ]),
                                ]),
                            ]))),
                    ]));
                });
            })),
      ]),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(context),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo producto'),
      ),
    );
  }

  Widget _chip(String label, String? valor) {
    final sel = _filtroCategoria == (valor ?? 'Todos');
    return GestureDetector(
      onTap: () =>
        setState(() => _filtroCategoria = valor ?? 'Todos'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: sel ? kPrimary : kBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: sel ? kPrimary : kBorder, width: 1.5)),
        child: Text(label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: sel ? Colors.white : kSecondary))));
  }

  Widget _imgPlaceholder() {
    return Container(
      width: 90, height: 90,
      color: kPrimaryLight,
      child: const Icon(Icons.devices,
        color: kPrimary, size: 36));
  }

  Widget _badge(String label, Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(
        horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6)),
      child: Text(label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color)));
  }

  void _confirmarEliminar(
    BuildContext ctx, String id, String nombre) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text('¿Eliminar "$nombre"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kDanger),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('productos').doc(id).delete();
              Navigator.pop(ctx);
            },
            child: const Text('Eliminar')),
        ]));
  }
}