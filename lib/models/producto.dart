import 'package:cloud_firestore/cloud_firestore.dart';

class Producto {
  final String id;
  final String nombre;
  final String marca;
  final String descripcionGeneral;
  final String imagenUrl;
  final String idCategoria;
  final String nombreCategoria;
  final double precioBase;
  final bool disponible;
  final bool esProximo;
  final String? fechaLanzamiento;

  Producto({
    required this.id,
    required this.nombre,
    required this.marca,
    required this.descripcionGeneral,
    required this.imagenUrl,
    required this.idCategoria,
    required this.nombreCategoria,
    required this.precioBase,
    this.disponible = true,
    this.esProximo = false,
    this.fechaLanzamiento,
  });

  // Desde Firestore
  factory Producto.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Producto(
      id:                  doc.id,
      nombre:              d['nombre']              ?? '',
      marca:               d['marca']               ?? '',
      descripcionGeneral:  d['descripcion_general'] ?? '',
      imagenUrl:           d['imagen_url']          ?? '',
      idCategoria:         d['id_categoria']        ?? '',
      nombreCategoria:     d['nombre_categoria']    ?? '',
      precioBase:          (d['precio_base'] as num?)?.toDouble() ?? 0.0,
      disponible:          d['disponible']          ?? true,
      esProximo:           d['es_proximo']          ?? false,
      fechaLanzamiento:    d['fecha_lanzamiento'],
    );
  }

  // Hacia Firestore
  Map<String, dynamic> toMap() {
    return {
      'nombre':              nombre,
      'marca':               marca,
      'descripcion_general': descripcionGeneral,
      'imagen_url':          imagenUrl,
      'id_categoria':        idCategoria,
      'nombre_categoria':    nombreCategoria,
      'precio_base':         precioBase,
      'disponible':          disponible,
      'es_proximo':          esProximo,
      'fecha_lanzamiento':   fechaLanzamiento,
    };
  }

  // Precio con IVA
  double get precioConIva => precioBase * 1.08;

  // Copia con cambios
  Producto copyWith({
    String? nombre,
    String? marca,
    String? descripcionGeneral,
    String? imagenUrl,
    String? idCategoria,
    String? nombreCategoria,
    double? precioBase,
    bool? disponible,
    bool? esProximo,
    String? fechaLanzamiento,
  }) {
    return Producto(
      id:                 this.id,
      nombre:             nombre             ?? this.nombre,
      marca:              marca              ?? this.marca,
      descripcionGeneral: descripcionGeneral ?? this.descripcionGeneral,
      imagenUrl:          imagenUrl          ?? this.imagenUrl,
      idCategoria:        idCategoria        ?? this.idCategoria,
      nombreCategoria:    nombreCategoria    ?? this.nombreCategoria,
      precioBase:         precioBase         ?? this.precioBase,
      disponible:         disponible         ?? this.disponible,
      esProximo:          esProximo          ?? this.esProximo,
      fechaLanzamiento:   fechaLanzamiento   ?? this.fechaLanzamiento,
    );
  }
}