// lib/screens/order_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/order_model.dart';
import '../services/database_service.dart';
import '../utils/app_theme.dart';
import '../widgets/common_widgets.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<OrderModel> _orders = [];
  bool _loading = true;
  int _tabIndex = 0;

  static const List<Map<String, String>> _tabs = [
    {'key': 'all', 'label': 'All'},
    {'key': 'pending', 'label': 'Pending'},
    {'key': 'processing', 'label': 'Processing'},
    {'key': 'shipped', 'label': 'Shipped'},
    {'key': 'delivered', 'label': 'Delivered'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _tabIndex = _tabController.index);
      }
    });
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() => _loading = true);
    try {
      final orders = await DatabaseService().getOrders();
      setState(() { _orders = orders; _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  List<OrderModel> get _filtered {
    final key = _tabs[_tabIndex]['key']!;
    if (key == 'all') return _orders;
    return _orders.where((o) => o.status == key).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _loadOrders),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: () => _showNewOrderDialog(context),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('New Order'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.success,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppTheme.white,
          labelColor: AppTheme.white,
          unselectedLabelColor: AppTheme.beige,
          tabs: _tabs.map((t) {
            final count = t['key'] == 'all'
                ? _orders.length
                : _orders.where((o) => o.status == t['key']).length;
            return Tab(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(t['label']!),
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
              ]),
            );
          }).toList(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.leather))
          : Column(children: [
              if (_tabIndex == 0) _buildSummaryRow(),
              Expanded(child: _buildOrderList()),
            ]),
    );
  }

  Widget _buildSummaryRow() {
    final total = _orders.fold(
        0.0, (sum, o) => o.status != 'cancelled' ? sum + o.totalAmount : sum);
    final fmt = NumberFormat.currency(symbol: r'₹', decimalDigits: 0);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppTheme.white,
      child: Row(children: [
        _StatPill('Total', '${_orders.length}', AppTheme.leather),
        const SizedBox(width: 12),
        _StatPill('Revenue', fmt.format(total), AppTheme.success),
        const SizedBox(width: 12),
        _StatPill('Pending',
            '${_orders.where((o) => o.status == 'pending').length}', AppTheme.warning),
        const SizedBox(width: 12),
        _StatPill('Shipped',
            '${_orders.where((o) => o.status == 'shipped').length}',
            AppTheme.info),
      ]),
    );
  }

  Widget _buildOrderList() {
    final orders = _filtered;
    if (orders.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.receipt_long_rounded,
              size: 52, color: AppTheme.border),
          const SizedBox(height: 12),
          const Text('No orders found', style: TextStyle(color: AppTheme.textMuted)),
        ]),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (ctx, i) => _OrderCard(
        order: orders[i],
        onStatusChange: (newStatus, tracking) async {
          await DatabaseService().updateOrderStatus(orders[i].id!, newStatus,
              trackingNumber: tracking);
          _loadOrders();
        },
      ),
    );
  }

  void _showNewOrderDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (ctx) => _NewOrderDialog(onCreated: _loadOrders));
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatPill(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withAlpha(18),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withAlpha(60)),
        ),
        child: Column(children: [
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 16)),
          Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 9)),
        ]),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final Function(String status, String? tracking) onStatusChange;

  const _OrderCard({required this.order, required this.onStatusChange});

  static const List<String> _statuses = [
    'pending', 'processing', 'shipped', 'delivered', 'cancelled'
  ];

  @override
  Widget build(BuildContext context) {
    final priceFmt = NumberFormat.currency(symbol: r'₹');
    final dateFmt = DateFormat('MMM d, yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(order.orderNumber,
                      style: const TextStyle(color: AppTheme.mahogany,
                          fontWeight: FontWeight.w800, fontSize: 15)),
                  const SizedBox(width: 10),
                  StatusBadge(status: order.status),
                ]),
                const SizedBox(height: 4),
                Text(order.customerName,
                    style: const TextStyle(color: AppTheme.espresso,
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text(order.customerEmail,
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              ]),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(priceFmt.format(order.totalAmount),
                  style: const TextStyle(color: AppTheme.espresso,
                      fontWeight: FontWeight.w800, fontSize: 17)),
              const SizedBox(height: 4),
              Text(dateFmt.format(order.orderDate),
                  style: const TextStyle(color: AppTheme.textFaint, fontSize: 11)),
            ]),
          ]),
        ),
        Divider(color: AppTheme.border, height: 1),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.location_on_outlined, size: 12, color: AppTheme.textFaint),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(order.shippingAddress,
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ]),
                if (order.estimatedDelivery != null) ...[
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.schedule_rounded, size: 12, color: AppTheme.textFaint),
                    const SizedBox(width: 4),
                    Text('ETA: ${dateFmt.format(order.estimatedDelivery!)}',
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                  ]),
                ],
                if (order.trackingNumber != null) ...[
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.local_shipping_rounded, size: 12, color: AppTheme.info),
                    const SizedBox(width: 4),
                    Text('Track: ${order.trackingNumber}',
                        style: const TextStyle(color: AppTheme.info, fontSize: 11)),
                  ]),
                ],
              ]),
            ),
            if (order.status != 'delivered' && order.status != 'cancelled')
              PopupMenuButton<String>(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.pillBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.more_vert_rounded, size: 18, color: AppTheme.textMuted),
                ),
                itemBuilder: (ctx) => _statuses
                    .where((s) => s != order.status)
                    .map((s) => PopupMenuItem<String>(
                          value: s,
                          child: Row(children: [
                            Container(
                              width: 8, height: 8,
                              decoration: BoxDecoration(
                                  color: AppColors.statusColor(s),
                                  shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 10),
                            Text(AppColors.statusLabel(s),
                                style: const TextStyle(color: AppTheme.espresso)),
                          ]),
                        ))
                    .toList(),
                onSelected: (newStatus) async {
                  String? trackingNumber;
                  if (newStatus == 'shipped') {
                    if (!context.mounted) return;
                    trackingNumber = await _showTrackingDialog(context);
                  }
                  onStatusChange(newStatus, trackingNumber);
                },
              ),
          ]),
        ),
        if (order.status != 'cancelled') _OrderProgressBar(status: order.status),
      ]),
    );
  }

  Future<String?> _showTrackingDialog(BuildContext context) async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Tracking Number',
            style: TextStyle(color: AppTheme.espresso)),
        content: TextField(
          controller: ctrl,
          style: const TextStyle(color: AppTheme.espresso),
          decoration: const InputDecoration(
            labelText: 'Tracking Number',
            prefixIcon: Icon(Icons.local_shipping_rounded),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Skip', style: TextStyle(color: AppTheme.textMuted))),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text),
              child: const Text('Confirm')),
        ],
      ),
    );
  }
}

class _OrderProgressBar extends StatelessWidget {
  final String status;
  const _OrderProgressBar({required this.status});

  static const List<String> _stages = [
    'pending', 'processing', 'shipped', 'delivered'
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = _stages.indexOf(status);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Row(
        children: _stages.asMap().entries.map((entry) {
          final i = entry.key;
          final stage = entry.value;
          final isDone = i <= currentIndex;
          final isCurrent = i == currentIndex;
          final color = isCurrent
              ? AppColors.statusColor(stage)
              : (isDone ? AppTheme.success : AppTheme.border);

          return Expanded(
            child: Column(children: [
              Row(children: [
                if (i > 0)
                  Expanded(
                      child: Container(
                          height: 2,
                          color: i <= currentIndex ? AppTheme.success : AppTheme.border)),
                Container(
                    width: 10, height: 10,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                if (i < _stages.length - 1)
                  Expanded(child: Container(height: 2, color: Colors.transparent)),
              ]),
              const SizedBox(height: 4),
              Text(AppColors.statusLabel(stage),
                  style: TextStyle(
                      color: isCurrent ? color : AppTheme.textFaint,
                      fontSize: 8,
                      fontWeight: isCurrent ? FontWeight.w700 : FontWeight.normal),
                  textAlign: TextAlign.center),
            ]),
          );
        }).toList(),
      ),
    );
  }
}

// ─── New Order Dialog ─────────────────────────────────────────────────────────
class _NewOrderDialog extends StatefulWidget {
  final VoidCallback onCreated;
  const _NewOrderDialog({required this.onCreated});

  @override
  State<_NewOrderDialog> createState() => _NewOrderDialogState();
}

class _NewOrderDialogState extends State<_NewOrderDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addrCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _phoneCtrl.dispose();
    _addrCtrl.dispose(); _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final ts = DateTime.now().millisecondsSinceEpoch.toString();
      final orderNumber = 'ORD-${DateTime.now().year}-${ts.substring(ts.length - 5)}';
      final order = OrderModel(
        orderNumber: orderNumber,
        customerName: _nameCtrl.text,
        customerEmail: _emailCtrl.text,
        customerPhone: _phoneCtrl.text,
        shippingAddress: _addrCtrl.text,
        items: [],
        status: 'pending',
        totalAmount: 0.0,
        orderDate: DateTime.now(),
        estimatedDelivery: DateTime.now().add(const Duration(days: 7)),
        notes: _notesCtrl.text,
      );
      await DatabaseService().addOrder(order);
      if (!mounted) return;
      Navigator.pop(context);
      widget.onCreated();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Order $orderNumber created!'),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.danger));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('New Order',
                  style: TextStyle(color: AppTheme.espresso,
                      fontWeight: FontWeight.w800, fontSize: 20)),
              const SizedBox(height: 20),
              _field(_nameCtrl, 'Customer Name', Icons.business_rounded),
              const SizedBox(height: 12),
              _field(_emailCtrl, 'Email', Icons.email_rounded, required: false),
              const SizedBox(height: 12),
              _field(_phoneCtrl, 'Phone', Icons.phone_rounded, required: false),
              const SizedBox(height: 12),
              _field(_addrCtrl, 'Shipping Address', Icons.location_on_rounded, maxLines: 2),
              const SizedBox(height: 12),
              _field(_notesCtrl, 'Notes', Icons.note_rounded, required: false, maxLines: 2),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.border),
                      foregroundColor: AppTheme.textMuted,
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(
                                color: AppTheme.white, strokeWidth: 2))
                        : const Text('Create Order'),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  TextFormField _field(TextEditingController ctrl, String label, IconData icon,
      {bool required = true, int maxLines = 1}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      style: const TextStyle(color: AppTheme.espresso),
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      validator: required ? (v) => v!.isEmpty ? '$label required' : null : null,
    );
  }
}
