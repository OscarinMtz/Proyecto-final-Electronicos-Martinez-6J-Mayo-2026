import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool _modoRegistro = false;
  bool _verPass      = false;
  bool _verPass2     = false;

  final _emailCtrl  = TextEditingController();
  final _passCtrl   = TextEditingController();
  final _nombreCtrl = TextEditingController();
  final _telCtrl    = TextEditingController();
  final _pass2Ctrl  = TextEditingController();

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400));
    _fadeAnim = CurvedAnimation(
      parent: _animCtrl, curve: Curves.easeInOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();  _passCtrl.dispose();
    _nombreCtrl.dispose(); _telCtrl.dispose();
    _pass2Ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    _animCtrl.reverse().then((_) {
      setState(() {
        _modoRegistro = !_modoRegistro;
        _emailCtrl.clear(); _passCtrl.clear();
        _nombreCtrl.clear(); _telCtrl.clear();
        _pass2Ctrl.clear();
        context.read<AppAuthProvider>().clearError();
      });
      _animCtrl.forward();
    });
  }

  Future<void> _submit() async {
    final auth = context.read<AppAuthProvider>();
    if (_modoRegistro) {
      if (_passCtrl.text != _pass2Ctrl.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Las contraseñas no coinciden')));
        return;
      }
      await auth.registrarCliente(
        nombre:   _nombreCtrl.text,
        email:    _emailCtrl.text,
        pass:     _passCtrl.text,
        telefono: _telCtrl.text,
      );
    } else {
      await auth.login(_emailCtrl.text, _passCtrl.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth  = context.watch<AppAuthProvider>();
    final size  = MediaQuery.of(context).size;
    final isWeb = size.width > 700;

    return Scaffold(
      backgroundColor: kBg,
      body: Row(children: [

        // ── Panel izquierdo (solo web) ──
        if (isWeb)
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1D4ED8), Color(0xFF2563EB),
                           Color(0xFF0EA5E9)],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16)),
                      child: const Icon(Icons.bolt,
                        color: Colors.white, size: 36)),
                    const SizedBox(height: 40),
                    const Text('ElectroAdmin',
                      style: TextStyle(
                        fontSize: 36, fontWeight: FontWeight.w800,
                        color: Colors.white)),
                    const SizedBox(height: 12),
                    Text('La plataforma más completa\npara gestionar tu tienda\nde electrónicos.',
                      style: TextStyle(
                        fontSize: 18, color: Colors.white.withOpacity(0.85),
                        height: 1.6)),
                    const SizedBox(height: 48),
                    _featureRow(Icons.inventory_2_outlined,
                      'Gestión de inventario en tiempo real'),
                    const SizedBox(height: 16),
                    _featureRow(Icons.shopping_cart_outlined,
                      'Carrito y pagos integrados'),
                    const SizedBox(height: 16),
                    _featureRow(Icons.people_outline,
                      'Panel admin y vista de cliente'),
                    const SizedBox(height: 16),
                    _featureRow(Icons.notifications_outlined,
                      'Alertas de stock y pedidos'),
                  ],
                ),
              ),
            ),
          ),

        // ── Panel derecho (formulario) ──
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isWeb ? 48 : 24,
                vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Logo móvil
                      if (!isWeb) ...[
                        Center(
                          child: Container(
                            width: 60, height: 60,
                            decoration: BoxDecoration(
                              color: kPrimary,
                              borderRadius: BorderRadius.circular(16)),
                            child: const Icon(Icons.bolt,
                              color: Colors.white, size: 36)),
                        ),
                        const SizedBox(height: 16),
                        const Center(
                          child: Text('ElectroAdmin',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: kDark))),
                        const SizedBox(height: 32),
                      ],

                      // Título
                      Text(
                        _modoRegistro
                          ? 'Crear cuenta'
                          : 'Bienvenido',
                        style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.w800,
                          color: kDark)),
                      const SizedBox(height: 6),
                      Text(
                        _modoRegistro
                          ? 'Regístrate para comprar en ElectroAdmin'
                          : 'Inicia sesión para continuar',
                        style: const TextStyle(
                          fontSize: 14, color: kSecondary)),
                      const SizedBox(height: 32),

                      // Campos registro
                      if (_modoRegistro) ...[
                        _campo(_nombreCtrl, 'Nombre completo',
                          Icons.person_outline),
                        const SizedBox(height: 14),
                        _campo(_telCtrl, 'Teléfono',
                          Icons.phone_outlined,
                          tipo: TextInputType.phone),
                        const SizedBox(height: 14),
                      ],

                      // Email
                      _campo(_emailCtrl, 'Correo electrónico',
                        Icons.email_outlined,
                        tipo: TextInputType.emailAddress),
                      const SizedBox(height: 14),

                      // Contraseña
                      _campoPass(
                        ctrl:    _passCtrl,
                        label:   'Contraseña',
                        ver:     _verPass,
                        toggle:  () => setState(() => _verPass = !_verPass),
                      ),

                      // Confirmar contraseña
                      if (_modoRegistro) ...[
                        const SizedBox(height: 14),
                        _campoPass(
                          ctrl:    _pass2Ctrl,
                          label:   'Confirmar contraseña',
                          ver:     _verPass2,
                          toggle:  () =>
                            setState(() => _verPass2 = !_verPass2),
                        ),
                      ],

                      // Error
                      if (auth.error.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: kDanger.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: kDanger.withOpacity(0.3))),
                          child: Row(children: [
                            const Icon(Icons.error_outline,
                              color: kDanger, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(auth.error,
                                style: const TextStyle(
                                  color: kDanger, fontSize: 13))),
                          ]),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Botón principal
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: auth.loading ? null : _submit,
                          style: kPrimaryButton,
                          child: auth.loading
                            ? const SizedBox(
                                width: 22, height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5))
                            : Text(
                                _modoRegistro
                                  ? 'Crear cuenta'
                                  : 'Iniciar sesión',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Divider
                      Row(children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12),
                          child: Text(
                            _modoRegistro
                              ? '¿Ya tienes cuenta?'
                              : '¿No tienes cuenta?',
                            style: const TextStyle(
                              fontSize: 13, color: kSecondary))),
                        const Expanded(child: Divider()),
                      ]),

                      const SizedBox(height: 16),

                      // Botón toggle
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: _toggle,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: kBorder, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                          child: Text(
                            _modoRegistro
                              ? 'Iniciar sesión'
                              : 'Crear cuenta nueva',
                            style: const TextStyle(
                              color: kDark,
                              fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _featureRow(IconData icon, String texto) {
    return Row(children: [
      Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: Colors.white, size: 18)),
      const SizedBox(width: 14),
      Text(texto,
        style: TextStyle(
          fontSize: 14, color: Colors.white.withOpacity(0.9))),
    ]);
  }

  Widget _campo(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType tipo = TextInputType.text,
  }) {
    return TextField(
      controller:    ctrl,
      keyboardType:  tipo,
      decoration:    kInputDecoration(label, icon: icon),
    );
  }

  Widget _campoPass({
    required TextEditingController ctrl,
    required String label,
    required bool ver,
    required VoidCallback toggle,
  }) {
    return TextField(
      controller:  ctrl,
      obscureText: !ver,
      decoration:  kInputDecoration(label, icon: Icons.lock_outlined)
          .copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            ver ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: kSecondary, size: 20),
          onPressed: toggle),
      ),
    );
  }
}