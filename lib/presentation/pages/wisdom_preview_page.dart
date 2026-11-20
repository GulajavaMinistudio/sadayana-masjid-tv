import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/islamic_colors.dart';
import '../../core/theme/islamic_typography.dart';
import '../../domain/entities/display_state.dart';
import '../../domain/entities/wisdom_quote.dart';
import '../widgets/focusable_widget.dart';
import 'main_display/layouts/wisdom_quote_layout.dart';

/// Halaman pratinjau fullscreen untuk melihat item Kata Mutiara sebelum diterapkan.
///
/// Menampilkan item yang telah dipilih admin satu per satu menggunakan
/// [WisdomQuoteLayout] yang sama dengan tampilan utama (WYSIWYG preview).
///
/// Fitur:
/// - Auto-slide otomatis setiap 5 detik
/// - Navigasi manual via D-Pad Left/Right atau tombol PREV/NEXT di header
/// - Dot indicator posisi item di footer
/// - Tombol "Tutup Preview" untuk menutup halaman
///
/// Ref: Plan feature-wisdom-quote-1.md TASK-039 s.d. TASK-043
class WisdomPreviewPage extends StatefulWidget {
  /// Daftar item Kata Mutiara yang akan di-preview. Minimal 1 item.
  final List<WisdomQuote> quotes;

  const WisdomPreviewPage({super.key, required this.quotes});

  @override
  State<WisdomPreviewPage> createState() => _WisdomPreviewPageState();
}

class _WisdomPreviewPageState extends State<WisdomPreviewPage> {
  /// Indeks item yang sedang ditampilkan (0-based).
  int _currentIndex = 0;

  /// Timer auto-slide setiap 5 detik.
  Timer? _autoSlideTimer;

  /// Durasi simulasi untuk preview — progress bar tampak full (tidak bergerak).
  static const int _previewDurationSeconds = 180;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _startAutoSlideTimer();
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Timer management
  // ---------------------------------------------------------------------------

  void _startAutoSlideTimer() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) {
        _goNext();
      }
    });
  }

  /// Reset timer setiap kali navigasi manual dilakukan agar tidak slide
  /// terlalu cepat setelah interaksi user.
  void _resetAutoSlideTimer() {
    _startAutoSlideTimer();
  }

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------

  void _goNext() {
    if (!mounted) return;
    setState(() {
      _currentIndex = (_currentIndex + 1) % widget.quotes.length;
    });
  }

  void _goPrevious() {
    if (!mounted) return;
    setState(() {
      _currentIndex =
          (_currentIndex - 1 + widget.quotes.length) % widget.quotes.length;
    });
  }

  // ---------------------------------------------------------------------------
  // D-Pad key handler (TASK-041)
  // ---------------------------------------------------------------------------

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _goNext();
        _resetAutoSlideTimer();
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _goPrevious();
        _resetAutoSlideTimer();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  // ---------------------------------------------------------------------------
  // WisdomQuoteState simulasi untuk preview (TASK-042)
  // ---------------------------------------------------------------------------

  /// Membuat state simulasi dari item saat ini untuk dirender oleh
  /// [WisdomQuoteLayout]. Nilai [remainingSeconds] == [_previewDurationSeconds]
  /// sehingga progress bar tampak kosong (preview di-reset setiap slide).
  WisdomQuoteState _buildPreviewState() {
    return WisdomQuoteState(
      currentQuote: widget.quotes[_currentIndex],
      currentIndex: _currentIndex,
      totalItems: widget.quotes.length,
      currentTime: DateTime.now(),
      totalDurationSeconds: _previewDurationSeconds,
      remainingSeconds: _previewDurationSeconds,
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Layer 1 — WisdomQuoteLayout penuh layar
            Positioned.fill(
              child: WisdomQuoteLayout(
                key: ValueKey(_currentIndex),
                state: _buildPreviewState(),
              ),
            ),

            // Layer 2 — Header overlay: label + tombol PREV/NEXT (TASK-042)
            Positioned(top: 0, left: 0, right: 0, child: _buildHeaderOverlay()),

            // Layer 3 — Footer overlay: dot indicator + tombol Tutup (TASK-043)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildFooterOverlay(),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Overlay widgets
  // ---------------------------------------------------------------------------

  /// Header overlay: tombol PREV di kiri, label tengah, tombol NEXT di kanan.
  Widget _buildHeaderOverlay() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 10.h),
      color: Colors.black.withValues(alpha: 0.65),
      child: Row(
        children: [
          _buildNavButton(
            icon: Icons.arrow_back_ios_new_rounded,
            label: 'PREV',
            onSelect: () {
              _goPrevious();
              _resetAutoSlideTimer();
            },
          ),
          Expanded(
            child: Text(
              'PREVIEW KATA MUTIARA  —  ${widget.quotes.length} item dipilih',
              textAlign: TextAlign.center,
              style: IslamicTypography.caption(
                color: IslamicColors.goldAmber,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _buildNavButton(
            icon: Icons.arrow_forward_ios_rounded,
            label: 'NEXT',
            isNextButton: true,
            onSelect: () {
              _goNext();
              _resetAutoSlideTimer();
            },
          ),
        ],
      ),
    );
  }

  /// Footer overlay: dot indicator posisi + tombol "Tutup Preview".
  Widget _buildFooterOverlay() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
      color: Colors.black.withValues(alpha: 0.65),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDotIndicator(),
          SizedBox(height: 12.h),
          Center(
            child: FocusableWidget(
              autofocus: false,
              onSelect: () => Navigator.of(context).pop(),
              builder: (isFocused) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: isFocused
                      ? IslamicColors.goldAmber.withValues(alpha: 0.25)
                      : IslamicColors.primaryTeal.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(30.r),
                  border: Border.all(
                    color: isFocused
                        ? IslamicColors.goldAmber
                        : IslamicColors.primaryTeal,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  'Tutup Preview',
                  style: IslamicTypography.body(
                    color: isFocused
                        ? IslamicColors.goldAmber
                        : IslamicColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Dot indicator: satu lingkaran per item, filled/wide = item aktif.
  Widget _buildDotIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.quotes.length, (index) {
        final isActive = index == _currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          width: isActive ? 14.r : 8.r,
          height: 8.r,
          decoration: BoxDecoration(
            color: isActive
                ? IslamicColors.goldAmber
                : IslamicColors.textMuted.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(4.r),
          ),
        );
      }),
    );
  }

  /// Tombol navigasi PREV / NEXT kecil di header overlay.
  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required VoidCallback onSelect,
    bool isNextButton = false,
  }) {
    return FocusableWidget(
      autofocus: false,
      onSelect: onSelect,
      builder: (isFocused) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isFocused
              ? IslamicColors.primaryTeal.withValues(alpha: 0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isFocused ? IslamicColors.primaryTeal : Colors.transparent,
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isNextButton) ...[
              Icon(icon, size: 16.r, color: IslamicColors.textSecondary),
              SizedBox(width: 4.w),
            ],
            Text(
              label,
              style: IslamicTypography.caption(
                color: IslamicColors.textSecondary,
              ),
            ),
            if (isNextButton) ...[
              SizedBox(width: 4.w),
              Icon(icon, size: 16.r, color: IslamicColors.textSecondary),
            ],
          ],
        ),
      ),
    );
  }
}
