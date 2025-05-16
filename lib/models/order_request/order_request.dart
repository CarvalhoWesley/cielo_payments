// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cielo_payments/cielo_payments.dart';
import 'package:cielo_payments/models/order_request/order_request_item.dart';

class OrderRequest {
  final String? accessToken;
  final String? clientID;
  final String? reference;
  final String? merchantCode;
  final String? email;
  final int? installments;
  final PaymentCodeEnum? paymentCode;
  final String? value;
  final List<OrderRequestItem>? items;

  OrderRequest({
    this.accessToken,
    this.clientID,
    this.reference,
    this.merchantCode,
    required this.email,
    required this.installments,
    required this.paymentCode,
    required this.value,
    required this.items,
  });

  OrderRequest copyWith({
    String? accessToken,
    String? clientID,
    String? reference,
    String? merchantCode,
    String? email,
    int? installments,
    PaymentCodeEnum? paymentCode,
    String? value,
    List<OrderRequestItem>? items,
  }) {
    return OrderRequest(
      accessToken: accessToken ?? this.accessToken,
      clientID: clientID ?? this.clientID,
      reference: reference ?? this.reference,
      merchantCode: merchantCode ?? this.merchantCode,
      email: email ?? this.email,
      installments: installments ?? this.installments,
      paymentCode: paymentCode ?? this.paymentCode,
      value: value ?? this.value,
      items: items ?? this.items,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'accessToken': accessToken,
      'clientID': clientID,
      'reference': reference,
      'merchantCode': merchantCode,
      'email': email,
      'installments': installments,
      'paymentCode': paymentCode?.value,
      'value': value,
      'items': items?.map((x) => x.toMap()).toList(),
    };
  }

  factory OrderRequest.fromMap(Map<String, dynamic> map) {
    return OrderRequest(
      accessToken:
          map['accessToken'] != null ? map['accessToken'] as String : null,
      clientID: map['clientID'] != null ? map['clientID'] as String : null,
      reference: map['reference'] != null ? map['reference'] as String : null,
      merchantCode:
          map['merchantCode'] != null ? map['merchantCode'] as String : null,
      email: map['email'] != null ? map['email'] as String : null,
      installments:
          map['installments'] != null ? map['installments'] as int : null,
      paymentCode: map['paymentCode'] != null
          ? PaymentCodeEnum.get(map['paymentCode'])
          : null,
      value: map['value'] != null ? map['value'] as String : null,
      items: map['items'] != null
          ? List<OrderRequestItem>.from(
              (map['items'] as List<int>).map<OrderRequestItem?>(
                (x) => OrderRequestItem.fromMap(x as Map<String, dynamic>),
              ),
            )
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory OrderRequest.fromJson(String source) =>
      OrderRequest.fromMap(json.decode(source) as Map<String, dynamic>);

  String toJsonBase64() {
    final jsonString = toJson();
    final bytes = utf8.encode(jsonString);
    return base64.encode(bytes);
  }

  @override
  String toString() {
    return 'OrderRequest(accessToken: $accessToken, clientID: $clientID, reference: $reference, merchantCode: $merchantCode, email: $email, installments: $installments, paymentCode: $paymentCode, value: $value, items: $items)';
  }
}
