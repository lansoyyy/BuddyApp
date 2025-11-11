import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:buddyapp/utils/app_colors.dart';
import 'package:buddyapp/utils/app_text_styles.dart';

enum LoadingType {
  spinner,
  dots,
  pulse,
  wave,
  cube,
  circle,
  fadingCircle,
  dualRing,
  hourGlass,
  pouringHourGlass,
  ripple,
  rotatingCircle,
  rotatingPlain,
  spinningCircle,
  threeBounce,
  threeInOut,
  wanderingCubes,
  waveIndicator,
  pianoWave,
  dancingSquare,
}

class LoadingWidget extends StatelessWidget {
  final String? message;
  final LoadingType type;
  final Color? color;
  final double size;
  final bool isOverlay;

  const LoadingWidget({
    super.key,
    this.message,
    this.type = LoadingType.spinner,
    this.color,
    this.size = 50.0,
    this.isOverlay = false,
  });

  @override
  Widget build(BuildContext context) {
    final loadingColor = color ?? AppColors.primary;
    final loadingWidget = _buildLoadingWidget(loadingColor);

    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        loadingWidget,
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: AppTextStyles.bodyMedium.copyWith(
              color: loadingColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (isOverlay) {
      return Container(
        color: AppColors.black.withOpacity(0.5),
        child: Center(child: content),
      );
    }

    return Center(child: content);
  }

  Widget _buildLoadingWidget(Color color) {
    switch (type) {
      case LoadingType.spinner:
        return SpinKitRotatingCircle(
          color: color,
          size: size,
        );
      case LoadingType.dots:
        return SpinKitThreeBounce(
          color: color,
          size: size,
        );
      case LoadingType.pulse:
        return SpinKitPulse(
          color: color,
          size: size,
        );
      case LoadingType.wave:
        return SpinKitWave(
          color: color,
          size: size,
        );
      case LoadingType.cube:
        return SpinKitCubeGrid(
          color: color,
          size: size,
        );
      case LoadingType.circle:
        return SpinKitCircle(
          color: color,
          size: size,
        );
      case LoadingType.fadingCircle:
        return SpinKitFadingCircle(
          color: color,
          size: size,
        );
      case LoadingType.dualRing:
        return SpinKitDualRing(
          color: color,
          size: size,
        );
      case LoadingType.hourGlass:
        return SpinKitHourGlass(
          color: color,
          size: size,
        );
      case LoadingType.pouringHourGlass:
        return SpinKitPouringHourGlass(
          color: color,
          size: size,
        );
      case LoadingType.ripple:
        return SpinKitRipple(
          color: color,
          size: size,
        );
      case LoadingType.rotatingCircle:
        return SpinKitRotatingCircle(
          color: color,
          size: size,
        );
      case LoadingType.rotatingPlain:
        return SpinKitRotatingPlain(
          color: color,
          size: size,
        );
      case LoadingType.spinningCircle:
        return SpinKitSpinningCircle(
          color: color,
          size: size,
        );
      case LoadingType.threeBounce:
        return SpinKitThreeBounce(
          color: color,
          size: size,
        );
      case LoadingType.threeInOut:
        return SpinKitThreeInOut(
          color: color,
          size: size,
        );
      case LoadingType.wanderingCubes:
        return SpinKitWanderingCubes(
          color: color,
          size: size,
        );
      case LoadingType.waveIndicator:
        return SpinKitWave(
          color: color,
          size: size,
        );
      case LoadingType.pianoWave:
        return SpinKitPianoWave(
          color: color,
          size: size,
        );
      case LoadingType.dancingSquare:
        return SpinKitDancingSquare(
          color: color,
          size: size,
        );
    }
  }
}

class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? message;
  final LoadingType type;
  final Color? color;
  final double size;

  const LoadingOverlay({
    super.key,
    required this.child,
    this.isLoading = false,
    this.message,
    this.type = LoadingType.spinner,
    this.color,
    this.size = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: AppColors.black.withOpacity(0.3),
            child: LoadingWidget(
              message: message,
              type: type,
              color: color,
              size: size,
              isOverlay: true,
            ),
          ),
      ],
    );
  }
}

class ButtonLoadingWidget extends StatelessWidget {
  final String? message;
  final Color? color;
  final double size;

  const ButtonLoadingWidget({
    super.key,
    this.message,
    this.color,
    this.size = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    final loadingColor = color ?? AppColors.textOnPrimary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(loadingColor),
          ),
        ),
        if (message != null) ...[
          const SizedBox(width: 8),
          Text(
            message!,
            style: AppTextStyles.buttonSmall.copyWith(
              color: loadingColor,
            ),
          ),
        ],
      ],
    );
  }
}

class PageLoadingWidget extends StatelessWidget {
  final String? message;
  final LoadingType type;
  final Color? color;
  final double size;

  const PageLoadingWidget({
    super.key,
    this.message,
    this.type = LoadingType.spinner,
    this.color,
    this.size = 60.0,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Center(
        child: LoadingWidget(
          message: message ?? 'Loading...',
          type: type,
          color: color,
          size: size,
        ),
      ),
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? icon;
  final Widget? action;
  final Color? color;

  const EmptyStateWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.action,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = color ?? AppColors.textSecondary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(height: 24),
            ] else ...[
              Icon(
                Icons.inbox_outlined,
                size: 64,
                color: textColor,
              ),
              const SizedBox(height: 24),
            ],
            Text(
              title,
              style: AppTextStyles.h5.copyWith(
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            if (action != null) action!,
          ],
        ),
      ),
    );
  }
}

class ErrorStateWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onRetry;
  final Widget? customAction;
  final Color? color;

  const ErrorStateWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.onRetry,
    this.customAction,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final errorColor = color ?? AppColors.error;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: errorColor,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: AppTextStyles.h5.copyWith(
                color: errorColor,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            if (customAction != null)
              customAction!
            else if (onRetry != null)
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: errorColor,
                  foregroundColor: AppColors.textOnPrimary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
