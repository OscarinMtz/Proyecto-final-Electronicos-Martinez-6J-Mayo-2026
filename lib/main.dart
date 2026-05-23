import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/carrito_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/usuario/user_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey:            'AIzaSyD9IHwlQc3QapQUO9UKddD9xhPcrQDBtFI',
      authDomain:        'bdcrudelectronicos-65a0a.firebaseapp.com',
      projectId:         'bdcrudelectronicos-65a0a',
      storageBucket:     'bdcrudelectronicos-65a0a.firebasestorage.app',
      messagingSenderId: '203230460010',
      appId:             '1:203230460010:web:12efcc668096efe6f9f213',
    ),
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppAuthProvider()),
        ChangeNotifierProvider(create: (_) => CarritoProvider()),
      ],
      child: const ElectroAdminApp(),
    ),
  );
}

class ElectroAdminApp extends StatelessWidget {
  const ElectroAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title:                  'ElectroAdmin',
      debugShowCheckedModeBanner: false,
      theme:                  AppTheme.light,
      home:                   const AuthWrapper(),
    );
  }
}

// ═══════════════════════════════════════
// AUTH WRAPPER
// ═══════════════════════════════════════
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator()));
        }
        if (snap.hasData && snap.data != null) {
          return const RolWrapper();
        }
        return const LoginScreen();
      },
    );
  }
}

// ═══════════════════════════════════════
// ROL WRAPPER
// ═══════════════════════════════════════
class RolWrapper extends StatefulWidget {
  const RolWrapper({super.key});

  @override
  State<RolWrapper> createState() => _RolWrapperState();
}

class _RolWrapperState extends State<RolWrapper> {
  bool _listo = false;

  @override
  void initState() {
    super.initState();
    _detectar();
  }

  Future<void> _detectar() async {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    // Corregido: Ahora lee 'AppAuthProvider' en lugar de 'AuthProvider'
    await context.read<AppAuthProvider>().detectarRol(email);
    if (mounted) setState(() => _listo = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_listo) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()));
    }
    final rol = context.watch<AppAuthProvider>().rol;
    if (rol == RolUsuario.admin || rol == RolUsuario.empleado) {
      return const AdminDashboard();
    }
    return const UserDashboard();
  }
}