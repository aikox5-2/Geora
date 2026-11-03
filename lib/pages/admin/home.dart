import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/navigasi_bawah.dart';
import 'absen.dart';
import 'dashboard.dart';
import 'profile.dart';
import 'rekap.dart';
import 'siswa.dart';

class AdminMainPage extends StatefulWidget {
  final int initialIndex;

  const AdminMainPage({super.key, this.initialIndex = 0});

  @override
  State<AdminMainPage> createState() => _AdminMainPageState();
}

class _AdminMainPageState extends State<AdminMainPage> {
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
      AdminDashboardTab(onNavigateTab: _onTabTapped),
      const AdminStudentsTab(),
      const AdminAttendanceTab(),
      const AdminRecapTab(),
      const AdminProfileTab(),
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
          child: GeoraBottomNav(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
          ),
        ),
      ),
    );
  }
}

