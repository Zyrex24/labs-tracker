import 'package:flutter/material.dart';
import 'glass/glass_scaffold.dart';
import '../features/subjects/subjects_screen.dart';
import '../features/calendar/calendar_screen.dart';
import '../features/exams/exams_screen.dart';
import '../features/summary/summary_screen.dart';
import '../features/settings/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = const [
    SubjectsScreen(),
    CalendarScreen(),
    ExamsScreen(),
    SummaryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      showAppBar: false,
      body: _screens[_currentIndex],
      bottomNavigationBar: GlassBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          GlassBottomNavItem(
            icon: Icons.science_rounded,
            label: 'Subjects',
          ),
          GlassBottomNavItem(
            icon: Icons.calendar_month_rounded,
            label: 'Calendar',
          ),
          GlassBottomNavItem(
            icon: Icons.assignment_rounded,
            label: 'Exams',
          ),
          GlassBottomNavItem(
            icon: Icons.analytics_rounded,
            label: 'Summary',
          ),
          GlassBottomNavItem(
            icon: Icons.settings_rounded,
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

