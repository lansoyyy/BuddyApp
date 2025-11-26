import 'package:flutter/material.dart';
import 'package:buddyapp/utils/app_colors.dart';
import 'package:buddyapp/utils/app_text_styles.dart';

enum ButtonType {
  primary,
  secondary,
  outline,
  ghost,
  danger,
  success,
}

enum ButtonSize {
  small,
  medium,
  large,
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final Widget? icon;
  final double? width;
  final double? height;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = _getButtonStyle();
    final textStyle = _getTextStyle();
    final padding = _getPadding();
    final borderRadius = BorderRadius.circular(8);

    Widget buttonChild = _buildButtonContent(textStyle);

    if (isLoading) {
      buttonChild = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getLoadingColor(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Loading...',
            style: textStyle,
          ),
        ],
      );
    }

    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonStyle.backgroundColor,
          foregroundColor: buttonStyle.foregroundColor,
          elevation: buttonStyle.elevation,
          shadowColor: buttonStyle.shadowColor,
          side: buttonStyle.side,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius,
          ),
          padding: padding,
        ),
        child: buttonChild,
      ),
    );
  }

  Widget _buildButtonContent(TextStyle textStyle) {
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon!,
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: textStyle.copyWith(color: Colors.blue),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: textStyle,
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
    );
  }

  ButtonStyleData _getButtonStyle() {
    switch (type) {
      case ButtonType.primary:
        return ButtonStyleData(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 2,
          shadowColor: AppColors.shadow,
          side: null,
        );
      case ButtonType.secondary:
        return ButtonStyleData(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.textOnSecondary,
          elevation: 2,
          shadowColor: AppColors.shadow,
          side: null,
        );
      case ButtonType.outline:
        return ButtonStyleData(
          backgroundColor: AppColors.transparent,
          foregroundColor: AppColors.primary,
          elevation: 0,
          shadowColor: AppColors.transparent,
          side: const BorderSide(color: AppColors.primary, width: 1),
        );
      case ButtonType.ghost:
        return ButtonStyleData(
          backgroundColor: AppColors.transparent,
          foregroundColor: AppColors.primary,
          elevation: 0,
          shadowColor: AppColors.transparent,
          side: null,
        );
      case ButtonType.danger:
        return ButtonStyleData(
          backgroundColor: AppColors.error,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 2,
          shadowColor: AppColors.shadow,
          side: null,
        );
      case ButtonType.success:
        return ButtonStyleData(
          backgroundColor: AppColors.success,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 2,
          shadowColor: AppColors.shadow,
          side: null,
        );
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case ButtonSize.small:
        return AppTextStyles.buttonSmall;
      case ButtonSize.medium:
        return AppTextStyles.buttonMedium;
      case ButtonSize.large:
        return AppTextStyles.buttonLarge;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  Color _getLoadingColor() {
    switch (type) {
      case ButtonType.primary:
      case ButtonType.outline:
      case ButtonType.ghost:
        return AppColors.textOnPrimary;
      case ButtonType.secondary:
        return AppColors.textOnSecondary;
      case ButtonType.danger:
        return AppColors.textOnPrimary;
      case ButtonType.success:
        return AppColors.textOnPrimary;
    }
  }
}

class ButtonStyleData {
  final Color backgroundColor;
  final Color foregroundColor;
  final double elevation;
  final Color shadowColor;
  final BorderSide? side;

  ButtonStyleData({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.elevation,
    required this.shadowColor,
    this.side,
  });
}
