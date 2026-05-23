import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/carrito_provider.dart';

class PagoScreen extends StatefulWidget {
  const PagoScreen({super.key});
  @override
  State<PagoScreen> createState() => _PagoScreenState();
}

class _PagoScreenState extends State<PagoScreen> {
  final _numeroCtrl  = TextEditingController();
  final _nombreCtrl  = TextEditingController();
  final _expCtrl     = TextEditingController();
  final _cvvCtrl     = TextEditingController();
  String _metodo     = 'Crédito';
  bool _verCvv       = false;

  @override
  void dispose() {
    _numeroCtrl.dispose(); _nombreCtrl.dispose();
    _expCtrl.dispose();    _cvvCtrl.dispose();
    super.dispose();
  }

  bool get _formularioValido =>
    _numeroCtrl.text.replaceAll(' ', '').length == 16 &&
    _nombreCtrl.text.trim().isNotEmpty &&
    _expCtrl.text.length == 5 &&
    _cvvCtrl.text.length >= 3;

  Future<void> _pagar() async {
    if (!_formularioValido) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa todos los campos correctamente'),
          backgroundColor: kDanger));
      return;
    }

    // Diálogo de confirmación
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar pago'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('¿Confirmas el pago con:',
              style: TextStyle(color: kSecondary)),
            const SizedBox(height: 12),
            _filaConfirm('Tarjeta',
              '**** **** **** ${_numeroCtrl.text.replaceAll(' ', '').substring(12)}'),
            _filaConfirm('Titular', _nombreCtrl.text),
            _filaConfirm('Método', 'Tarjeta de $_metodo'),
            const SizedBox(height: 12),
            Consumer<CarritoProvider>(
              builder: (_, c, __) => Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kPrimaryLight,
                  borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total a pagar',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: kPrimary)),
                    Text(
                      '\$${c.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: kPrimary)),
                  ]))),
          ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar')),
          ElevatedButton(
            style: kPrimaryButton,
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar y pagar')),
        ],
      ),
    );

    if (confirmar != true) return;

    // Procesar pago
    final carrito = context.read<CarritoProvider>();
    final ok = await carrito.realizarPedido(
      numeroTarjeta: _numeroCtrl.text.replaceAll(' ', ''),
      nombreTarjeta: _nombreCtrl.text.trim(),
      expiracion:    _expCtrl.text,
      cvv:           _cvvCtrl.text,
      metodoPago:    'Tarjeta de $_metodo',
    );

    if (!mounted) return;

    if (ok) {
      _mostrarExito();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al procesar el pago. Intenta de nuevo.'),
          backgroundColor: kDanger));
    }
  }

  void _mostrarExito() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80, height: 80,
                decoration: const BoxDecoration(
                  color: kSuccess,
                  shape: BoxShape.circle),
                child: const Icon(Icons.check,
                  color: Colors.white, size: 44)),
              const SizedBox(height: 20),
              const Text('¡Pago exitoso!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: kDark)),
              const SizedBox(height: 8),
              const Text(
                'Tu pedido ha sido registrado.\nPuedes verlo en "Mis Pedidos".',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: kSecondary,
                  height: 1.5)),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: kPrimaryButton,
                  onPressed: () {
                    Navigator.pop(context);      // cierra dialog
                    Navigator.pop(context);      // cierra pago
                    Navigator.pop(context);      // cierra carrito
                  },
                  child: const Text('Ver mis pedidos')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final carrito = context.watch<CarritoProvider>();

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(title: const Text('Pago seguro')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [

          // ── Vista previa tarjeta ───────
          _TarjetaVisual(
            numero:  _numeroCtrl.text,
            nombre:  _nombreCtrl.text,
            expira:  _expCtrl.text,
            metodo:  _metodo,
          ),
          const SizedBox(height: 24),

          // ── Selector método ────────────
          Container(
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kBorder)),
            child: Row(children: [
              _metodoBtn('Crédito',  Icons.credit_card),
              _metodoBtn('Débito',   Icons.account_balance_outlined),
            ]),
          ),
          const SizedBox(height: 20),

          // ── Formulario ────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kBorder),
              boxShadow: kShadowSm),
            child: Column(children: [

              // Número tarjeta
              TextField(
                controller: _numeroCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _TarjetaFormatter(),
                ],
                maxLength: 19,
                onChanged: (_) => setState(() {}),
                decoration: kInputDecoration(
                  'Número de tarjeta',
                  icon: Icons.credit_card,
                ).copyWith(counterText: ''),
              ),
              const SizedBox(height: 14),

              // Nombre titular
              TextField(
                controller: _nombreCtrl,
                textCapitalization: TextCapitalization.characters,
                onChanged: (_) => setState(() {}),
                decoration: kInputDecoration(
                  'Nombre del titular',
                  icon: Icons.person_outline),
              ),
              const SizedBox(height: 14),

              // Expiración y CVV
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _expCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _ExpFormatter(),
                    ],
                    maxLength: 5,
                    onChanged: (_) => setState(() {}),
                    decoration: kInputDecoration(
                      'MM/AA',
                      icon: Icons.calendar_month_outlined,
                    ).copyWith(counterText: ''),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _cvvCtrl,
                    keyboardType: TextInputType.number,
                    obscureText: !_verCvv,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly],
                    maxLength: 4,
                    onChanged: (_) => setState(() {}),
                    decoration: kInputDecoration(
                      'CVV',
                      icon: Icons.lock_outline,
                    ).copyWith(
                      counterText: '',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _verCvv
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                          size: 18, color: kSecondary),
                        onPressed: () =>
                          setState(() => _verCvv = !_verCvv))),
                  ),
                ),
              ]),
            ]),
          ),
          const SizedBox(height: 20),

          // ── Resumen pedido ─────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kBorder)),
            child: Column(children: [
              _filaResumen('Subtotal',
                '\$${carrito.subtotal.toStringAsFixed(2)}'),
              const SizedBox(height: 6),
              _filaResumen('IVA (8%)',
                '\$${carrito.iva.toStringAsFixed(2)}',
                color: kSecondary),
              const Divider(height: 20),
              _filaResumen(
                'Total',
                '\$${carrito.total.toStringAsFixed(2)}',
                grande: true),
            ]),
          ),
          const SizedBox(height: 20),

          // ── Seguridad ─────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 14, color: kSuccess),
              const SizedBox(width: 6),
              const Text('Pago 100% seguro y encriptado',
                style: TextStyle(
                  fontSize: 12, color: kSecondary)),
            ]),
          const SizedBox(height: 20),

          // ── Botón pagar ───────────────
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: carrito.procesando ? null : _pagar,
              style: kPrimaryButton,
              child: carrito.procesando
                ? const SizedBox(
                    width: 24, height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock_outline, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Pagar \$${carrito.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700)),
                    ]),
            ),
          ),
          const SizedBox(height: 32),
        ]),
      ),
    );
  }

  Widget _metodoBtn(String label, IconData icon) {
    final sel = _metodo == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _metodo = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: sel ? kPrimaryLight : Colors.transparent,
            borderRadius: BorderRadius.circular(11)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                size: 18,
                color: sel ? kPrimary : kSecondary),
              const SizedBox(width: 6),
              Text(label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: sel ? kPrimary : kSecondary)),
            ]),
        ),
      ),
    );
  }

  Widget _filaConfirm(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        Text('$label: ',
          style: const TextStyle(
            color: kSecondary, fontSize: 13)),
        Text(valor,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13, color: kDark)),
      ]));
  }

  Widget _filaResumen(
    String label, String valor, {
    Color color = kDark,
    bool grande = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
          style: TextStyle(
            fontSize: grande ? 15 : 13,
            fontWeight: grande
              ? FontWeight.w700 : FontWeight.w400,
            color: grande ? kDark : kSecondary)),
        Text(valor,
          style: TextStyle(
            fontSize: grande ? 18 : 13,
            fontWeight: FontWeight.w700,
            color: grande ? kPrimary : color)),
      ]);
  }
}

// ═══════════════════════════════════════
// VISTA PREVIA TARJETA
// ═══════════════════════════════════════
class _TarjetaVisual extends StatelessWidget {
  final String numero;
  final String nombre;
  final String expira;
  final String metodo;

  const _TarjetaVisual({
    required this.numero,
    required this.nombre,
    required this.expira,
    required this.metodo,
  });

  @override
  Widget build(BuildContext context) {
    final num = numero.isEmpty
      ? '**** **** **** ****' : numero.padRight(19, '*');

    return Container(
      width: double.infinity,
      height: 190,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1D4ED8), Color(0xFF2563EB),
                   Color(0xFF0EA5E9)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8))
        ]),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.bolt,
                  color: Colors.white, size: 28),
                Text(metodo.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1)),
              ]),
            const Spacer(),
            Text(num,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: 3)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TITULAR',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 10, letterSpacing: 1)),
                    const SizedBox(height: 2),
                    Text(
                      nombre.isEmpty ? 'NOMBRE APELLIDO' : nombre,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                  ]),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('EXPIRA',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 10, letterSpacing: 1)),
                    const SizedBox(height: 2),
                    Text(expira.isEmpty ? 'MM/AA' : expira,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                  ]),
              ]),
          ]),
      ),
    );
  }
}

// ═══════════════════════════════════════
// FORMATEADORES
// ═══════════════════════════════════════
class _TarjetaFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue old, TextEditingValue nuevo) {
    final digits = nuevo.text.replaceAll(' ', '');
    final buf = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buf.write(' ');
      buf.write(digits[i]);
    }
    final str = buf.toString();
    return nuevo.copyWith(
      text: str,
      selection: TextSelection.collapsed(offset: str.length));
  }
}

class _ExpFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue old, TextEditingValue nuevo) {
    final digits = nuevo.text.replaceAll('/', '');
    if (digits.length >= 2) {
      final str = '${digits.substring(0, 2)}/${digits.substring(2)}';
      return nuevo.copyWith(
        text: str,
        selection: TextSelection.collapsed(offset: str.length));
    }
    return nuevo;
  }
}