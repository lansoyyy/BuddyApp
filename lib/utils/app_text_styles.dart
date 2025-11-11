import 'package:flutter/material.dart';
import 'package:buddyapp/utils/app_colors.dart';

class AppTextStyles {
  // Font Families
  static const String fontFamily = 'Urbanist';
  static const String fontFamilyMedium = 'Urbanist';
  static const String fontFamilyBold = 'Urbanist';

  // Heading Styles
  static TextStyle get h1 => TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        fontFamily: fontFamilyBold,
        color: AppColors.textPrimary,
        height: 1.2,
      );

  static TextStyle get h2 => TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        fontFamily: fontFamilyBold,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  static TextStyle get h3 => TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        fontFamily: fontFamilyBold,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  static TextStyle get h4 => TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: fontFamilyMedium,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  static TextStyle get h5 => TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        fontFamily: fontFamilyMedium,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  static TextStyle get h6 => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontFamily: fontFamilyMedium,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  // Body Text Styles
  static TextStyle get bodyLarge => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        fontFamily: fontFamily,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get bodyMedium => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        fontFamily: fontFamily,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get bodySmall => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        fontFamily: fontFamily,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  // Label Styles
  static TextStyle get labelLarge => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        fontFamily: fontFamilyMedium,
        color: AppColors.textSecondary,
        height: 1.4,
      );

  static TextStyle get labelMedium => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        fontFamily: fontFamilyMedium,
        color: AppColors.textSecondary,
        height: 1.4,
      );

  static TextStyle get labelSmall => TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        fontFamily: fontFamilyMedium,
        color: AppColors.textTertiary,
        height: 1.3,
      );

  // Caption Styles
  static TextStyle get caption => TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.normal,
        fontFamily: fontFamily,
        color: AppColors.textTertiary,
        height: 1.3,
      );

  // Button Styles
  static TextStyle get buttonLarge => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontFamily: fontFamilyMedium,
        color: AppColors.textOnPrimary,
        height: 1.2,
      );

  static TextStyle get buttonMedium => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        fontFamily: fontFamilyMedium,
        color: AppColors.textOnPrimary,
        height: 1.2,
      );

  static TextStyle get buttonSmall => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        fontFamily: fontFamilyMedium,
        color: AppColors.textOnPrimary,
        height: 1.2,
      );

  // Input Field Styles
  static TextStyle get inputText => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        fontFamily: fontFamily,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  static TextStyle get inputLabel => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        fontFamily: fontFamilyMedium,
        color: AppColors.textSecondary,
        height: 1.3,
      );

  static TextStyle get inputHint => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        fontFamily: fontFamily,
        color: AppColors.textTertiary,
        height: 1.4,
      );

  // Status Styles
  static TextStyle get success => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        fontFamily: fontFamilyMedium,
        color: AppColors.success,
        height: 1.4,
      );

  static TextStyle get warning => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        fontFamily: fontFamilyMedium,
        color: AppColors.warning,
        height: 1.4,
      );

  static TextStyle get error => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        fontFamily: fontFamilyMedium,
        color: AppColors.error,
        height: 1.4,
      );

  static TextStyle get info => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        fontFamily: fontFamilyMedium,
        color: AppColors.info,
        height: 1.4,
      );

  // Custom Methods
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  static TextStyle withSize(TextStyle style, double fontSize) {
    return style.copyWith(fontSize: fontSize);
  }

  static TextStyle withWeight(TextStyle style, FontWeight fontWeight) {
    return style.copyWith(fontWeight: fontWeight);
  }

  static TextStyle withOpacity(TextStyle style, double opacity) {
    return style.copyWith(color: style.color?.withOpacity(opacity));
  }
}
