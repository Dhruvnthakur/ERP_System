// lib/screens/main_scaffold.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import 'home_screen.dart';
import 'inventory_screen.dart';
import 'product_screen.dart';
import 'order_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});
  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _idx = 0;

  final List<_NavItem> _items = [
    _NavItem(Icons.dashboard_rounded,    'Dashboard', const HomeScreen()),
    _NavItem(Icons.inventory_2_rounded,  'Inventory', const InventoryScreen()),
    _NavItem(Icons.storefront_rounded,   'Products',  const ProductScreen()),
    _NavItem(Icons.receipt_long_rounded, 'Orders',    const OrderScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    final auth   = context.read<AuthProvider>();

    if (isWide) {
      return Scaffold(
        body: Row(children: [
          // ── Sidebar ──────────────────────────────────────────────────────
          Container(
            width: 220,
            decoration: const BoxDecoration(
              color: AppTheme.mahogany,
            ),
            child: Column(children: [
              const SizedBox(height: 36),
              // Logo
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.white.withAlpha(25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.shopping_bag_rounded,
                        color: AppTheme.white, size: 22),
                  ),
                  const SizedBox(width: 10),
                  const Text('SoleERP',
                      style: TextStyle(
                          color: AppTheme.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800)),
                ]),
              ),
              const SizedBox(height: 36),

              // Nav items
              ..._items.asMap().entries.map((e) {
                final sel = e.key == _idx;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 3),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: sel
                          ? AppTheme.white.withAlpha(25)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Icon(e.value.icon,
                          color: sel ? AppTheme.white : AppTheme.beige,
                          size: 22),
                      title: Text(e.value.label,
                          style: TextStyle(
                              color: sel ? AppTheme.white : AppTheme.beige,
                              fontWeight: sel
                                  ? FontWeight.w700
                                  : FontWeight.normal,
                              fontSize: 14)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      onTap: () => setState(() => _idx = e.key),
                    ),
                  ),
                );
              }),
              const Spacer(),

              // Profile panel
              Padding(
                padding: const EdgeInsets.all(14),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.espresso.withAlpha(120),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.white.withAlpha(20)),
                  ),
                  child: Column(children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppTheme.white.withAlpha(30),
                      child: Text(
                        auth.currentUser?.fullName.substring(0, 1) ?? 'U',
                        style: const TextStyle(
                            color: AppTheme.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(auth.currentUser?.fullName ?? '',
                        style: const TextStyle(
                            color: AppTheme.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.white.withAlpha(20),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        auth.currentUser?.role == 'hr_manager'
                            ? 'HR MANAGER'
                            : 'SUPERVISOR',
                        style: const TextStyle(
                            color: AppTheme.parchment,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      icon: const Icon(Icons.logout_rounded,
                          size: 14, color: AppTheme.beige),
                      label: const Text('Logout',
                          style: TextStyle(
                              color: AppTheme.beige, fontSize: 12)),
                      onPressed: () {
                        auth.logout();
                        Navigator.of(context).pop();
                      },
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 12),
            ]),
          ),
          Expanded(child: _items[_idx].screen),
        ]),
      );
    }

    // ── Mobile bottom nav ─────────────────────────────────────────────────
    return Scaffold(
      body: _items[_idx].screen,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.mahogany,
          border: Border(
              top: BorderSide(color: AppTheme.white.withAlpha(20), width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _idx,
          onTap: (i) => setState(() => _idx = i),
          backgroundColor: Colors.transparent,
          selectedItemColor: AppTheme.white,
          unselectedItemColor: AppTheme.beige,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: _items.map((item) => BottomNavigationBarItem(
              icon: Icon(item.icon), label: item.label)).toList(),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final Widget screen;
  _NavItem(this.icon, this.label, this.screen);
}
