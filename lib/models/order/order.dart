import 'dart:convert';

import 'package:cielo_payments/models/order/order_item.dart';
import 'package:cielo_payments/models/order/order_payment.dart';

class Order {
  final String? id;
  final String? createdAt;
  final String? updatedAt;
  final String? notes;
  final String? number;
  final int? paidAmount;
  final int? pendingAmount;
  final int? price;
  final String? reference;
  final String? status;
  final String? type;
  final List<OrderItem>? items;
  final List<OrderPayment>? payments;
  final int? code;
  final String? reason;

  Order({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.notes,
    this.number,
    this.paidAmount,
    this.pendingAmount,
    this.price,
    this.reference,
    this.status,
    this.type,
    this.items,
    this.payments,
    this.code,
    this.reason,
  });

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
      notes: map['notes'],
      number: map['number'],
      paidAmount: map['paidAmount'],
      pendingAmount: map['pendingAmount'],
      price: map['price'],
      reference: map['reference'],
      status: map['status'],
      type: map['type'],
      items: (map['items'] as List<dynamic>?)
          ?.map((e) => OrderItem.fromMap(e))
          .toList(),
      payments: (map['payments'] as List<dynamic>?)
          ?.map((e) => OrderPayment.fromMap(e))
          .toList(),
      code: map['code'],
      reason: map['reason'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'notes': notes,
      'number': number,
      'paidAmount': paidAmount,
      'pendingAmount': pendingAmount,
      'price': price,
      'reference': reference,
      'status': status,
      'type': type,
      'items': items?.map((e) => e.toMap()).toList(),
      'payments': payments?.map((e) => e.toMap()).toList(),
      'code': code,
      'reason': reason,
    };
  }

  factory Order.fromJson(String source) => Order.fromMap(json.decode(source));

  String toJson() => json.encode(toMap());

  factory Order.fromBase64(String base64) {
    final decoded = base64Decode(base64.replaceAll('\n', ''));
    return Order.fromMap(json.decode(utf8.decode(decoded)));
  }
}
