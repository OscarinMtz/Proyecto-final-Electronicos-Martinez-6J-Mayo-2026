import 'producto.dart';

// ═══════════════════════════════════════
// ITEM DEL CARRITO
// ═══════════════════════════════════════
class CarritoItem {
  final Producto producto;
  int cantidad;

  CarritoItem({
    required this.producto,
    this.cantidad = 1,
  });

  double get subtotal => producto.precioBase * cantidad;
  double get subtotalConIva => producto.precioConIva * cantidad;
}

// ═══════════════════════════════════════
// MODELO PEDIDO
// ═══════════════════════════════════════
class Pedido {
  final String id;
  final String emailCliente;
  final String nombreCliente;
  final List<Map<String, dynamic>> items;
  final double subtotal;
  final double iva;
  final double total;
  final String estado;
  final String metodoPago;
  final String ultimos4;
  final DateTime fechaPedido;

  Pedido({
    required this.id,
    required this.emailCliente,
    required this.nombreCliente,
    required this.items,
    required this.subtotal,
    required this.iva,
    required this.total,
    required this.estado,
    required this.metodoPago,
    required this.ultimos4,
    required this.fechaPedido,
  });

  factory Pedido.fromMap(String id, Map<String, dynamic> d) {
    return Pedido(
      id:             id,
      emailCliente:   d['email_cliente']   ?? '',
      nombreCliente:  d['nombre_cliente']  ?? '',
      items:          List<Map<String, dynamic>>.from(d['items'] ?? []),
      subtotal:       (d['subtotal'] as num?)?.toDouble() ?? 0,
      iva:            (d['iva']      as num?)?.toDouble() ?? 0,
      total:          (d['total_neto'] as num?)?.toDouble() ?? 0,
      estado:         d['estado']          ?? 'Pendiente',
      metodoPago:     d['metodo_pago']     ?? '',
      ultimos4:       d['ultimos4']        ?? '',
      fechaPedido:    (d['fecha_pedido'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email_cliente':  emailCliente,
      'nombre_cliente': nombreCliente,
      'items':          items,
      'subtotal':       subtotal,
      'iva':            iva,
      'total_neto':     total,
      'estado':         estado,
      'metodo_pago':    metodoPago,
      'ultimos4':       ultimos4,
      'fecha_pedido':   fechaPedido,
    };
  }

  // Color según estado
  String get estadoLabel {
    switch (estado) {
      case 'Pagado':    return 'Pagado';
      case 'Enviado':   return 'Enviado';
      case 'Cancelado': return 'Cancelado';
      default:          return 'Pendiente';
    }
  }
}

// ═══════════════════════════════════════
// MODELO RESERVA (productos próximos)
// ═══════════════════════════════════════
class Reserva {
  final String id;
  final String idProducto;
  final String nombreProducto;
  final String emailCliente;
  final String nombreCliente;
  final DateTime fechaReserva;
  final String estado;

  Reserva({
    required this.id,
    required this.idProducto,
    required this.nombreProducto,
    required this.emailCliente,
    required this.nombreCliente,
    required this.fechaReserva,
    required this.estado,
  });

  factory Reserva.fromMap(String id, Map<String, dynamic> d) {
    return Reserva(
      id:              id,
      idProducto:      d['id_producto']      ?? '',
      nombreProducto:  d['nombre_producto']  ?? '',
      emailCliente:    d['email_cliente']    ?? '',
      nombreCliente:   d['nombre_cliente']   ?? '',
      fechaReserva:    (d['fecha_reserva'] as dynamic)?.toDate() ?? DateTime.now(),
      estado:          d['estado']           ?? 'Reservado',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_producto':     idProducto,
      'nombre_producto': nombreProducto,
      'email_cliente':   emailCliente,
      'nombre_cliente':  nombreCliente,
      'fecha_reserva':   fechaReserva,
      'estado':          estado,
    };
  }
}