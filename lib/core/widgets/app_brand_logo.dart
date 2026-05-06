import 'package:flutter/material.dart';

class AppBrandLogo extends StatelessWidget {
  const AppBrandLogo({
    super.key,
    this.logoSize = 96,
    this.borderRadius = 24,
    this.showAppName = true,
    this.appName = 'Windify',
    this.subtitle,
    this.showShadow = true,
    this.titleStyle,
    this.subtitleStyle,
    this.spacing = 16,
    this.assetPath = 'assets/images/windify_logo.png',
  });

  final double logoSize;
  final double borderRadius;
  final bool showAppName;
  final String appName;
  final String? subtitle;
  final bool showShadow;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final double spacing;
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    final image = Container(
      width: logoSize,
      height: logoSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.14),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Theme.of(context).colorScheme.primary,
            alignment: Alignment.center,
            child: const Icon(Icons.cloud, color: Colors.white),
          ),
        ),
      ),
    );

    if (!showAppName) {
      return image;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        image,
        SizedBox(height: spacing),
        Text(
          appName,
          textAlign: TextAlign.center,
          style:
              titleStyle ??
              Theme.of(context).textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style:
                subtitleStyle ??
                Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
        ],
      ],
    );
  }
}
