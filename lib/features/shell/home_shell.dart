import 'package:flutter/material.dart';

import '../schedule/schedule_tab.dart';
import '../summary/summary_tab.dart';
import '../todo/todo_tab.dart';

/// Mobile-first tab shell: Schedule, To-Do, Summary.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _titles = ['Schedule', 'To-Do', 'Summary'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
      ),
      body: IndexedStack(
        index: _index,
        children: const [
          ScheduleTab(),
          TodoTab(),
          SummaryTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_view_day_outlined),
            selectedIcon: Icon(Icons.calendar_view_day),
            label: 'Schedule',
          ),
          NavigationDestination(
            icon: Icon(Icons.check_box_outlined),
            selectedIcon: Icon(Icons.check_box),
            label: 'To-Do',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Summary',
          ),
        ],
      ),
    );
  }
}
