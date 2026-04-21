// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/database_service.dart';
import '../utils/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'add_product_screen.dart';
import 'inventory_screen.dart';
import 'order_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _stats;
  bool _loading = true;

  @override
  void initState() { super.initState(); _loadStats(); }

  Future<void> _loadStats() async {
    setState(() => _loading = true);
    try {
      final db = DatabaseService();
      await db.initializeDatabase();
      final s = await db.getDashboardStats();
      setState(() { _stats = s; _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('DB Error: $e'),
              backgroundColor: AppTheme.danger));
    }
  }

  void _showReportsDialog(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.gold.withAlpha(40),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.bar_chart_rounded,
                color: AppTheme.gold, size: 20),
          ),
          const SizedBox(width: 12),
          const Text('Reports',
              style: TextStyle(
                  color: AppTheme.cream,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.gold.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.gold.withAlpha(60)),
            ),
            child: const Row(children: [
              Icon(Icons.construction_rounded, color: AppTheme.gold, size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Reports module coming soon in the next version.',
                  style:
                      TextStyle(color: AppTheme.warmGrey, fontSize: 13),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 14),
          const Text(
            'Planned: revenue charts, production efficiency, and inventory trend analysis.',
            style: TextStyle(color: AppTheme.warmGrey, fontSize: 12),
          ),
        ]),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final fmt  = NumberFormat.currency(symbol: r'₹');

    return Scaffold(
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Welcome, ${auth.currentUser?.fullName.split(' ').first ?? ''}!',
              style: const TextStyle(color: AppTheme.cream)),
          Text(DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
              style: const TextStyle(
                  fontSize: 11, color: AppTheme.warmGrey,
                  fontWeight: FontWeight.normal)),
        ]),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const AddProductScreen()))
                  .then((_) => _loadStats()),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Product'),
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8)),
            ),
          ),
          IconButton(
              icon: const Icon(Icons.refresh_rounded,
                  color: AppTheme.warmGrey),
              onPressed: _loadStats),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(
              color: AppTheme.leather))
          : RefreshIndicator(
              onRefresh: _loadStats,
              color: AppTheme.leather,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  // ── KPI Grid ──────────────────────────────────────────
                  GridView.count(
                    crossAxisCount:
                        MediaQuery.of(context).size.width > 600 ? 3 : 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.1,
                    children: [
                      StatCard(
                        title: 'Total Revenue',
                        value: fmt.format(_stats?['total_revenue'] ?? 0),
                        icon: Icons.currency_rupee_rounded,
                        color: AppTheme.success,
                        subtitle: 'Completed orders',
                      ),
                      StatCard(
                        title: 'Active Products',
                        value: '${_stats?["total_products"] ?? 0}',
                        icon: Icons.category_rounded,
                        color: AppTheme.leather,
                        subtitle: 'In catalog',
                      ),
                      StatCard(
                        title: 'Total Orders',
                        value: '${_stats?["total_orders"] ?? 0}',
                        icon: Icons.receipt_long_rounded,
                        color: AppTheme.warmGrey,
                        subtitle: 'All time',
                      ),
                      StatCard(
                        title: 'Pending Orders',
                        value: '${_stats?["pending_orders"] ?? 0}',
                        icon: Icons.pending_actions_rounded,
                        color: AppTheme.warning,
                        subtitle: 'Awaiting processing',
                      ),
                      StatCard(
                        title: 'Low Stock',
                        value: '${_stats?["low_stock_items"] ?? 0}',
                        icon: Icons.warning_amber_rounded,
                        color: AppTheme.danger,
                        subtitle: 'Needs restocking',
                      ),
                      StatCard(
                        title: 'In Production',
                        value: '${_stats?["manufacturing_batches"] ?? 0}',
                        icon: Icons.factory_rounded,
                        color: AppTheme.gold,
                        subtitle: 'Active batches',
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // ── Quick Actions ─────────────────────────────────────
                  const SectionHeader(title: 'Quick Actions'),
                  const SizedBox(height: 14),
                  GridView.count(
                    crossAxisCount:
                        MediaQuery.of(context).size.width > 600 ? 4 : 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _QuickAction(
                          icon: Icons.add_box_rounded,
                          label: 'Add Product',
                          color: AppTheme.leather,
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const AddProductScreen()))
                              .then((_) => _loadStats())),
                      _QuickAction(
                          icon: Icons.inventory_rounded,
                          label: 'Inventory',
                          color: AppTheme.info,
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const InventoryScreen()))),
                      _QuickAction(
                          icon: Icons.add_shopping_cart_rounded,
                          label: 'New Order',
                          color: AppTheme.success,
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const OrderScreen()))
                              .then((_) => _loadStats())),
                      _QuickAction(
                          icon: Icons.bar_chart_rounded,
                          label: 'Reports',
                          color: AppTheme.gold,
                          onTap: () => _showReportsDialog(context)),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // ── User Profile Banner ───────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        AppTheme.leather.withAlpha(40),
                        AppTheme.cardDark,
                      ]),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppTheme.leather.withAlpha(70)),
                    ),
                    child: Row(children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppTheme.leather.withAlpha(50),
                        child: Text(
                          auth.currentUser?.fullName.substring(0, 1) ?? 'U',
                          style: const TextStyle(
                              color: AppTheme.leather,
                              fontWeight: FontWeight.w800,
                              fontSize: 22),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(auth.currentUser?.fullName ?? '',
                              style: const TextStyle(
                                  color: AppTheme.cream,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16)),
                          const SizedBox(height: 4),
                          Row(children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.leather.withAlpha(45),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                auth.currentUser?.role == 'hr_manager'
                                    ? 'HR Manager'
                                    : 'Supervisor',
                                style: const TextStyle(
                                    color: AppTheme.leather,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(auth.currentUser?.email ?? '',
                                  style: const TextStyle(
                                      color: AppTheme.warmGrey,
                                      fontSize: 12),
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ]),
                        ],
                      )),
                    ]),
                  ),
                ]),
              ),
            ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction(
      {required this.icon, required this.label,
       required this.color,  required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withAlpha(60)),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: color.withAlpha(35), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(
                  color: AppTheme.warmGrey,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}