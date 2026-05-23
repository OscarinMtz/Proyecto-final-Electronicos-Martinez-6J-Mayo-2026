import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/carrito.dart';
import '../models/producto.dart';

class CarritoProvider extends ChangeNotifier {
  final List<CarritoItem> _items = [];
  bool _procesando = false;

  List<CarritoItem> get items => List.unmodifiable(_items);
  bool get procesando => _procesando;
  bool get vacio => _items.isEmpty;
  int get totalItems => _items.fold(0, (s, i) => s + i.cantidad);

  // ── Totales ──────────────────────────
  double get subtotal =>
      _items.fold(0, (s, i) => s + i.subtotal);

  double get iva => subtotal * 0.08;

  double get total => subtotal + iva;

  // ── Agregar producto ─────────────────
  void agregar(Producto p) {
    final idx = _items.indexWhere((i) => i.producto.id == p.id);
    if (idx >= 0) {
      _items[idx].cantidad++;
    } else {
      _items.add(CarritoItem(producto: p));
    }
    notifyListeners();
  }

  // ── Quitar uno ───────────────────────
  void quitar(String productoId) {
    final idx = _items.indexWhere((i) => i.producto.id == productoId);
    if (idx < 0) return;
    if (_items[idx].cantidad > 1) {
      _items[idx].cantidad--;
    } else {
      _items.removeAt(idx);
    }
    notifyListeners();
  }

  // ── Eliminar del carrito ─────────────
  void eliminar(String productoId) {
    _items.removeWhere((i) => i.producto.id == productoId);
    notifyListeners();
  }

  // ── Limpiar carrito ──────────────────
  void limpiar() {
    _items.clear();
    notifyListeners();
  }

  // ── Verificar si está en carrito ─────
  bool estaEnCarrito(String productoId) =>
      _items.any((i) => i.producto.id == productoId);

  int cantidadEnCarrito(String productoId) {
    final idx = _items.indexWhere((i) => i.producto.id == productoId);
    return idx >= 0 ? _items[idx].cantidad : 0;
  }

  // ── Realizar pedido ──────────────────
  Future<bool> realizarPedido({
    required String numeroTarjeta,
    required String nombreTarjeta,
    required String expiracion,
    required String cvv,
    required String metodoPago,
  }) async {
    if (_items.isEmpty) return false;
    _procesando = true;
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      // Obtener datos del cliente
      final clienteSnap = await FirebaseFirestore.instance
          .collection('clientes')
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get();

      final nombreCliente = clienteSnap.docs.isNotEmpty
          ? clienteSnap.docs.first['nombre_completo'] ?? user.email
          : user.email ?? '';

      // Construir lista de items para Firestore
      final itemsMap = _items.map((i) => {
        'id_producto':   i.producto.id,
        'nombre':        i.producto.nombre,
        'marca':         i.producto.marca,
        'imagen_url':    i.producto.imagenUrl,
        'categoria':     i.producto.nombreCategoria,
        'precio_base':   i.producto.precioBase,
        'precio_con_iva': i.producto.precioConIva,
        'cantidad':      i.cantidad,
        'subtotal':      i.subtotal,
      }).toList();

      final ultimos4 = numeroTarjeta.length >= 4
          ? numeroTarjeta.substring(numeroTarjeta.length - 4)
          : '****';

      // Crear pedido en Firestore
      final pedidoRef = await FirebaseFirestore.instance
          .collection('pedidos')
          .add({
        'email_cliente':  user.email,
        'nombre_cliente': nombreCliente,
        'items':          itemsMap,
        'subtotal':       subtotal,
        'iva':            iva,
        'total_neto':     total,
        'estado':         'Pagado',
        'metodo_pago':    metodoPago,
        'ultimos4':       ultimos4,
        'nombre_tarjeta': nombreTarjeta,
        'fecha_pedido':   FieldValue.serverTimestamp(),
      });

      // Crear registro de pago vinculado
      await FirebaseFirestore.instance.collection('pagos').add({
        'id_pedido':    pedidoRef.id,
        'metodo_pago':  metodoPago,
        'monto_pagado': total,
        'ultimos4':     ultimos4,
        'fecha_pago':   FieldValue.serverTimestamp(),
      });

      // Crear detalle_pedido por cada item
      for (final item in _items) {
        await FirebaseFirestore.instance
            .collection('detalle_pedido')
            .add({
          'id_pedido':              pedidoRef.id,
          'id_variante':            item.producto.id,
          'nombre_producto':        item.producto.nombre,
          'cantidad':               item.cantidad,
          'precio_historico':       item.producto.precioBase,
          'precio_con_iva':         item.producto.precioConIva,
          'descuento_aplicado':     0,
        });
      }

      limpiar();
      return true;
    } catch (e) {
      debugPrint('Error al realizar pedido: $e');
      return false;
    } finally {
      _procesando = false;
      notifyListeners();
    }
  }

  // ── Reservar producto próximo ────────
  Future<bool> reservar(Producto producto) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      final clienteSnap = await FirebaseFirestore.instance
          .collection('clientes')
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get();

      final nombreCliente = clienteSnap.docs.isNotEmpty
          ? clienteSnap.docs.first['nombre_completo'] ?? user.email
          : user.email ?? '';

      // Verificar si ya reservó
      final yaReservo = await FirebaseFirestore.instance
          .collection('reservas')
          .where('id_producto', isEqualTo: producto.id)
          .where('email_cliente', isEqualTo: user.email)
          .get();

      if (yaReservo.docs.isNotEmpty) return false;

      await FirebaseFirestore.instance.collection('reservas').add({
        'id_producto':     producto.id,
        'nombre_producto': producto.nombre,
        'imagen_url':      producto.imagenUrl,
        'precio_base':     producto.precioBase,
        'email_cliente':   user.email,
        'nombre_cliente':  nombreCliente,
        'fecha_reserva':   FieldValue.serverTimestamp(),
        'estado':          'Reservado',
      });

      return true;
    } catch (e) {
      debugPrint('Error al reservar: $e');
      return false;
    }
  }
}