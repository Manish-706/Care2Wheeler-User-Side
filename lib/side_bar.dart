import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({Key? key}) : super(key: key);
  final Color _mainThemeColor = const Color.fromARGB(255, 1, 225, 188);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 280,
      elevation: 16,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeaderSection(),
          Expanded(child: _buildMenuItems(context)), // Pass context here
          _buildFooterSection(),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _mainThemeColor.withOpacity(0.9),
            _mainThemeColor.withOpacity(0.7),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 2,
                )
              ],
            ),
            child: const CircleAvatar(
              radius: 48,
              backgroundImage: AssetImage('assets/user_profile.jpg'),
            ),
          ),
          const SizedBox(height: 16),
          const Text('John Doe',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              )),
          const SizedBox(height: 4),
          const Text('New York, USA',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              )),
        ],
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        _buildMenuItem(
          context: context, // Pass context here
          icon: Icons.notifications_active_rounded,
          label: 'Service Updates',
          onTap: () => _handleNavigation(context, '/updates'),
        ),
        _buildMenuItem(
          context: context, // Pass context here
          icon: Icons.edit_document,
          label: 'Edit Vehicle Details',
          onTap: () => _handleNavigation(context, '/edit_vehicle'),
        ),
        _buildMenuItem(
          context: context, // Pass context here
          icon: Icons.person_rounded,
          label: 'Account Settings',
          onTap: () => _handleNavigation(context, '/profile'),
        ),
        _buildMenuItem(
          context: context, // Pass context here
          icon: Icons.history_rounded,
          label: 'Service History',
          onTap: () => _handleNavigation(context, '/history'),
        ),
        const Divider(height: 32, indent: 20, endIndent: 20),
        _buildMenuItem(
          context: context, // Pass context here
          icon: Icons.logout_rounded,
          label: 'Logout',
          color: Colors.red,
          onTap: () => _handleLogout(context),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required BuildContext context, // Add context as a required parameter
    required IconData icon,
    required String label,
    required Function() onTap,
    Color? color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: _mainThemeColor.withOpacity(0.1),
        highlightColor: _mainThemeColor.withOpacity(0.05),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: color ?? _mainThemeColor, size: 24),
              const SizedBox(width: 16),
              Text(label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: color ?? Colors.grey.shade800,
                  )),
              const Spacer(),
              Icon(Icons.chevron_right_rounded,
                  color: color ?? Colors.grey.shade400, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Divider(height: 1),
          const SizedBox(height: 12),
          Text('App Version 2.4.1',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              )),
          const SizedBox(height: 4),
          Text('© 2024 Care2Wheeler',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              )),
        ],
      ),
    );
  }

  void _handleNavigation(BuildContext context, String route) {
    Navigator.pop(context);
    // Navigator.pushNamed(context, route);
  }

  void _handleLogout(BuildContext context) {
    Navigator.pop(context);
    // Add logout implementation
  }
}
