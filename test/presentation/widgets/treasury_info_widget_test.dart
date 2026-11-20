import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miqotul_khoir_tv/presentation/widgets/treasury_info_widget.dart';

/// Unit/Widget tests untuk [TreasuryInfoWidget].
///
/// Memvalidasi tampilan nilai kas masjid dalam format Rupiah,
/// label sections, dan ikon yang sesuai.
///
/// Ref: Plan feature-treasury-info-1.md Phase 9 TASK-035
void main() {
  /// Helper untuk membungkus widget dalam ScreenUtil + MaterialApp.
  Widget buildTestable(Widget widget) {
    return ScreenUtilInit(
      designSize: const Size(1920, 1080),
      child: MaterialApp(home: Scaffold(body: widget)),
    );
  }

  group('TreasuryInfoWidget', () {
    testWidgets('menampilkan title "Kas Masjid"', (tester) async {
      await tester.pumpWidget(
        buildTestable(
          const TreasuryInfoWidget(balance: 0, income: 0, expense: 0),
        ),
      );
      await tester.pump();

      expect(find.text('Kas Masjid'), findsOneWidget);
    });

    testWidgets('menampilkan label Saldo, Pemasukan, dan Pengeluaran', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestable(
          const TreasuryInfoWidget(balance: 0, income: 0, expense: 0),
        ),
      );
      await tester.pump();

      expect(find.text('Saldo'), findsOneWidget);
      expect(find.text('Pemasukan'), findsOneWidget);
      expect(find.text('Pengeluaran'), findsOneWidget);
    });

    testWidgets('memformat saldo dalam format Rupiah yang benar', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestable(
          const TreasuryInfoWidget(balance: 5000000, income: 0, expense: 0),
        ),
      );
      await tester.pump();

      // Rp 5.000.000 (locale id_ID dengan titik sebagai thousands separator)
      expect(find.text('Rp 5.000.000'), findsOneWidget);
    });

    testWidgets('memformat pemasukan dan pengeluaran dalam format Rupiah', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestable(
          const TreasuryInfoWidget(
            balance: 0,
            income: 2500000,
            expense: 750000,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Rp 2.500.000'), findsOneWidget); // income
      expect(find.text('Rp 750.000'), findsOneWidget); // expense
    });

    testWidgets('menampilkan semua 3 nilai Rupiah secara bersamaan', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestable(
          const TreasuryInfoWidget(
            balance: 10000000,
            income: 3000000,
            expense: 1500000,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Rp 10.000.000'), findsOneWidget);
      expect(find.text('Rp 3.000.000'), findsOneWidget);
      expect(find.text('Rp 1.500.000'), findsOneWidget);
    });

    testWidgets('menampilkan ikon wallet di title row', (tester) async {
      await tester.pumpWidget(
        buildTestable(
          const TreasuryInfoWidget(balance: 0, income: 0, expense: 0),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.account_balance_wallet), findsOneWidget);
    });

    testWidgets('menampilkan ikon arah untuk pemasukan dan pengeluaran', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestable(
          const TreasuryInfoWidget(balance: 0, income: 0, expense: 0),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
      expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
    });

    testWidgets('memformat nilai nol dengan benar (Rp 0)', (tester) async {
      await tester.pumpWidget(
        buildTestable(
          const TreasuryInfoWidget(balance: 0, income: 0, expense: 0),
        ),
      );
      await tester.pump();

      // "Rp 0" muncul 3x (balance, income, expense semua 0)
      expect(find.text('Rp 0'), findsNWidgets(3));
    });
  });
}
