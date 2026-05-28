import 'package:flutter/material.dart';
import 'package:spendlytic/ui/screens/add_expense/add_expense_screen.dart';
import 'package:spendlytic/ui/screens/budget/budget_screen.dart';
import 'package:spendlytic/ui/screens/home/home_screen.dart';
import 'package:spendlytic/ui/screens/profile/profile_screen.dart';
import 'package:spendlytic/ui/screens/stats/stats_screen.dart';

class AppNavigationLayout extends StatefulWidget {
  const AppNavigationLayout({super.key});

  @override
  State<AppNavigationLayout> createState() => _AppNavigationLayoutState();
}

class _AppNavigationLayoutState extends State<AppNavigationLayout> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomeScreen(),
      const StatsScreen(),
      const AddExpenseScreen(),
      const BudgetScreen(),
      const ProfileScreen(), // ✅ Real Screen
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        backgroundColor: Colors.white,
        indicatorColor: colorScheme.secondary.withOpacity(0.5),
        elevation: 2,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Add',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Budget',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
