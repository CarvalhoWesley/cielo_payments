// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class OrderRequestItem {
  final String? name;
  final int? quantity;
  final String? sku;
  final String? unitOfMeasure;
  final int? unitPrice;

  OrderRequestItem({
    required this.name,
    required this.quantity,
    required this.sku,
    required this.unitOfMeasure,
    required this.unitPrice,
  });

  factory OrderRequestItem.fromMap(Map<String, dynamic> map) {
    return OrderRequestItem(
      name: map['name'] != null ? map['name'] as String : null,
      quantity: map['quantity'] != null ? map['quantity'] as int : null,
      sku: map['sku'] != null ? map['sku'] as String : null,
      unitOfMeasure:
          map['unitOfMeasure'] != null ? map['unitOfMeasure'] as String : null,
      unitPrice: map['unitPrice'] != null ? map['unitPrice'] as int : null,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'quantity': quantity,
      'sku': sku,
      'unitOfMeasure': unitOfMeasure,
      'unitPrice': unitPrice,
    };
  }

  OrderRequestItem copyWith({
    String? name,
    int? quantity,
    String? sku,
    String? unitOfMeasure,
    int? unitPrice,
  }) {
    return OrderRequestItem(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      sku: sku ?? this.sku,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }

  String toJson() => json.encode(toMap());

  factory OrderRequestItem.fromJson(String source) =>
      OrderRequestItem.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'OrderRequestItem(name: $name, quantity: $quantity, sku: $sku, unitOfMeasure: $unitOfMeasure, unitPrice: $unitPrice)';
  }
}
