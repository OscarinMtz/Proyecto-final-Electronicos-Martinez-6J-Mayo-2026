import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum RolUsuario { admin, empleado, cliente, desconocido }

class AppAuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool _loading = false;
  bool get loading => _loading;

  String _error = '';
  String get error => _error;

  RolUsuario _rol = RolUsuario.desconocido;
  RolUsuario get rol => _rol;

  Map<String, dynamic>? _datosUsuario;
  Map<String, dynamic>? get datosUsuario => _datosUsuario;

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentUser != null;

  void _setLoading(bool v) { _loading = v; notifyListeners(); }
  void _setError(String v)  { _error   = v; notifyListeners(); }
  void clearError()          { _error   = ''; notifyListeners(); }

  // ── Detectar rol ─────────────────────
  Future<RolUsuario> detectarRol(String email) async {
    try {
      final empSnap = await _db
          .collection('empleados')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (empSnap.docs.isNotEmpty) {
        final d = empSnap.docs.first.data();
        _datosUsuario = {'id': empSnap.docs.first.id, ...d};
        final rolStr = d['rol'] ?? 'Vendedor';
        _rol = rolStr == 'Admin'
            ? RolUsuario.admin
            : RolUsuario.empleado;
        notifyListeners();
        return _rol;
      }

      final cliSnap = await _db
          .collection('clientes')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (cliSnap.docs.isNotEmpty) {
        _datosUsuario = {
          'id': cliSnap.docs.first.id,
          ...cliSnap.docs.first.data()
        };
        _rol = RolUsuario.cliente;
        notifyListeners();
        return _rol;
      }
    } catch (e) {
      debugPrint('Error detectando rol: $e');
    }

    _rol = RolUsuario.desconocido;
    notifyListeners();
    return _rol;
  }

  // ── Login ─────────────────────────────
  Future<bool> login(String email, String pass) async {
    _setLoading(true);
    _setError('');
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: pass,
      );
      await detectarRol(email.trim());
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_traducirError(e.code));
      _setLoading(false);
      return false;
    }
  }

  // ── Registro cliente ──────────────────
  Future<bool> registrarCliente({
    required String nombre,
    required String email,
    required String pass,
    required String telefono,
  }) async {
    _setLoading(true);
    _setError('');
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: pass,
      );

      await _db.collection('clientes').add({
        'uid':             cred.user!.uid,
        'nombre_completo': nombre.trim(),
        'email':           email.trim(),
        'telefono':        telefono.trim(),
        'dni':             '',
        'fecha_registro':  FieldValue.serverTimestamp(),
      });

      _rol = RolUsuario.cliente;
      _datosUsuario = {
        'nombre_completo': nombre.trim(),
        'email':           email.trim(),
        'telefono':        telefono.trim(),
      };
      _setLoading(false);
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_traducirError(e.code));
      _setLoading(false);
      return false;
    }
  }

  // ── Actualizar perfil cliente ─────────
  Future<bool> actualizarPerfil({
    required String docId,
    required String nombre,
    required String telefono,
    required String dni,
  }) async {
    _setLoading(true);
    try {
      await _db.collection('clientes').doc(docId).update({
        'nombre_completo': nombre.trim(),
        'telefono':        telefono.trim(),
        'dni':             dni.trim(),
      });
      if (_datosUsuario != null) {
        _datosUsuario!['nombre_completo'] = nombre.trim();
        _datosUsuario!['telefono']        = telefono.trim();
        _datosUsuario!['dni']             = dni.trim();
      }
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setLoading(false);
      return false;
    }
  }

  // ── Logout con confirmación ───────────
  Future<bool> logout(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text(
          '¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444)),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar sesión')),
        ],
      ),
    );

    if (confirmar == true) {
      await _auth.signOut();
      _rol = RolUsuario.desconocido;
      _datosUsuario = null;
      notifyListeners();
      return true;
    }
    return false;
  }

  // ── Traducir errores Firebase ─────────
  String _traducirError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No existe una cuenta con ese correo.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos.';
      case 'email-already-in-use':
        return 'Ese correo ya está registrado.';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres.';
      case 'invalid-email':
        return 'El formato del correo no es válido.';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde.';
      case 'network-request-failed':
        return 'Sin conexión. Verifica tu internet.';
      default:
        return 'Error inesperado. Intenta de nuevo.';
    }
  }
}