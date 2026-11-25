import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yemen_real_estate_portal/core/theme/app_fonts.dart';

void main() {
  test('uses the bundled Cairo family', () {
    final style = AppFonts.cairo(fontSize: 16);

    expect(style.fontFamily, AppFonts.family);
    expect(style.fontFamilyFallback, isNull);
  });

  test('maps Flutter font weights to the wght axis', () {
    final regular = AppFonts.cairo(fontWeight: FontWeight.w400);
    final bold = AppFonts.cairo(fontWeight: FontWeight.w700);

    expect(regular.fontVariations!.single.axis, 'wght');
    expect(regular.fontVariations!.single.value, 400.0);
    expect(bold.fontVariations!.single.value, 700.0);
  });

  test('clamps the wght axis to the bundled font range', () {
    expect(
      AppFonts.cairo(fontWeight: FontWeight.w100).fontVariations!.single.value,
      200.0,
    );
    expect(
      AppFonts.cairo(fontWeight: FontWeight.w900).fontVariations!.single.value,
      900.0,
    );
  });

  test('merges an existing text style and keeps its colour', () {
    const base = TextStyle(color: Colors.red, fontSize: 12);
    final style = AppFonts.cairo(textStyle: base, fontWeight: FontWeight.w600);

    expect(style.color, Colors.red);
    expect(style.fontSize, 12);
    expect(style.fontFamily, AppFonts.family);
    expect(style.fontVariations!.single.value, 600.0);
  });
}
