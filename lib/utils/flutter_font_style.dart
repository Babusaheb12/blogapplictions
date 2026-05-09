import 'package:flutter/material.dart';
import 'size_config.dart';

class FTextStyle {
  static TextStyle heading(BuildContext context) => TextStyle(
    fontFamily: 'DM Sans',
    fontSize: getResponsiveFontSize(context, 22),
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static TextStyle subHeading(BuildContext context) => TextStyle(
    fontFamily: 'DM Sans',
    fontSize: getResponsiveFontSize(context, 20),
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );

  static TextStyle title(BuildContext context) => TextStyle(
    fontFamily: 'DM Sans',
    fontSize: getResponsiveFontSize(context, 18),
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );

  static TextStyle body(BuildContext context) => TextStyle(
    fontFamily: 'DM Sans',
    fontSize: getResponsiveFontSize(context, 16),
    fontWeight: FontWeight.w400,
    color: Colors.black,
  );

  static TextStyle small(BuildContext context) => TextStyle(
    fontFamily: 'DM Sans',
    fontSize: getResponsiveFontSize(context, 14),
    fontWeight: FontWeight.w400,
    color: Colors.black,
  );

  static TextStyle button(BuildContext context) => TextStyle(
    fontFamily: 'DM Sans',
    fontSize: getResponsiveFontSize(context, 16),
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );

  static TextStyle hint(BuildContext context) => TextStyle(
    fontFamily: 'DM Sans',
    fontSize: getResponsiveFontSize(context, 14),
    fontWeight: FontWeight.w400,
    color: Colors.black.withOpacity(0.5),
  );

  static double getResponsiveFontSize(BuildContext context, double size) {
    double textScale = MediaQuery.of(context).textScaleFactor;

    //     // return baseSize * 0.0030 * size * textScale;
    return size * textScale;
  }
}

//  style: FTextStyle.messageTittle(context).copyWith(color: AppColors.brand), // sortFilter
