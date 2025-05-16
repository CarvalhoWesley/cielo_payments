import 'package:cielo_payments/models/order/order_payment_fields.dart';

class OrderPayment {
  final String? id;
  final String? accessKey;
  final int? amount;
  final String? applicationName;
  final String? authCode;
  final String? brand;
  final String? cieloCode;
  final String? description;
  final int? discountedAmount;
  final String? externalId;
  final int? installments;
  final String? mask;
  final String? merchantCode;
  final OrderPaymentFields? paymentFields;
  final String? primaryCode;
  final String? requestDate;
  final String? secondaryCode;
  final String? terminal;

  OrderPayment({
    this.id,
    this.accessKey,
    this.amount,
    this.applicationName,
    this.authCode,
    this.brand,
    this.cieloCode,
    this.description,
    this.discountedAmount,
    this.externalId,
    this.installments,
    this.mask,
    this.merchantCode,
    this.paymentFields,
    this.primaryCode,
    this.requestDate,
    this.secondaryCode,
    this.terminal,
  });

  factory OrderPayment.fromMap(Map<String, dynamic> map) {
    return OrderPayment(
      id: map['id'],
      accessKey: map['accessKey'],
      amount: map['amount'],
      applicationName: map['applicationName'],
      authCode: map['authCode'],
      brand: map['brand'],
      cieloCode: map['cieloCode'],
      description: map['description'],
      discountedAmount: map['discountedAmount'],
      externalId: map['externalId'],
      installments: map['installments'],
      mask: map['mask'],
      merchantCode: map['merchantCode'],
      paymentFields: map['paymentFields'] != null
          ? OrderPaymentFields.fromMap(map['paymentFields'])
          : null,
      primaryCode: map['primaryCode'],
      requestDate: map['requestDate'].toString(),
      secondaryCode: map['secondaryCode'],
      terminal: map['terminal'],
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'accessKey': accessKey,
        'amount': amount,
        'applicationName': applicationName,
        'authCode': authCode,
        'brand': brand,
        'cieloCode': cieloCode,
        'description': description,
        'discountedAmount': discountedAmount,
        'externalId': externalId,
        'installments': installments,
        'mask': mask,
        'merchantCode': merchantCode,
        'paymentFields': paymentFields?.toMap(),
        'primaryCode': primaryCode,
        'requestDate': requestDate,
        'secondaryCode': secondaryCode,
        'terminal': terminal,
      };
}
