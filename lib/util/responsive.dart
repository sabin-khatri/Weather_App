import 'package:flutter/material.dart';

/// Screen-size helpers for consistent layout on phones, tablets, and web.
class Responsive {
  static const double _baseWidth = 390;

  static Size size(BuildContext context) => MediaQuery.sizeOf(context);

  static EdgeInsets padding(BuildContext context) =>
      MediaQuery.paddingOf(context);

  static bool isCompact(BuildContext context) => size(context).width < 400;

  static bool isShortScreen(BuildContext context) => size(context).height < 720;

  /// Scales a value relative to a ~390px-wide reference device.
  static double sp(BuildContext context, double value) {
    final factor = (size(context).width / _baseWidth).clamp(0.82, 1.12);
    return value * factor;
  }

  static double horizontalPadding(BuildContext context) =>
      isCompact(context) ? 16 : 20;

  static double scrollBottomInset(BuildContext context) {
    final dockHeight = isCompact(context) ? 64.0 : 72.0;
    return dockHeight + padding(context).bottom + 20;
  }

  /// Fixed height for humidity / pressure / wind / visibility grid cells.
  static double detailCardHeight(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final pad = sp(context, 12) * 2;
    final icon = sp(context, 22);
    final valueLine = sp(context, 18) * 1.25 * textScale;
    final labelLines = sp(context, 11) * 1.35 * 2 * textScale;
    const gaps = 12.0;
    const safety = 16.0;
    return pad + icon + gaps + valueLine + labelLines + safety;
  }

  static double mainTempFontSize(BuildContext context) =>
      isCompact(context) ? 62 : 78;

  static double mainLottieSize(BuildContext context) =>
      isShortScreen(context) ? 110 : (isCompact(context) ? 130 : 150);

  static double cardPadding(BuildContext context) =>
      isCompact(context) ? 18 : 24;
}
