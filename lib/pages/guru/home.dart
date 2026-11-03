import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'absen.dart';
import 'navigasi_bawah.dart';
import 'dashboard.dart';
import 'profile.dart';
import 'rekap.dart';
import 'pengajuan.dart';

class GuruMainPage extends StatefulWidget {
  final int initialIndex;

  const GuruMainPage({super.key, this.initialIndex = 0});

  @override
  State<GuruMainPage> createState() => _GuruMainPageState();
}

class _GuruMainPageState extends State<GuruMainPage> {
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
      GuruDashboardTab(onNavigateTab: _onTabTapped),
      const GuruAttendanceTab(),
      const GuruSubmissionsTab(),
      const GuruRecapTab(),
      const GuruProfileTab(),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFFF5EDE5),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5EDE5),
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
          child: GuruBottomNav(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
          ),
        ),
      ),
    );
  }
}
