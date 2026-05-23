import 'package:flutter/material.dart';

// ═══════════════════════════════════════
// COLORES
// ═══════════════════════════════════════
const kPrimary      = Color(0xFF2563EB);
const kPrimaryDark  = Color(0xFF1D4ED8);
const kPrimaryLight = Color(0xFFDBEAFE);
const kSecondary    = Color(0xFF64748B);
const kAccent       = Color(0xFF0EA5E9);
const kBg           = Color(0xFFF1F5F9);
const kCard         = Colors.white;
const kSuccess      = Color(0xFF10B981);
const kWarning      = Color(0xFFF59E0B);
const kDanger       = Color(0xFFEF4444);
const kDark         = Color(0xFF1E293B);
const kMuted        = Color(0xFF94A3B8);
const kBorder       = Color(0xFFE2E8F0);

// ═══════════════════════════════════════
// SOMBRAS
// ═══════════════════════════════════════
List<BoxShadow> kShadowSm = [
  BoxShadow(color: Colors.black.withOpacity(0.06),
    blurRadius: 8, offset: const Offset(0, 2)),
];
List<BoxShadow> kShadowMd = [
  BoxShadow(color: Colors.black.withOpacity(0.08),
    blurRadius: 16, offset: const Offset(0, 4)),
];
List<BoxShadow> kShadowLg = [
  BoxShadow(color: Colors.black.withOpacity(0.12),
    blurRadius: 32, offset: const Offset(0, 8)),
];

// ═══════════════════════════════════════
// BORDER RADIUS
// ═══════════════════════════════════════
const kRadiusSm = BorderRadius.all(Radius.circular(8));
const kRadiusMd = BorderRadius.all(Radius.circular(12));
const kRadiusLg = BorderRadius.all(Radius.circular(16));
const kRadiusXl = BorderRadius.all(Radius.circular(24));

// ═══════════════════════════════════════
// IVA
// ═══════════════════════════════════════
const double kIVA = 0.08;

// ═══════════════════════════════════════
// ESTILOS DE TEXTO
// ═══════════════════════════════════════
const kTitleStyle = TextStyle(
  fontSize: 22, fontWeight: FontWeight.w700, color: kDark);

const kSubtitleStyle = TextStyle(
  fontSize: 14, fontWeight: FontWeight.w400, color: kSecondary);

const kLabelStyle = TextStyle(
  fontSize: 12, fontWeight: FontWeight.w600,
  color: kSecondary, letterSpacing: 0.5);

// ═══════════════════════════════════════
// DECORACIÓN DE INPUTS
// ═══════════════════════════════════════
InputDecoration kInputDecoration(String label, {IconData? icon, String? hint}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: icon != null ? Icon(icon, color: kSecondary, size: 20) : null,
    filled: true,
    fillColor: const Color(0xFFF8FAFC),
    labelStyle: const TextStyle(color: kSecondary, fontSize: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: kBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: kBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: kPrimary, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16, vertical: 14),
  );
}

// ═══════════════════════════════════════
// BOTÓN PRIMARIO
// ═══════════════════════════════════════
ButtonStyle kPrimaryButton = ElevatedButton.styleFrom(
  backgroundColor: kPrimary,
  foregroundColor: Colors.white,
  elevation: 0,
  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
);

ButtonStyle kDangerButton = ElevatedButton.styleFrom(
  backgroundColor: kDanger,
  foregroundColor: Colors.white,
  elevation: 0,
  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
);