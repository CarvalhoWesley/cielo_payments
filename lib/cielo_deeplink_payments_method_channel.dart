import 'dart:async';
import 'dart:convert';

import 'package:cielo_payments/cielo_payments.dart';
import 'package:cielo_payments/models/order_request/order_request.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'cielo_deeplink_payments_platform_interface.dart';

/// The [MethodChannelCieloDeeplinkPayments] class is the default implementation
/// of [CieloDeeplinkPaymentsPlatform], using method channels to communicate
/// with native platform code for handling Cielo payments and refunds.
///
/// This implementation manages state to ensure only one operation is
/// processed at a time and handles communication with the native platform
/// via the `MethodChannel`.
class MethodChannelCieloDeeplinkPayments extends CieloDeeplinkPaymentsPlatform {
  static final _controller = StreamController<Order>.broadcast();
  static Stream<Order> get onTransaction => _controller.stream;
  // Completer<void>? _deeplinkCompleter;

  /// The [MethodChannel] usedc to interact with native platform code.
  ///
  /// This channel communicates with the platform using the channel name `cielo_payments`.
  @visibleForTesting
  final methodChannel = const MethodChannel('cielo_payments');

  /// Tracks whether a payment or refund operation is currently in progress.
  bool _transactionInProgress = false;

  /// Creates an instance of [MethodChannelCieloDeeplinkPayments].
  MethodChannelCieloDeeplinkPayments() {
    _startListener();
  }

  void _startListener() async {
    methodChannel.setMethodCallHandler((call) async {
      _transactionInProgress = false;
      try {
        if (call.method == 'onDeeplinkResponse') {
          final Map<String, dynamic> data =
              Map<String, dynamic>.from(call.arguments);
          final tx = Order.fromMap(data);
          _controller.add(tx);
        }
        // _deeplinkCompleter?.complete();
      } catch (e) {
        rethrow;
      }
    });
  }

  /// Processes a payment request via the native platform.
  ///
  /// [value] is the payment value and must be greater than zero.
  /// [paymentCode] specifies the type of payment (credit or debit).
  /// [reference] is the transaction identifier and cannot be empty.
  /// [installments] specifies the number of installments (between 1 and 12).
  /// [clientId] is the client ID for authentication.
  /// [accessToken] is the access token for authentication.
  /// Returns a [Order] object containing the transaction details, or
  /// `null` if a transaction is already in progress or if the result is `null`.
  ///
  /// Throws an exception if an error occurs during platform communication.
  @override
  Future<void> payment(OrderRequest order, String urlCallback) async {
    try {
      if (_transactionInProgress) return;

      _transactionInProgress = true;

      await methodChannel.invokeMethod(
        'paymentDeeplink',
        <String, dynamic>{
          'request': order.toJsonBase64(),
          'urlCallback': urlCallback,
        },
      );
    } catch (e) {
      _transactionInProgress = false;
      rethrow;
    }
  }

  /// Processes a payment request via the native platform.
  ///
  /// [value] is the payment value and must be greater than zero.
  /// [paymentCode] specifies the type of payment (credit or debit).
  /// [reference] is the transaction identifier and cannot be empty.
  /// [installments] specifies the number of installments (between 1 and 12).
  /// [clientId] is the client ID for authentication.
  /// [accessToken] is the access token for authentication.
  /// Returns a [Order] object containing the transaction details, or
  /// `null` if a transaction is already in progress or if the result is `null`.
  ///
  /// Throws an exception if an error occurs during platform communication.
  @override
  Future<void> print(List<ItemPrintModel> items, String urlCallback) async {
    try {
      if (_transactionInProgress) return;

      _transactionInProgress = true;

      for (var item in items) {
        final object = await item.toPrint();

        final request = base64.encode(utf8.encode(jsonEncode(object)));

        await Future.delayed(const Duration(milliseconds: 100));

        await methodChannel.invokeMethod(
          'printDeeplink',
          <String, dynamic>{
            'request': request,
            'urlCallback': urlCallback,
          },
        );
      }
    } catch (e) {
      _transactionInProgress = false;
    }
  }
}
