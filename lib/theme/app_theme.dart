import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HellTheme {
  // 核心配色
  static const Color bloodRed = Color(0xFFCC0000);
  static const Color deepRed = Color(0xFF8B0000);
  static const Color darkBlood = Color(0xFF3D0000);
  static const Color voidBlack = Color(0xFF0A0000);
  static const Color ashBlack = Color(0xFF1A0A0A);
  static const Color paperBlack = Color(0xFF140808);
  static const Color dimRed = Color(0xFF4A0A0A);
  static const Color ghostWhite = Color(0xFFE8D5C4);
  static const Color ashWhite = Color(0xFFB8A090);
  static const Color rustRed = Color(0xFF8B2020);
  static const Color cinnabar = Color(0xFFE03030);

  static ThemeData get theme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: voidBlack,
        primaryColor: bloodRed,
        colorScheme: const ColorScheme.dark(
          primary: bloodRed,
          secondary: cinnabar,
          surface: ashBlack,
          error: cinnabar,
        ),
        textTheme: GoogleFonts.notoSerifScTextTheme(
          const TextTheme(
            bodyLarge: TextStyle(color: ghostWhite),
            bodyMedium: TextStyle(color: ashWhite),
            bodySmall: TextStyle(color: ashWhite),
          ),
        ),
        iconTheme: const IconThemeData(color: ashWhite, size: 20),
        dividerColor: dimRed,
      );

  // 装饰性边框样式（中式边框）
  static BoxDecoration panelDecoration = BoxDecoration(
    color: ashBlack,
    border: Border.all(color: dimRed, width: 0.8),
    boxShadow: [
      BoxShadow(
        color: bloodRed.withOpacity(0.08),
        blurRadius: 12,
        spreadRadius: 0,
      ),
    ],
  );

  static BoxDecoration addressBarDecoration = BoxDecoration(
    color: paperBlack,
    border: Border.all(color: rustRed, width: 0.6),
    borderRadius: BorderRadius.circular(2),
  );

  // 中式装饰角
  static Widget cornerDecor({double size = 10, Color? color}) {
    final c = color ?? dimRed;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _CornerPainter(c)),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  _CornerPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset.zero, Offset(size.width, 0), paint);
    canvas.drawLine(Offset.zero, Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(_) => false;
}