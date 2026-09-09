import 'package:flutter/painting.dart';

abstract final class AppFonts {
  static const condensedFamily = 'BarlowCondensed';

  static const bodyFamily = 'Barlow';

  static const tabular = <FontFeature>[FontFeature.tabularFigures()];

  static TextStyle condensed({
    required double size,
    FontWeight weight = FontWeight.w600,
    double? height,
    double tracking = 0,
    Color? color,
    bool tabularFigures = false,
  }) {
    return TextStyle(
      fontFamily: condensedFamily,
      fontWeight: weight,
      fontSize: size,
      height: height,
      letterSpacing: tracking * size,
      color: color,
      fontFeatures: tabularFigures ? tabular : null,
    );
  }

  static TextStyle body({
    required double size,
    FontWeight weight = FontWeight.w400,
    double? height,
    double tracking = 0,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: bodyFamily,
      fontWeight: weight,
      fontSize: size,
      height: height,
      letterSpacing: tracking * size,
      color: color,
    );
  }
}