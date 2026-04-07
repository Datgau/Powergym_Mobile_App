import 'package:flutter/material.dart';
import '../config/theme.dart';

class GradientContainer extends StatelessWidget {
  final Widget child;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  
  const GradientContainer({
    super.key,
    required this.child,
    this.height,
    this.padding,
    this.borderRadius,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        gradient: AppTheme.brandGradient,
        borderRadius: borderRadius,
      ),
      child: child,
    );
  }
}
