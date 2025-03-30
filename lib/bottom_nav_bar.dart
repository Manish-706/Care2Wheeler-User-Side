import 'package:care2wheeler_customer/garageServices/services.dart';
import 'package:care2wheeler_customer/Records/records.dart';
import 'package:flutter/material.dart';
import 'home/home.dart';

// Theme Constants
const Color kPrimaryColor = Color.fromARGB(255, 1, 225, 188);
const Color kUnselectedColor = Color(0xFF95A5A6);
const Color kBackgroundColor = Colors.white;

class BottomNavBar extends StatefulWidget {
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  final List<Widget> _pages = [
    HomeScreen(),
    Records(),
    Services(),
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex == index) {
      _navigatorKeys[index].currentState!.popUntil((route) => route.isFirst);
    } else {
      setState(() => _selectedIndex = index);
    }
  }

  Widget _buildOffstageNavigator(int index) {
    return Offstage(
      offstage: _selectedIndex != index,
      child: Navigator(
        key: _navigatorKeys[index],
        onGenerateRoute: (routeSettings) => MaterialPageRoute(
          builder: (context) => _pages[index],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: List.generate(
            _pages.length, (index) => _buildOffstageNavigator(index)),
      ),
      bottomNavigationBar: _buildModernNavBar(),
    );
  }

  Widget _buildModernNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: kBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(
          top: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          color: kUnselectedColor,
        ),
        selectedItemColor: kPrimaryColor,
        unselectedItemColor: kUnselectedColor,
        items: [
          _buildNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: 'Home',
            index: 0,
          ),
          _buildNavItem(
            icon: Icons.assignment_outlined,
            activeIcon: Icons.assignment_rounded,
            label: 'Records',
            index: 1,
          ),
          _buildNavItem(
            icon: Icons.handyman_outlined,
            activeIcon: Icons.handyman_rounded,
            label: 'Services',
            index: 2,
          ),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    return BottomNavigationBarItem(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: animation,
          child: child,
        ),
        child: Icon(
          _selectedIndex == index ? activeIcon : icon,
          key: ValueKey(_selectedIndex == index ? activeIcon : icon),
        ),
      ),
      label: label,
    );
  }
}
