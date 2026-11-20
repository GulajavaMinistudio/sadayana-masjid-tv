import 'dart:math';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/islamic_typography.dart';
import 'focusable_widget.dart';
import '../../core/theme/islamic_colors.dart';

class PinInputWidget extends StatefulWidget {
  final int pinLength;
  final ValueChanged<String> onCompleted;
  final bool showError;
  final bool autofocus;

  const PinInputWidget({
    super.key,
    this.pinLength = 6,
    required this.onCompleted,
    this.showError = false,
    this.autofocus = true,
  });

  @override
  State<PinInputWidget> createState() => _PinInputWidgetState();
}

class _PinInputWidgetState extends State<PinInputWidget>
    with SingleTickerProviderStateMixin {
  late List<String> _digits;
  int _currentIndex = 0;

  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  // Hidden TextField untuk membuka soft keyboard di Android TV.
  // skipTraversal: true → tidak masuk D-pad traversal otomatis.
  final FocusNode _hiddenFocusNode = FocusNode(skipTraversal: true);
  late final TextEditingController _hiddenController;

  @override
  void initState() {
    super.initState();
    _digits = List.filled(widget.pinLength, '');
    _hiddenController = TextEditingController();
    _hiddenController.addListener(_onHiddenTextChanged);

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Shake animation
    _shakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _shakeController,
        curve: const ElasticInCurve(0.4),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant PinInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showError && !oldWidget.showError) {
      _shakeController.forward(from: 0.0).then((_) {
        // Reset when error animation finishes
        if (mounted) {
          setState(() {
            _digits = List.filled(widget.pinLength, '');
            _currentIndex = 0;
          });
        }
      });
    } else if (!widget.showError && oldWidget.showError) {
      // Clear pins if error is lifted externally
      _digits = List.filled(widget.pinLength, '');
      _currentIndex = 0;
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _hiddenController.removeListener(_onHiddenTextChanged);
    _hiddenController.dispose();
    _hiddenFocusNode.dispose();
    super.dispose();
  }

  /// Menangkap digit dari soft keyboard melalui hidden TextField.
  ///
  /// Setiap kali karakter masuk ke hidden field:
  /// 1. Ambil digit terakhir → teruskan ke [_onDigitEntered]
  /// 2. Clear field di frame berikutnya supaya siap menerima input berikutnya
  void _onHiddenTextChanged() {
    final text = _hiddenController.text;
    if (text.isEmpty) return;
    final digit = text[text.length - 1];
    if (int.tryParse(digit) != null) {
      _onDigitEntered(digit);
    }
    // Clear setelah frame ini selesai agar soft keyboard tetap terbuka.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _hiddenController.clear();
    });
  }

  void _onDigitEntered(String digit) {
    if (_currentIndex < widget.pinLength) {
      setState(() {
        _digits[_currentIndex] = digit;
        if (_currentIndex < widget.pinLength - 1) {
          _currentIndex++;
        }
      });
      _checkCompletion();
    }
  }

  void _onBackspace() {
    setState(() {
      if (_digits[_currentIndex].isNotEmpty) {
        _digits[_currentIndex] = '';
      } else {
        if (_currentIndex > 0) {
          _currentIndex--;
          _digits[_currentIndex] = '';
        }
      }
    });
  }

  void _checkCompletion() {
    final pin = _digits.join();
    if (pin.length == widget.pinLength) {
      widget.onCompleted(pin);
    }
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final key = event.logicalKey;

    // Handle digits 0-9
    if (key.keyLabel.length == 1 && int.tryParse(key.keyLabel) != null) {
      _onDigitEntered(key.keyLabel);
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.numpad0) {
      _onDigitEntered('0');
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.numpad1) {
      _onDigitEntered('1');
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.numpad2) {
      _onDigitEntered('2');
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.numpad3) {
      _onDigitEntered('3');
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.numpad4) {
      _onDigitEntered('4');
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.numpad5) {
      _onDigitEntered('5');
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.numpad6) {
      _onDigitEntered('6');
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.numpad7) {
      _onDigitEntered('7');
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.numpad8) {
      _onDigitEntered('8');
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.numpad9) {
      _onDigitEntered('9');
      return KeyEventResult.handled;
    }

    // Handle Navigation
    if (key == LogicalKeyboardKey.backspace ||
        key == LogicalKeyboardKey.delete) {
      _onBackspace();
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      if (_currentIndex > 0) {
        setState(() => _currentIndex--);
      }
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.arrowRight) {
      if (_currentIndex < widget.pinLength - 1) {
        setState(() => _currentIndex++);
      }
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        // Shake logic using sine function mapping to -10 to 10 pixels offset
        final dx = sin(_shakeAnimation.value * 4 * pi) * 10;
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: Focus(
        onKeyEvent: (node, event) => _handleKeyEvent(node, event),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Hidden TextField sebagai IME connection untuk soft keyboard.
            // Offstage: tidak visible tapi tetap dalam widget tree sehingga
            // requestFocus() berfungsi dan soft keyboard bisa terbuka.
            Offstage(
              child: TextField(
                focusNode: _hiddenFocusNode,
                controller: _hiddenController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onSubmitted: (_) => _hiddenFocusNode.unfocus(),
              ),
            ),
            FocusableWidget(
              autofocus: widget.autofocus,
              onSelect: () {
                // Defer ke frame berikutnya agar key-event selesai sebelum IME
                // connection dibuka — sama seperti pattern di identity/treasury.
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _hiddenFocusNode.requestFocus();
                });
              },
              builder: (isFocusedWrapper) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(widget.pinLength, (index) {
                    final isCurrent = index == _currentIndex;
                    final isFilled = _digits[index].isNotEmpty;
                    // isFocused indicates if the whole UI widget is focused.
                    // we highlight the current sub-box if wrapper is focused, or we can just highlight it relative to others
                    final boxFocused = isFocusedWrapper && isCurrent;

                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Container(
                        width: 60.w,
                        height: 80.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: boxFocused
                                ? IslamicColors.goldAmber
                                : (widget.showError
                                      ? IslamicColors.error
                                      : IslamicColors.glassBorder),
                            width: boxFocused ? 2.w : 1.w,
                          ),
                          color: widget.showError
                              ? IslamicColors.error.withValues(alpha: 0.2)
                              : IslamicColors.glassOverlay,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          isFilled
                              ? (index == _currentIndex ? _digits[index] : '●')
                              : '−',
                          style:
                              IslamicTypography.heading(
                                color: widget.showError
                                    ? IslamicColors.error
                                    : (isFilled
                                          ? IslamicColors.textPrimary
                                          : IslamicColors.textMuted),
                              ).copyWith(
                                // Adjust translation of bullet vs numbers to feel aligned natively
                                height: isFilled && index != _currentIndex
                                    ? 1.0
                                    : null,
                              ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
