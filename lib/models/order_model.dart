// lib/models/order_model.dart
class OrderItem {
  final int? id;
  final int orderId;
  final int productId;
  final String productName;
  final String size;
  final String color;
  final int quantity;
  final double unitPrice;

  OrderItem({
    this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.size,
    required this.color,
    required this.quantity,
    required this.unitPrice,
  });

  double get totalPrice => quantity * unitPrice;

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: map['id'],
      orderId: map['order_id'],
      productId: map['product_id'],
      productName: map['product_name'] ?? '',
      size: map['size'],
      color: map['color'],
      quantity: map['quantity'],
      unitPrice: double.parse(map['unit_price'].toString()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'order_id': orderId,
      'product_id': productId,
      'size': size,
      'color': color,
      'quantity': quantity,
      'unit_price': unitPrice,
    };
  }
}

class OrderModel {
  final int? id;
  final String orderNumber;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String shippingAddress;
  final List<OrderItem> items;
  final String status; // 'pending', 'processing', 'shipped', 'delivered', 'cancelled'
  final double totalAmount;
  final DateTime orderDate;
  final DateTime? estimatedDelivery;
  final String? trackingNumber;
  final String? notes;

  OrderModel({
    this.id,
    required this.orderNumber,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.shippingAddress,
    required this.items,
    required this.status,
    required this.totalAmount,
    required this.orderDate,
    this.estimatedDelivery,
    this.trackingNumber,
    this.notes,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, {List<OrderItem> items = const []}) {
    return OrderModel(
      id: map['id'],
      orderNumber: map['order_number'],
      customerName: map['customer_name'],
      customerEmail: map['customer_email'],
      customerPhone: map['customer_phone'],
      shippingAddress: map['shipping_address'],
      items: items,
      status: map['status'],
      totalAmount: double.parse(map['total_amount'].toString()),
      orderDate: map['order_date'] is DateTime
          ? map['order_date']
          : DateTime.parse(map['order_date'].toString()),
      estimatedDelivery: map['estimated_delivery'] != null
          ? (map['estimated_delivery'] is DateTime
              ? map['estimated_delivery']
              : DateTime.parse(map['estimated_delivery'].toString()))
          : null,
      trackingNumber: map['tracking_number'],
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'order_number': orderNumber,
      'customer_name': customerName,
      'customer_email': customerEmail,
      'customer_phone': customerPhone,
      'shipping_address': shippingAddress,
      'status': status,
      'total_amount': totalAmount,
      'order_date': orderDate.toIso8601String(),
      'estimated_delivery': estimatedDelivery?.toIso8601String(),
      'tracking_number': trackingNumber,
      'notes': notes,
    };
  }

  OrderModel copyWith({
    String? status,
    String? trackingNumber,
    DateTime? estimatedDelivery,
  }) {
    return OrderModel(
      id: id,
      orderNumber: orderNumber,
      customerName: customerName,
      customerEmail: customerEmail,
      customerPhone: customerPhone,
      shippingAddress: shippingAddress,
      items: items,
      status: status ?? this.status,
      totalAmount: totalAmount,
      orderDate: orderDate,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      notes: notes,
    );
  }
}
