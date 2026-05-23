import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Categoria {
  final String id;
  final String nombre;
  final String descripcion;
  final String icono;

  Categoria({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.icono,
  });

  factory Categoria.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Categoria(
      id:          doc.id,
      nombre:      d['nombre']      ?? '',
      descripcion: d['descripcion'] ?? '',
      icono:       d['icono']       ?? 'devices',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre':      nombre,
      'descripcion': descripcion,
      'icono':       icono,
    };
  }

  // Icono visual según nombre
  IconData get iconData {
    switch (icono) {
      case 'laptop':     return Icons.laptop;
      case 'mouse':      return Icons.mouse;
      case 'monitor':    return Icons.monitor;
      case 'headphones': return Icons.headphones;
      case 'phone':      return Icons.smartphone;
      case 'tablet':     return Icons.tablet;
      case 'keyboard':   return Icons.keyboard;
      case 'camera':     return Icons.camera_alt;
      case 'speaker':    return Icons.speaker;
      case 'tv':         return Icons.tv;
      default:           return Icons.devices;
    }
  }
}