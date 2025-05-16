class OrderItem {
  final String? id;
  final String? name;
  final String? description;
  final String? details;
  final String? reference;
  final String? sku;
  final String? unitOfMeasure;
  final int? quantity;
  final int? unitPrice;

  OrderItem({
    this.id,
    this.name,
    this.description,
    this.details,
    this.reference,
    this.sku,
    this.unitOfMeasure,
    this.quantity,
    this.unitPrice,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      details: map['details'],
      reference: map['reference'],
      sku: map['sku'],
      unitOfMeasure: map['unitOfMeasure'],
      quantity: map['quantity'],
      unitPrice: map['unitPrice'],
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'details': details,
        'reference': reference,
        'sku': sku,
        'unitOfMeasure': unitOfMeasure,
        'quantity': quantity,
        'unitPrice': unitPrice,
      };
}
