import 'dart:async';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/islamic_colors.dart';
import '../../core/theme/islamic_typography.dart';
import 'focusable_widget.dart';
import 'glassmorphism_card.dart';

class DPadStepper extends StatefulWidget {
  final int value;
  final int minValue;
  final int maxValue;
  final int step;
  final ValueChanged<int> onChanged;
  final String? label;
  final String? suffix;
  final bool autofocus;

  const DPadStepper({
    super.key,
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.onChanged,
    this.step = 1,
    this.label,
    this.suffix,
    this.autofocus = false,
  });

  @override
  State<DPadStepper> createState() => _DPadStepperState();
}

class _DPadStepperState extends State<DPadStepper>
    with SingleTickerProviderStateMixin {
  Timer? _longPressTimer;
  bool _isHolding = false;

  // Visual feedback animation
  late final AnimationController _flashController;
  late final Animation<double> _flashAnimation;

  @override
  void initState() {
    super.initState();
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _flashAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _flashController, curve: Curves.easeInOut),
    );
    _flashController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _flashController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _cancelTimer();
    _flashController.dispose();
    super.dispose();
  }

  void _increment() {
    if (widget.value < widget.maxValue) {
      int nextVal = widget.value + widget.step;
      if (nextVal > widget.maxValue) nextVal = widget.maxValue;
      widget.onChanged(nextVal);
      _flashController.forward(from: 0.0);
    }
  }

  void _decrement() {
    if (widget.value > widget.minValue) {
      int nextVal = widget.value - widget.step;
      if (nextVal < widget.minValue) nextVal = widget.minValue;
      widget.onChanged(nextVal);
      _flashController.forward(from: 0.0);
    }
  }

  void _startTimer(bool isIncrement) {
    if (_isHolding) return;
    _isHolding = true;

    // Initial action
    if (isIncrement) {
      _increment();
    } else {
      _decrement();
    }

    _cancelTimer();
    // Start 500ms delay, then periodic 100ms
    _longPressTimer = Timer(const Duration(milliseconds: 500), () {
      _longPressTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
        if (isIncrement) {
          _increment();
        } else {
          _decrement();
        }
      });
    });
  }

  void _cancelTimer() {
    _isHolding = false;
    _longPressTimer?.cancel();
    _longPressTimer = null;
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    final isRight = event.logicalKey == LogicalKeyboardKey.arrowRight;
    final isLeft = event.logicalKey == LogicalKeyboardKey.arrowLeft;

    // ArrowRight → increment, ArrowLeft → decrement.
    // ArrowUp/Down sengaja TIDAK ditangani di sini agar focus traversal
    // Flutter bisa memindahkan fokus ke baris stepper berikutnya/sebelumnya.
    if (isRight) {
      if (event is KeyDownEvent) {
        _startTimer(true);
      } else if (event is KeyUpEvent) {
        _cancelTimer();
      }
      return KeyEventResult.handled;
    } else if (isLeft) {
      if (event is KeyDownEvent) {
        _startTimer(false);
      } else if (event is KeyUpEvent) {
        _cancelTimer();
      }
      return KeyEventResult.handled;
    }

    if (event is KeyUpEvent) {
      _cancelTimer();
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      skipTraversal: true,
      onKeyEvent: (node, event) => _handleKeyEvent(node, event),
      child: FocusableWidget(
        autofocus: widget.autofocus,
        builder: (isFocused) {
          return GlassmorphismCard(
            isFocused: isFocused,
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.label != null)
                  Expanded(
                    child: Text(
                      widget.label!,
                      style: IslamicTypography.body(
                        color: isFocused
                            ? IslamicColors.goldAmber
                            : Colors.white,
                      ),
                    ),
                  ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: _decrement,
                      onLongPressStart: (_) => _startTimer(false),
                      onLongPressEnd: (_) => _cancelTimer(),
                      child: Padding(
                        padding: EdgeInsets.all(8.r),
                        child: Icon(
                          Icons.remove_circle_outline,
                          color: isFocused
                              ? IslamicColors.goldAmber
                              : Colors.white70,
                          size: 44.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    AnimatedBuilder(
                      animation: _flashAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _flashAnimation.value,
                          child: child,
                        );
                      },
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: 80.w),
                        child: Text(
                          widget.suffix != null
                              ? '${widget.value} ${widget.suffix}'
                              : '${widget.value}',
                          style: IslamicTypography.title(
                            color: isFocused
                                ? IslamicColors.goldAmber
                                : IslamicColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    GestureDetector(
                      onTap: _increment,
                      onLongPressStart: (_) => _startTimer(true),
                      onLongPressEnd: (_) => _cancelTimer(),
                      child: Padding(
                        padding: EdgeInsets.all(8.r),
                        child: Icon(
                          Icons.add_circle_outline,
                          color: isFocused
                              ? IslamicColors.goldAmber
                              : Colors.white70,
                          size: 44.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
