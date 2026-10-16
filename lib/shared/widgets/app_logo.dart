import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool isDark;

  const AppLogo({
    super.key,
    this.size = 40,
    this.showText = true,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CustomPaint(
          size: Size(size, size),
          painter: _YemenRealEstateLogoPainter(),
        ),
        if (showText) ...[
          const SizedBox(width: 10),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppConstants.appNameAr,
                style: GoogleFonts.cairo(
                  fontSize: size * 0.42,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textLight : AppColors.primary,
                  height: 1.1,
                ),
              ),
              Text(
                AppConstants.appNameEn,
                style: GoogleFonts.outfit(
                  fontSize: size * 0.22,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.accent,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _YemenRealEstateLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background rounded squircle
    final bgPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      Radius.circular(w * 0.25),
    );
    canvas.drawRRect(rrect, bgPaint);

    // Decorative Gold Border
    final borderPaint = Paint()
      ..color = AppColors.accent.withAlpha(200)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.04;
    canvas.drawRRect(rrect, borderPaint);

    // Architectural Qamariya Arch (Traditional Yemeni Window Curve)
    final archPaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.05
      ..strokeCap = StrokeCap.round;

    final archPath = Path()
      ..moveTo(w * 0.22, h * 0.75)
      ..lineTo(w * 0.22, h * 0.45)
      ..arcToPoint(
        Offset(w * 0.78, h * 0.45),
        radius: Radius.circular(w * 0.28),
      )
      ..lineTo(w * 0.78, h * 0.75);
    canvas.drawPath(archPath, archPaint);

    // Modern High-Rise Real Estate Tower silhouette inside the arch
    final towerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final towerPath = Path()
      ..moveTo(w * 0.35, h * 0.75)
      ..lineTo(w * 0.35, h * 0.40)
      ..lineTo(w * 0.50, h * 0.28)
      ..lineTo(w * 0.65, h * 0.40)
      ..lineTo(w * 0.65, h * 0.75)
      ..close();
    canvas.drawPath(towerPath, towerPaint);

    // Central Emerald Accent Diamond
    final diamondPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final diamondPath = Path()
      ..moveTo(w * 0.50, h * 0.42)
      ..lineTo(w * 0.56, h * 0.49)
      ..lineTo(w * 0.50, h * 0.56)
      ..lineTo(w * 0.44, h * 0.49)
      ..close();
    canvas.drawPath(diamondPath, diamondPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
