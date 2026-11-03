import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'absen.dart';
import 'navigasi_bawah.dart';
import 'dashboard.dart';
import 'riwayat.dart';
import 'profile.dart';

class SiswaMainPage extends StatefulWidget {
  final int initialIndex;

  const SiswaMainPage({super.key, this.initialIndex = 0});

  @override
  State<SiswaMainPage> createState() => _SiswaMainPageState();
}

class _SiswaMainPageState extends State<SiswaMainPage> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      SiswaDashboardTab(onNavigateTab: _onTabTapped),
      const SiswaHistoryTab(),
      const SiswaAttendanceHubTab(),
      const SiswaProfileTab(),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFFFAF9F9),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF9F9),
        body: SafeArea(
          top: false,
          bottom: false,
          child: IndexedStack(
            index: _currentIndex,
            children: tabs,
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: SiswaBottomNav(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
          ),
        ),
      ),
    );
  }
}
