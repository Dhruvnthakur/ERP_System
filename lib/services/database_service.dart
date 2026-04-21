// lib/services/database_service.dart
//
// ══════════════════════════════════════════════════════════════════════════════
//  SoleERP — Supabase Database Service
//  Replaces the local PostgreSQL service with Supabase (online, multi-device).
//
//  SETUP STEPS:
//  ─────────────────────────────────────────────────────────────────────────────
//  1. Go to https://supabase.com → New Project → note your:
//       • Project URL  → paste into _supabaseUrl below
//       • Anon/public key → paste into _supabaseAnonKey below
//
//  2. In pubspec.yaml replace:
//       postgres: ^2.6.4
//     with:
//       supabase_flutter: ^2.5.6
//
//  3. Run:  flutter pub get
//
//  4. In Supabase Dashboard → SQL Editor → run supabase_setup.sql
//     (provided alongside this file — creates all tables + seeds data)
//
//  5. Replace lib/services/database_service.dart with this file.
//
//  6. In lib/main.dart add inside main() BEFORE runApp():
//       await Supabase.initialize(
//         url:    DatabaseService.supabaseUrl,
//         anonKey: DatabaseService.supabaseAnonKey,
//       );
//     And add this import:
//       import 'package:supabase_flutter/supabase_flutter.dart';
//
//  That's it — the app now works from any device with internet access.
// ══════════════════════════════════════════════════════════════════════════════

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../models/inventory_model.dart';
import '../models/order_model.dart';

class DatabaseService {
  // ── Supabase credentials ────────────────────────────────────────────────────
  // Replace these with your actual project values from supabase.com/dashboard
  static const String supabaseUrl     = 'https://skdvftikujbdfbxpxbmc.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_ov9mdBms50I-9hfWVNCPpg_S2d6PLcW';

  // ── Singleton ───────────────────────────────────────────────────────────────
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  // Supabase client — initialized once via Supabase.initialize() in main.dart
  SupabaseClient get _db => Supabase.instance.client;

  // ── initializeDatabase ──────────────────────────────────────────────────────
  // With Supabase the schema is created via SQL Editor (supabase_setup.sql).
  // This method is kept for API compatibility — it's a no-op here.
  Future<void> initializeDatabase() async {
    // Tables are created in Supabase Dashboard → SQL Editor.
    // Nothing to do at runtime.
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  USER / AUTH
  // ════════════════════════════════════════════════════════════════════════════

  /// Simple username+password login against the `users` table.
  /// Supabase Auth (email/password) is a future upgrade path;
  /// for now we keep the same login logic as the local version.
  Future<UserModel?> login(String username, String password) async {
    final res = await _db
        .from('users')
        .select()
        .eq('username', username)
        .eq('password', password)
        .maybeSingle();

    if (res == null) return null;
    return UserModel.fromMap(res);
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  PRODUCTS
  // ════════════════════════════════════════════════════════════════════════════

  Future<List<ProductModel>> getProducts({bool activeOnly = false}) async {
    var query = _db.from('products').select();
    if (activeOnly) query = query.eq('is_active', true);
    final res = await query.order('created_at', ascending: false);
    return (res as List).map((r) => ProductModel.fromMap(r)).toList();
  }

  Future<ProductModel> addProduct(ProductModel product) async {
    final res = await _db
        .from('products')
        .insert({
          'name':             product.name,
          'sku':              product.sku,
          'category':         product.category,
          'description':      product.description,
          'available_sizes':  product.availableSizes.join(','),
          'available_colors': product.availableColors.join(','),
          'price':            product.price,
          'image_url':        product.imageUrl,
          'material':         product.material,
          'gender':           product.gender,
          'is_active':        product.isActive,
        })
        .select()
        .single();
    return ProductModel.fromMap(res);
  }

  Future<void> updateProduct(ProductModel product) async {
    await _db.from('products').update({
      'name':             product.name,
      'category':         product.category,
      'description':      product.description,
      'available_sizes':  product.availableSizes.join(','),
      'available_colors': product.availableColors.join(','),
      'price':            product.price,
      'image_url':        product.imageUrl,
      'material':         product.material,
      'gender':           product.gender,
      'is_active':        product.isActive,
    }).eq('id', product.id!);
  }

  Future<void> deleteProduct(int id) async {
    await _db.from('products').update({'is_active': false}).eq('id', id);
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  INVENTORY
  // ════════════════════════════════════════════════════════════════════════════

  Future<List<InventoryItem>> getInventoryItems() async {
    // Supabase supports joining via select with embedded resources
    final res = await _db
        .from('inventory')
        .select('*, products(name)')
        .order('last_updated', ascending: false);

    return (res as List).map((r) {
      final map = Map<String, dynamic>.from(r);
      // Flatten the joined product name
      map['product_name'] = r['products']?['name'] ?? '';
      return InventoryItem.fromMap(map);
    }).toList();
  }

  Future<List<RawMaterial>> getRawMaterials() async {
    final res = await _db
        .from('raw_materials')
        .select()
        .order('name', ascending: true);
    return (res as List).map((r) => RawMaterial.fromMap(r)).toList();
  }

  Future<void> updateRawMaterial(RawMaterial material) async {
    await _db.from('raw_materials').update({
      'quantity':     material.quantity,
      'supplier':     material.supplier,
      'last_updated': DateTime.now().toIso8601String(),
    }).eq('id', material.id!);
  }

  Future<void> addRawMaterial(RawMaterial material) async {
    await _db.from('raw_materials').insert({
      'name':          material.name,
      'unit':          material.unit,
      'quantity':      material.quantity,
      'minimum_stock': material.minimumStock,
      'supplier':      material.supplier,
    });
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  MANUFACTURING BATCHES
  // ════════════════════════════════════════════════════════════════════════════

  Future<List<ManufacturingBatch>> getManufacturingBatches() async {
    final res = await _db
        .from('manufacturing_batches')
        .select('*, products(name)')
        .neq('status', 'completed')
        .order('expected_completion', ascending: true);

    return (res as List).map((r) {
      final map = Map<String, dynamic>.from(r);
      map['product_name'] = r['products']?['name'] ?? '';
      return ManufacturingBatch.fromMap(map);
    }).toList();
  }

  Future<void> updateBatchStatus(int batchId, String status) async {
    await _db
        .from('manufacturing_batches')
        .update({'status': status})
        .eq('id', batchId);
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  ORDERS
  // ════════════════════════════════════════════════════════════════════════════

  Future<List<OrderModel>> getOrders({String? status}) async {
    var query = _db.from('orders').select();
    if (status != null) query = query.eq('status', status);
    final res = await query.order('order_date', ascending: false);
    return (res as List).map((r) => OrderModel.fromMap(r)).toList();
  }

  Future<OrderModel> addOrder(OrderModel order) async {
    final res = await _db
        .from('orders')
        .insert({
          'order_number':      order.orderNumber,
          'customer_name':     order.customerName,
          'customer_email':    order.customerEmail,
          'customer_phone':    order.customerPhone,
          'shipping_address':  order.shippingAddress,
          'status':            order.status,
          'total_amount':      order.totalAmount,
          'estimated_delivery': order.estimatedDelivery?.toIso8601String(),
          'notes':             order.notes,
        })
        .select()
        .single();
    return OrderModel.fromMap(res);
  }

  Future<void> updateOrderStatus(
    int orderId,
    String status, {
    String? trackingNumber,
  }) async {
    final update = <String, dynamic>{'status': status};
    if (trackingNumber != null && trackingNumber.isNotEmpty) {
      update['tracking_number'] = trackingNumber;
    }
    await _db.from('orders').update(update).eq('id', orderId);
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  DASHBOARD STATS
  // ════════════════════════════════════════════════════════════════════════════

  Future<Map<String, dynamic>> getDashboardStats() async {
    // Run all queries in parallel for speed
    final results = await Future.wait([
      // 0 — total active products
      _db.from('products').select('id').eq('is_active', true),
      // 1 — total orders
      _db.from('orders').select('id'),
      // 2 — pending orders
      _db.from('orders').select('id').eq('status', 'pending'),
      // 3 — revenue (non-cancelled, non-pending orders)
      _db
          .from('orders')
          .select('total_amount')
          .neq('status', 'cancelled')
          .neq('status', 'pending'),
      // 4 — low stock items
      _db.from('inventory').select('id').eq('status', 'low_stock'),
      // 5 — active manufacturing batches
      _db
          .from('manufacturing_batches')
          .select('id')
          .neq('status', 'completed'),
    ]);

    // Calculate total revenue from returned rows
    final revenueRows = results[3] as List;
    final totalRevenue = revenueRows.fold<double>(
      0.0,
      (sum, row) => sum + (double.tryParse(row['total_amount'].toString()) ?? 0),
    );

    return {
      'total_products':       (results[0] as List).length,
      'total_orders':         (results[1] as List).length,
      'pending_orders':       (results[2] as List).length,
      'total_revenue':        totalRevenue,
      'low_stock_items':      (results[4] as List).length,
      'manufacturing_batches':(results[5] as List).length,
    };
  }
}
