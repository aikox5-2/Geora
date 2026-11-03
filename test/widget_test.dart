import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geora/main.dart';
import 'package:geora/pages/admin/home.dart';
import 'package:geora/pages/admin/kelola_guru.dart';
import 'package:geora/pages/guru/anggota_kelas.dart';
import 'package:geora/pages/guru/home.dart';
import 'package:geora/pages/guru/profile.dart';
import 'package:geora/pages/guru/rekap.dart';
import 'package:geora/pages/guru/pilih_kelas.dart';
import 'package:geora/pages/siswa/absen_manual.dart';
import 'package:geora/pages/siswa/navigasi_bawah.dart';
import 'package:geora/pages/siswa/home.dart';
import 'package:geora/widgets/ganti_password.dart';

void main() {
  testWidgets('SplashScreen smoke test and navigation to LoginPage',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const GeoraApp());
    expect(find.text('smkn8malang.sch.id'), findsOneWidget);

    // Fast-forward past the 5-second timer and fade transition
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    // Verify LoginPage is displayed
    expect(find.text('Selamat datang'), findsOneWidget);
    expect(find.text('Masuk ke Absensi'), findsOneWidget);
  });

  testWidgets('Admin Login with alias "admin" navigates to AdminMainPage',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const GeoraApp());
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    final emailField =
        find.widgetWithText(TextField, 'Masukkan NISN atau email');
    final passField = find.widgetWithText(TextField, 'Masukkan password');
    final loginButton = find.widgetWithText(ElevatedButton, 'Masuk ke Absensi');

    await tester.enterText(emailField, 'admin');
    await tester.enterText(passField, '12345');
    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);

    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.byType(AdminMainPage), findsOneWidget);
    expect(find.text('Dashboard Admin'), findsOneWidget);
    expect(find.text('Ringkasan Sistem'), findsOneWidget);
  });

  testWidgets('Siswa Login with dummy data navigates to SiswaMainPage',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const GeoraApp());
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    final emailField =
        find.widgetWithText(TextField, 'Masukkan NISN atau email');
    final passField = find.widgetWithText(TextField, 'Masukkan password');
    final loginButton = find.widgetWithText(ElevatedButton, 'Masuk ke Absensi');

    await tester.enterText(emailField, 'iko@gmail.com');
    await tester.enterText(passField, '12345');
    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);

    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.byType(SiswaMainPage), findsOneWidget);
    expect(find.text('Budiono Siregar'), findsOneWidget);
    expect(find.text('Absensi Siswa'), findsOneWidget);

    // Test switching to Riwayat Tab
    final riwayatTab = find.descendant(
      of: find.byType(SiswaBottomNav),
      matching: find.text('Riwayat'),
    );
    await tester.tap(riwayatTab);
    await tester.pumpAndSettle();
    expect(find.text('Riwayat Absensi'), findsOneWidget);
    expect(find.text('18 / 20 Hari'), findsOneWidget);

    // Test switching to Absen Tab
    final absenTab = find.descendant(
      of: find.byType(SiswaBottomNav),
      matching: find.text('Absen'),
    );
    await tester.tap(absenTab);
    await tester.pumpAndSettle();
    expect(find.text('Absensi Hari Ini'), findsOneWidget);
    expect(find.text('Absensi Hanya Dapat Dilakukan Diarea Sekolah'), findsOneWidget);
    expect(find.text('Absen Sekarang'), findsWidgets);

    // Test switching to Profil Tab
    final profilTab = find.descendant(
      of: find.byType(SiswaBottomNav),
      matching: find.text('Profil'),
    );
    await tester.tap(profilTab);
    await tester.pumpAndSettle();
    expect(find.text('Profil Saya'), findsOneWidget);
    expect(find.text('Informasi Akademik'), findsOneWidget);
  });

  testWidgets('Guru Login navigates to GuruMainPage with all 5 tabs working',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const GeoraApp());
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    final emailField =
        find.widgetWithText(TextField, 'Masukkan NISN atau email');
    final passField = find.widgetWithText(TextField, 'Masukkan password');
    final loginButton = find.widgetWithText(ElevatedButton, 'Masuk ke Absensi');

    await tester.enterText(emailField, 'yudi@gmail.com');
    await tester.enterText(passField, '12345');
    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);

    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.byType(GuruMainPage), findsOneWidget);
    expect(find.text('Halo, Yudi'), findsOneWidget);
    expect(find.text('Ringkasan Hari Ini'), findsOneWidget);

    // Test switching to Rekap Tab
    final rekapTab = find.text('Rekap');
    await tester.tap(rekapTab);
    await tester.pumpAndSettle();
    expect(find.byType(GuruRecapTab), findsOneWidget);
    expect(find.text('Persentase Kehadiran'), findsOneWidget);
    expect(find.text('Unduh Rekap'), findsOneWidget);

    // Test switching to Profil Tab
    final profilTab = find.text('Profil');
    await tester.tap(profilTab);
    await tester.pumpAndSettle();
    expect(find.byType(GuruProfileTab), findsOneWidget);
    expect(find.text('Profil Saya'), findsOneWidget);
    expect(find.text('Wali Kelas XII RPL D'), findsOneWidget);
  });

  testWidgets('PilihKelasPage smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: PilihKelasPage(),
      ),
    );

    expect(find.text('Absensi Siswa'), findsOneWidget);
    expect(find.text('XII RPL D'), findsOneWidget);
    expect(find.text('XII RPL B'), findsOneWidget);
  });

  testWidgets('AbsenManualPage smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: AbsenManualPage(),
      ),
    );

    expect(find.text('Absen Manual'), findsOneWidget);
    expect(find.text('Guru / Karyawan Bertugas'), findsOneWidget);
    expect(find.text('Budi Santoso'), findsOneWidget);
    expect(find.text('Kirim Pengajuan'), findsOneWidget);
  });

  testWidgets('Unregistered username shows Alert dialog',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const GeoraApp());
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    final emailField =
        find.widgetWithText(TextField, 'Masukkan NISN atau email');
    final passField = find.widgetWithText(TextField, 'Masukkan password');
    final loginButton = find.widgetWithText(ElevatedButton, 'Masuk ke Absensi');

    await tester.enterText(emailField, 'unknown_user');
    await tester.enterText(passField, '12345');
    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);

    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Akun Tidak Ditemukan'), findsOneWidget);
    expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text(
              'Username / NISN tidak terdaftar! Periksa kembali akun sekolah Anda.'),
        ),
        findsOneWidget);
  });

  testWidgets('Wrong password shows Alert dialog',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const GeoraApp());
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    final emailField =
        find.widgetWithText(TextField, 'Masukkan NISN atau email');
    final passField = find.widgetWithText(TextField, 'Masukkan password');
    final loginButton = find.widgetWithText(ElevatedButton, 'Masuk ke Absensi');

    await tester.enterText(emailField, 'admin@gmail.com');
    await tester.enterText(passField, 'salah123');
    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);

    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Kata Sandi Salah'), findsOneWidget);
    expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text(
              'Kata sandi salah! Silakan coba lagi atau hubungi admin.'),
        ),
        findsOneWidget);
  });

  testWidgets('Admin tabs: Absensi, Rekap (Gambar 5), and Profil Change Password',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const GeoraApp());
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    final emailField =
        find.widgetWithText(TextField, 'Masukkan NISN atau email');
    final passField = find.widgetWithText(TextField, 'Masukkan password');
    final loginButton = find.widgetWithText(ElevatedButton, 'Masuk ke Absensi');

    await tester.enterText(emailField, 'admin@gmail.com');
    await tester.enterText(passField, '12345');
    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // 1. Absensi Tab (Gambar 3)
    final absensiNav = find.text('Absensi');
    await tester.tap(absensiNav);
    await tester.pumpAndSettle();

    expect(find.text('Monitoring Absensi'), findsOneWidget);
    expect(find.textContaining('Seluruh kelas •'), findsOneWidget);
    expect(find.text('98'), findsOneWidget);
    expect(find.text('15'), findsOneWidget);
    expect(find.text('XII RPL A'), findsOneWidget);
    expect(find.text('XII RPL D'), findsOneWidget);

    // 2. Rekap Tab (Gambar 5)
    final rekapNav = find.text('Rekap');
    await tester.tap(rekapNav);
    await tester.pumpAndSettle();

    expect(find.text('Laporan Absensi'), findsOneWidget);
    expect(find.text('Rekap dan analisis kehadiran'), findsOneWidget);
    expect(find.text('September 2026'), findsOneWidget);
    expect(find.text('84%'), findsOneWidget);
    expect(find.text('6%'), findsOneWidget);
    expect(find.text('10%'), findsOneWidget);
    expect(find.text('Harian'), findsOneWidget);
    expect(find.text('Mingguan'), findsOneWidget);
    expect(find.text('Bulanan'), findsOneWidget);

    // Tap Unduh Laporan
    final unduhBtn = find.widgetWithText(ElevatedButton, 'Unduh Laporan');
    await tester.ensureVisible(unduhBtn);
    await tester.tap(unduhBtn);
    await tester.pumpAndSettle();

    expect(find.text('Unduh Laporan'), findsWidgets);
    expect(find.text('Dokumen PDF (.pdf)'), findsOneWidget);
    expect(find.text('Spreadsheet Excel (.xlsx)'), findsOneWidget);

    // Tap PDF format
    await tester.tap(find.text('Dokumen PDF (.pdf)'));
    await tester.pumpAndSettle();
    expect(find.text('Unduh Berhasil!'), findsOneWidget);
    await tester.tap(find.text('Tutup'));
    await tester.pumpAndSettle();

    // 3. Profil Tab (Gambar 2: Profil Admin & Change Password)
    final profilNav = find.text('Profil');
    await tester.tap(profilNav);
    await tester.pumpAndSettle();

    expect(find.text('Profil Saya'), findsOneWidget);
    expect(find.text('Data akun dan informasi admin'), findsOneWidget);
    expect(find.text('Administrator'), findsOneWidget);
    expect(find.text('Informasi'), findsOneWidget);
    expect(find.text('Kontak & Alamat'), findsOneWidget);

    final changePassCard = find.byType(ChangePasswordCard);
    await tester.ensureVisible(changePassCard);
    await tester.pumpAndSettle();

    expect(find.text('Change Password'), findsOneWidget);
    expect(find.text('Perbarui kata sandi akun'), findsOneWidget);

    // Open Change Password Dialog
    await tester.tap(changePassCard);
    await tester.pumpAndSettle();

    expect(find.text('Password Lama'), findsOneWidget);
    expect(find.text('Password Baru'), findsOneWidget);
  });

  testWidgets('ManageGuruPage and AnggotaKelasPage smoke and interaction test',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // 1. ManageGuruPage (Gambar 4)
    await tester.pumpWidget(const MaterialApp(home: ManageGuruPage()));
    await tester.pumpAndSettle();

    expect(find.text('Kelola Akun Guru'), findsOneWidget);
    expect(find.text('Ahmad Guru'), findsOneWidget);
    expect(find.text('Rani Guru'), findsOneWidget);
    expect(find.text('Siti Guru'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);

    // Tap Add Guru FAB
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('Tambah Akun Guru'), findsOneWidget);
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();

    // 2. AnggotaKelasPage (Gambar 1)
    await tester.pumpWidget(const MaterialApp(home: AnggotaKelasPage(className: 'XII RPL D')));
    await tester.pumpAndSettle();

    expect(find.text('Anggota Kelas XII RPL D'), findsOneWidget);
    expect(find.text('Tanggal Presensi'), findsOneWidget);
    expect(find.text('Wali Kelas'), findsWidgets);
    expect(find.text('Ahmad Farhan'), findsOneWidget);
    expect(find.text('Chelsea Aqila Putri'), findsOneWidget);
    expect(find.text('Dimas Ibrahimovic'), findsOneWidget);
    expect(find.text('Hadir'), findsWidgets);

    // Test Search input for Malika Aisyabila
    final searchInput = find.byType(TextField);
    await tester.enterText(searchInput, 'Malika');
    await tester.pumpAndSettle();
    expect(find.text('Malika Aisyabila'), findsOneWidget);
    expect(find.text('Sakit'), findsWidgets);
  });
}
