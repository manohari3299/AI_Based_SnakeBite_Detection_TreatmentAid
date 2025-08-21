import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class FocusIndicatorWidget extends StatefulWidget {
  final Offset? focusPoint;
  final bool isVisible;

  const FocusIndicatorWidget({
    Key? key,
    this.focusPoint,
    required this.isVisible,
  }) : super(key: key);

  @override
  State<FocusIndicatorWidget> createState() => _FocusIndicatorWidgetState();
}

class _FocusIndicatorWidgetState extends State<FocusIndicatorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
  }

  @override
  void didUpdateWidget(FocusIndicatorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      _animationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible || widget.focusPoint == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: widget.focusPoint!.dx - 8.w,
      top: widget.focusPoint!.dy - 8.w,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 16.w,
              height: 16.w,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8.w),
              ),
              child: Stack(
                children: [
                  // Horizontal crosshair
                  Positioned(
                    left: 6.w,
                    top: 7.5.w,
                    child: Container(
                      width: 4.w,
                      height: 1,
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                  // Vertical crosshair
                  Positioned(
                    left: 7.5.w,
                    top: 6.w,
                    child: Container(
                      width: 1,
                      height: 4.w,
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
