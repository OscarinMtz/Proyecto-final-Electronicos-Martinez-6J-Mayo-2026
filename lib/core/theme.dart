import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: kPrimary,
        primary: kPrimary,
        secondary: kSecondary,
        background: kBg,
        surface: kCard,
        error: kDanger,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: kBg,
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 32, fontWeight: FontWeight.w800, color: kDark),
        displayMedium: GoogleFonts.inter(
          fontSize: 26, fontWeight: FontWeight.w700, color: kDark),
        headlineLarge: GoogleFonts.inter(
          fontSize: 22, fontWeight: FontWeight.w700, color: kDark),
        headlineMedium: GoogleFonts.inter(
          fontSize: 18, fontWeight: FontWeight.w600, color: kDark),
        titleLarge: GoogleFonts.inter(
          fontSize: 16, fontWeight: FontWeight.w600, color: kDark),
        titleMedium: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w500, color: kDark),
        bodyLarge: GoogleFonts.inter(
          fontSize: 15, fontWeight: FontWeight.w400, color: kDark),
        bodyMedium: GoogleFonts.inter(
          fontSize: 13, fontWeight: FontWeight.w400, color: kSecondary),
        labelLarge: GoogleFonts.inter(
          fontSize: 13, fontWeight: FontWeight.w600, color: kDark),
        labelSmall: GoogleFonts.inter(
          fontSize: 11, fontWeight: FontWeight.w500,
          color: kSecondary, letterSpacing: 0.4),
      ),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18, fontWeight: FontWeight.w700,
          color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
        actionsIconTheme: const IconThemeData(color: Colors.white),
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),

      // Botones elevados
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
          textStyle: GoogleFonts.inter(
            fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      // Botones de texto
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: kPrimary,
          textStyle: GoogleFonts.inter(
            fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      // Botones outlined
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: kPrimary,
          side: const BorderSide(color: kPrimary, width: 1.5),
          padding: const EdgeInsets.symmetric(
            vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        ),
      ),

      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        labelStyle: GoogleFonts.inter(
          fontSize: 14, color: kSecondary),
        hintStyle: GoogleFonts.inter(
          fontSize: 14, color: kMuted),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kDanger),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 14),
      ),

      // Cards
      cardTheme: CardTheme(
        color: kCard,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: kBorder, width: 0.8),
        ),
        margin: const EdgeInsets.only(bottom: 10),
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: kPrimaryLight,
        labelStyle: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w500,
          color: kPrimary),
        padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      ),

      // BottomNavigationBar
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: kCard,
        indicatorColor: kPrimaryLight,
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return GoogleFonts.inter(
              fontSize: 11, fontWeight: FontWeight.w600,
              color: kPrimary);
          }
          return GoogleFonts.inter(
            fontSize: 11, color: kSecondary);
        }),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(color: kPrimary, size: 22);
          }
          return const IconThemeData(color: kSecondary, size: 22);
        }),
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.08),
      ),

      // NavigationDrawer
      navigationDrawerTheme: NavigationDrawerThemeData(
        backgroundColor: kCard,
        indicatorColor: kPrimaryLight,
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return GoogleFonts.inter(
              fontSize: 14, fontWeight: FontWeight.w600,
              color: kPrimary);
          }
          return GoogleFonts.inter(
            fontSize: 14, color: kSecondary);
        }),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: kBorder, thickness: 0.8, space: 1),

      // FAB
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16))),
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: kDark,
        contentTextStyle: GoogleFonts.inter(
          fontSize: 13, color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)),
      ),

      // Dialog
      dialogTheme: DialogTheme(
        backgroundColor: kCard,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18, fontWeight: FontWeight.w700, color: kDark),
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14, color: kSecondary),
      ),

      // ListTile
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16, vertical: 4),
        minLeadingWidth: 0,
      ),
    );
  }
}