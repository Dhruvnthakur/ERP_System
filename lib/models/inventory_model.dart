// lib/models/inventory_model.dart
class InventoryItem {
  final int? id;
  final int productId;
  final String productName;
  final String size;
  final String color;
  final int quantity;
  final String status; // 'in_stock', 'manufacturing', 'low_stock'
  final DateTime lastUpdated;

  InventoryItem({
    this.id,
    required this.productId,
    required this.productName,
    required this.size,
    required this.color,
    required this.quantity,
    required this.status,
    required this.lastUpdated,
  });

  factory InventoryItem.fromMap(Map<String, dynamic> map) {
    return InventoryItem(
      id: map['id'],
      productId: map['product_id'],
      productName: map['product_name'] ?? '',
      size: map['size'],
      color: map['color'],
      quantity: map['quantity'],
      status: map['status'],
      lastUpdated: map['last_updated'] is DateTime
          ? map['last_updated']
          : DateTime.parse(map['last_updated'].toString()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'size': size,
      'color': color,
      'quantity': quantity,
      'status': status,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }
}

class RawMaterial {
  final int? id;
  final String name;
  final String unit;
  final double quantity;
  final double minimumStock;
  final String supplier;
  final DateTime lastUpdated;

  RawMaterial({
    this.id,
    required this.name,
    required this.unit,
    required this.quantity,
    required this.minimumStock,
    required this.supplier,
    required this.lastUpdated,
  });

  bool get isLowStock => quantity <= minimumStock;

  factory RawMaterial.fromMap(Map<String, dynamic> map) {
    return RawMaterial(
      id: map['id'],
      name: map['name'],
      unit: map['unit'],
      quantity: double.parse(map['quantity'].toString()),
      minimumStock: double.parse(map['minimum_stock'].toString()),
      supplier: map['supplier'] ?? '',
      lastUpdated: map['last_updated'] is DateTime
          ? map['last_updated']
          : DateTime.parse(map['last_updated'].toString()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'unit': unit,
      'quantity': quantity,
      'minimum_stock': minimumStock,
      'supplier': supplier,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }
}

class ManufacturingBatch {
  final int? id;
  final int productId;
  final String productName;
  final int quantity;
  final String status; // 'cutting', 'stitching', 'finishing', 'quality_check', 'completed'
  final DateTime startDate;
  final DateTime expectedCompletion;
  final String supervisorName;

  ManufacturingBatch({
    this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.status,
    required this.startDate,
    required this.expectedCompletion,
    required this.supervisorName,
  });

  double get progressPercent {
    switch (status) {
      case 'cutting': return 0.2;
      case 'stitching': return 0.45;
      case 'finishing': return 0.70;
      case 'quality_check': return 0.90;
      case 'completed': return 1.0;
      default: return 0.0;
    }
  }

  factory ManufacturingBatch.fromMap(Map<String, dynamic> map) {
    return ManufacturingBatch(
      id: map['id'],
      productId: map['product_id'],
      productName: map['product_name'] ?? '',
      quantity: map['quantity'],
      status: map['status'],
      startDate: map['start_date'] is DateTime
          ? map['start_date']
          : DateTime.parse(map['start_date'].toString()),
      expectedCompletion: map['expected_completion'] is DateTime
          ? map['expected_completion']
          : DateTime.parse(map['expected_completion'].toString()),
      supervisorName: map['supervisor_name'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'quantity': quantity,
      'status': status,
      'start_date': startDate.toIso8601String(),
      'expected_completion': expectedCompletion.toIso8601String(),
      'supervisor_name': supervisorName,
    };
  }
}
