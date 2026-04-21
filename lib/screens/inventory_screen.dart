// lib/screens/inventory_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/inventory_model.dart';
import '../services/database_service.dart';
import '../utils/app_theme.dart';
import '../widgets/common_widgets.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<InventoryItem> _inventoryItems = [];
  List<RawMaterial> _rawMaterials = [];
  List<ManufacturingBatch> _batches = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final db = DatabaseService();
      final items = await db.getInventoryItems();
      final materials = await db.getRawMaterials();
      final batches = await db.getManufacturingBatches();
      setState(() {
        _inventoryItems = items;
        _rawMaterials = materials;
        _batches = batches;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Tab _buildTab(IconData icon, String label, int count) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(label),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: AppTheme.white.withAlpha(40),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('$count',
                style: const TextStyle(fontSize: 10, color: AppTheme.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh_rounded), onPressed: _loadData),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.white,
          labelColor: AppTheme.white,
          unselectedLabelColor: AppTheme.beige,
          tabs: [
            _buildTab(Icons.inventory_2_rounded, 'Stock', _inventoryItems.length),
            _buildTab(Icons.factory_rounded, 'Manufacturing', _batches.length),
            _buildTab(Icons.warehouse_rounded, 'Raw Materials', _rawMaterials.length),
          ],
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.leather))
          : TabBarView(
              controller: _tabController,
              children: [
                _StockTab(items: _inventoryItems),
                _ManufacturingTab(batches: _batches, onRefresh: _loadData),
                _RawMaterialsTab(materials: _rawMaterials, onRefresh: _loadData),
              ],
            ),
    );
  }
}

// ─── Stock Tab ────────────────────────────────────────────────────────────────
class _StockTab extends StatelessWidget {
  final List<InventoryItem> items;
  const _StockTab({required this.items});

  @override
  Widget build(BuildContext context) {
    final inStock = items.where((i) => i.status == 'in_stock').toList();
    final lowStock = items.where((i) => i.status == 'low_stock').toList();
    final manufacturing = items.where((i) => i.status == 'manufacturing').toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            _StockSummaryCard('In Stock', inStock.length, AppTheme.success, Icons.check_circle_rounded),
            const SizedBox(width: 10),
            _StockSummaryCard('Low Stock', lowStock.length, AppTheme.warning, Icons.warning_amber_rounded),
            const SizedBox(width: 10),
            _StockSummaryCard('Mfg.', manufacturing.length, AppTheme.info, Icons.precision_manufacturing_rounded),
          ]),
          const SizedBox(height: 20),
          if (lowStock.isNotEmpty) ...[
            const SectionHeader(title: '⚠️ Low Stock Alert'),
            const SizedBox(height: 10),
            ...lowStock.map((item) => _InventoryItemCard(item: item, highlight: true)),
            const SizedBox(height: 16),
          ],
          SectionHeader(title: 'All Inventory (${items.length} items)'),
          const SizedBox(height: 10),
          ...items.map((item) => _InventoryItemCard(item: item)),
        ],
      ),
    );
  }
}

class _StockSummaryCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _StockSummaryCard(this.label, this.count, this.color, this.icon);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(60)),
          boxShadow: [BoxShadow(
            color: AppTheme.mahogany.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )],
        ),
        child: Column(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text('$count',
              style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w800)),
          Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
        ]),
      ),
    );
  }
}

class _InventoryItemCard extends StatelessWidget {
  final InventoryItem item;
  final bool highlight;

  const _InventoryItemCard({required this.item, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: highlight ? AppTheme.warning.withAlpha(12) : AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlight ? AppTheme.warning.withAlpha(80) : AppTheme.border,
        ),
        boxShadow: [BoxShadow(
          color: AppTheme.mahogany.withAlpha(8),
          blurRadius: 6,
          offset: const Offset(0, 2),
        )],
      ),
      child: Row(children: [
        Container(
          width: 46, height: 46,
          decoration: BoxDecoration(
            color: AppTheme.iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.checkroom_rounded, size: 24, color: AppTheme.leather),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.productName,
                  style: const TextStyle(
                      color: AppTheme.espresso, fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 4),
              Row(children: [
                _pill('Size ${item.size}'),
                const SizedBox(width: 6),
                _pill(item.color),
              ]),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${item.quantity}',
                style: const TextStyle(
                    color: AppTheme.espresso, fontWeight: FontWeight.w800, fontSize: 18)),
            const Text('units', style: TextStyle(color: AppTheme.textFaint, fontSize: 10)),
            const SizedBox(height: 4),
            StatusBadge(status: item.status),
          ],
        ),
      ]),
    );
  }

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.pillBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.border),
      ),
      child: Text(text, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
    );
  }
}

// ─── Manufacturing Tab ────────────────────────────────────────────────────────
class _ManufacturingTab extends StatelessWidget {
  final List<ManufacturingBatch> batches;
  final VoidCallback onRefresh;

  const _ManufacturingTab({required this.batches, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    if (batches.isEmpty) {
      return const Center(
          child: Text('No active manufacturing batches',
              style: TextStyle(color: AppTheme.warmGrey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: batches.length,
      itemBuilder: (ctx, i) =>
          _BatchCard(batch: batches[i], onRefresh: onRefresh),
    );
  }
}

class _BatchCard extends StatelessWidget {
  final ManufacturingBatch batch;
  final VoidCallback onRefresh;

  const _BatchCard({required this.batch, required this.onRefresh});

  static const List<String> _stages = [
    'cutting', 'stitching', 'finishing', 'quality_check', 'completed'
  ];

  Future<void> _updateStatus(BuildContext context) async {
    final currentIndex = _stages.indexOf(batch.status);
    if (currentIndex >= _stages.length - 1) return;

    final nextStatus = _stages[currentIndex + 1];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update Status', style: TextStyle(color: AppTheme.espresso)),
        content: Text('Advance to "${AppColors.statusLabel(nextStatus)}"?',
            style: const TextStyle(color: AppTheme.warmGrey)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel', style: TextStyle(color: AppTheme.warmGrey))),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Confirm')),
        ],
      ),
    );
    if (confirmed == true) {
      await DatabaseService().updateBatchStatus(batch.id!, nextStatus);
      onRefresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = batch.progressPercent;
    final color = AppColors.statusColor(batch.status);
    final dateFormat = DateFormat('MMM d, yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
        boxShadow: [BoxShadow(
          color: AppTheme.mahogany.withAlpha(10),
          blurRadius: 10,
          offset: const Offset(0, 3),
        )],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(batch.productName,
                      style: const TextStyle(
                          color: AppTheme.espresso, fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text('Qty: ${batch.quantity} pairs  •  Supervisor: ${batch.supervisorName}',
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                ],
              ),
            ),
            StatusBadge(status: batch.status),
          ]),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppTheme.pillBg,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${(progress * 100).toInt()}% Complete',
                  style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
              Text('ETA: ${dateFormat.format(batch.expectedCompletion)}',
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
            ],
          ),
          if (batch.status != 'completed' && batch.status != 'quality_check') ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _updateStatus(context),
                icon: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
                label: const Text('Advance Stage'),
                style: TextButton.styleFrom(foregroundColor: AppTheme.leather),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Raw Materials Tab ────────────────────────────────────────────────────────
class _RawMaterialsTab extends StatelessWidget {
  final List<RawMaterial> materials;
  final VoidCallback onRefresh;

  const _RawMaterialsTab({required this.materials, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: materials.length,
      itemBuilder: (ctx, i) =>
          _MaterialCard(material: materials[i], onRefresh: onRefresh),
    );
  }
}

class _MaterialCard extends StatelessWidget {
  final RawMaterial material;
  final VoidCallback onRefresh;

  const _MaterialCard({required this.material, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final percent =
        (material.quantity / (material.minimumStock * 5)).clamp(0.0, 1.0);
    final color = material.isLowStock ? AppTheme.warning : AppTheme.success;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: material.isLowStock
              ? AppTheme.warning.withAlpha(80)
              : AppTheme.border,
        ),
        boxShadow: [BoxShadow(
          color: AppTheme.mahogany.withAlpha(8),
          blurRadius: 8,
          offset: const Offset(0, 2),
        )],
      ),
      child: Column(children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.inventory_rounded, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(material.name,
                    style: const TextStyle(
                        color: AppTheme.espresso, fontWeight: FontWeight.w600)),
                Text('Supplier: ${material.supplier}',
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${material.quantity} ${material.unit}',
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.w700, fontSize: 15)),
              Text('Min: ${material.minimumStock}',
                  style: const TextStyle(color: AppTheme.textFaint, fontSize: 11)),
            ],
          ),
        ]),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: percent,
            backgroundColor: AppTheme.pillBg,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
        if (material.isLowStock) ...[
          const SizedBox(height: 8),
          const Row(children: [
            Icon(Icons.warning_amber_rounded, color: AppTheme.warning, size: 14),
            SizedBox(width: 4),
            Text('Low stock — Reorder needed',
                style: TextStyle(color: AppTheme.warning, fontSize: 11)),
          ]),
        ],
      ]),
    );
  }
}
