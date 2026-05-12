import 'package:flutter/material.dart';

enum CustomButtonVariant { filled, outlined }

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height = 56,
    this.width,
    this.variant = CustomButtonVariant.filled,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.prefix,
    this.suffix,
    this.prefixIcon,
    this.suffixIcon,
    this.iconSize = 20,
  });

  final String label;
  final VoidCallback? onPressed;
  final double height;
  final double? width;
  final CustomButtonVariant variant;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final Widget? prefix;
  final Widget? suffix;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultBg = theme.colorScheme.primary;
    final isFilled = variant == CustomButtonVariant.filled;

    final bg = backgroundColor ?? (isFilled ? defaultBg : Colors.transparent);
    final fg = foregroundColor ?? (isFilled ? Colors.white : defaultBg);
    final side = borderColor ?? Colors.black.withValues(alpha: 0.08);
    final radius = BorderRadius.circular(height / 2);

    final prefixWidget =
        prefix ??
        (prefixIcon == null
            ? null
            : Icon(prefixIcon, size: iconSize, color: fg));
    final suffixWidget =
        suffix ??
        (suffixIcon == null
            ? null
            : Icon(suffixIcon, size: iconSize, color: fg));

    final content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (prefixWidget != null) ...[prefixWidget, const SizedBox(width: 10)],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
              color: fg,
            ),
          ),
        ),
        if (suffixWidget != null) ...[const SizedBox(width: 10), suffixWidget],
      ],
    );

    final buttonChild = isFilled
        ? ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: bg,
              foregroundColor: fg,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: radius),
            ),
            child: content,
          )
        : OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              backgroundColor: bg,
              foregroundColor: fg,
              elevation: 0,
              side: BorderSide(color: side),
              shape: RoundedRectangleBorder(borderRadius: radius),
            ),
            child: content,
          );

    if (width != null) {
      return SizedBox(width: width, height: height, child: buttonChild);
    }
    return SizedBox(height: height, width: double.infinity, child: buttonChild);
  }
}
