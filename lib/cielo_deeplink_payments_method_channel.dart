import 'dart:async';
import 'dart:convert';

import 'package:cielo_payments/models/order/order.dart';
import 'package:cielo_payments/models/order_request/order_request.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:uni_links3/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

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

  /// The [MethodChannel] used to interact with native platform code.
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
    try {
      await getInitialLink();
    } on PlatformException catch (e) {
      print("error: ${e.toString()}");
    }

    uriLinkStream.listen((Uri? uri) {
      _transactionInProgress = false;

      if (uri == null) return;

      String? response = uri.queryParameters["response"];

      if (response?.isNotEmpty ?? false) {
        var coverted =
            String.fromCharCodes(base64Decode(response!.replaceAll("\n", "")));
        print(coverted);

        final order = Order.fromJson(coverted);
        _controller.add(order);
      }
    }, onError: (err) {
      print(err.toString());
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
  Future<void> payment(OrderRequest order) async {
    try {
      if (_transactionInProgress) return;

      _transactionInProgress = true;

      final uri = Uri(
        scheme: 'lio',
        host: 'payment',
        queryParameters: {
          'request': order.toJsonBase64(),
          'urlCallback': 'cielo://response',
        },
      );

      launchUrl(uri);
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
  Future<void> printText() async {
    try {
      if (_transactionInProgress) return;

      _transactionInProgress = true;

      final object = {
        "operation": "PRINT_MULTI_COLUMN_TEXT",
        "styles": [
          {
            "key_attributes_align": 1,
            "key_attributes_textsize": 30,
            "key_attributes_typeface": 0
          },
          {
            "key_attributes_align": 0,
            "key_attributes_textsize": 20,
            "key_attributes_typeface": 1
          },
          {
            "key_attributes_align": 2,
            "key_attributes_textsize": 15,
            "key_attributes_typeface": 2
          }
        ],
        "value": [
          "Texto alinhado à esquerda.\n\n\n",
          "Texto centralizado\n\n\n",
          "Texto alinhado à direita\n\n\n"
        ]
      };

      final uri = Uri(
        scheme: 'lio',
        host: 'print',
        queryParameters: {
          'request': base64.encode(utf8.encode(jsonEncode(object))),
          'urlCallback': 'cielo://response',
        },
      );

      launchUrl(uri);
    } catch (e) {
      _transactionInProgress = false;
      rethrow;
    }
  }
}
