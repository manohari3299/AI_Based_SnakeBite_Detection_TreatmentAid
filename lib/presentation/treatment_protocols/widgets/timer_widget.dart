import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class TimerWidget extends StatefulWidget {
  final DateTime biteTime;

  const TimerWidget({
    Key? key,
    required this.biteTime,
  }) : super(key: key);

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsed = DateTime.now().difference(widget.biteTime);
      });
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  Color _getTimerColor() {
    final minutes = _elapsed.inMinutes;
    if (minutes < 30) {
      return AppTheme.lightTheme.colorScheme.secondary;
    } else if (minutes < 60) {
      return const Color(0xFFFF6F00);
    } else {
      return AppTheme.lightTheme.colorScheme.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final timerColor = _getTimerColor();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: timerColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: timerColor,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: timerColor,
              shape: BoxShape.circle,
            ),
            child: CustomIconWidget(
              iconName: 'timer',
              color: Colors.white,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 4.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Time Since Bite',
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: timerColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  _formatDuration(_elapsed),
                  style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                    color: timerColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 24.sp,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),

          // Critical time indicator
          if (_elapsed.inMinutes >= 30)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: timerColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _elapsed.inMinutes >= 60 ? 'CRITICAL' : 'URGENT',
                style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10.sp,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
