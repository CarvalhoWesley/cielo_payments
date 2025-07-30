import 'dart:async';

import 'package:cielo_payments/cielo_payments.dart';
import 'package:cielo_payments/cielo_deeplink_payments_platform_interface.dart';
import 'package:cielo_payments/models/order_request/order_request.dart';
import 'package:flutter/foundation.dart';

/// The [CieloDeeplinkPayments] class provides methods to perform
/// payments and refunds using the Cielo platform via deeplinks.
///
/// This class validates input parameters and delegates operations
/// to the platform interface [CieloDeeplinkPaymentsPlatform].
class CieloDeeplinkPayments {
  late String _clientId;
  late String _accessToken;
  late String _urlCallback;

  StreamSubscription<Order> Function(
    ValueChanged<Order>?, {
    bool? cancelOnError,
    VoidCallback? onDone,
    Function? onError,
  }) get onTransactionListener =>
      CieloDeeplinkPaymentsPlatform.onTransaction.listen;

  Future<void> init({
    required String clientId,
    required String accessToken,
    String urlCallback = 'cielo://response',
  }) async {
    assert(clientId.isNotEmpty, 'Client ID cannot be empty');
    assert(accessToken.isNotEmpty, 'Access token cannot be empty');

    _clientId = clientId;
    _accessToken = accessToken;
    _urlCallback = urlCallback;
  }

  /// Processes a payment with the provided parameters.
  ///
  /// [value] is the payment amount and must be greater than zero.
  /// [paymentType] specifies the type of payment (credit or debit).
  /// [callerId] is the transaction identifier and cannot be empty.
  /// [installments] specifies the number of installments (between 1 and 12).
  /// [creditType] (optional) specifies the credit type for credit payments (creditMerchant or creditIssuer).
  /// For debit payments, this value must always be 1.
  ///
  /// Returns a [Order] object containing transaction details, or
  /// `null` if the transaction fails.
  ///
  /// Throws an exception if:
  /// - [value] is less than or equal to 0.
  /// - [installments] is less than 1 or greater than 12.
  /// - [callerId] is empty.
  /// - The number of installments is not 1 for debit payment types.
  Future<void> payment(OrderRequest order) async {
    assert(order.value != null && order.value != "",
        'The payment value must be greater than zero');

    assert((order.installments ?? 0) > 0 && (order.installments ?? 0) <= 12,
        'The number of installments must be between 1 and 12');

    assert(order.reference != null && order.reference != "",
        'The transaction identifier cannot be empty');

    if (order.paymentCode == PaymentCodeEnum.debitoAVista) {
      assert((order.installments ?? 0) == 1,
          'Installments must equal 1 for debit payments');
    }

    order = order.copyWith(
      accessToken: _accessToken,
      clientID: _clientId,
    );

    try {
      // Delegate the payment process to the platform
      return CieloDeeplinkPaymentsPlatform.instance
          .payment(order, _urlCallback);
    } catch (e) {
      // Emit the error through the stream
      rethrow;
    }
  }

  Future<void> print(List<ItemPrintModel> items) async {
    try {
      return CieloDeeplinkPaymentsPlatform.instance
          .print(items, _urlCallback);
    } catch (e) {
      rethrow;
    }
  }

  /// Processes a refund for a transaction based on the provided parameters.
  ///
  /// [amount] is the refund amount and must be greater than zero.
  /// [transactionDate] (optional) specifies the date of the original transaction.
  /// [cvNumber] (optional) is the control number of the transaction (CV).
  /// [originTerminal] (optional) identifies the origin terminal.
  ///
  /// Returns a [Order] object containing refund details, or
  /// `null` if the operation fails.
  ///
  /// Throws an exception if:
  /// - [amount] is less than or equal to 0.
  // Future<Order?> refund({
  //   required double amount,
  //   DateTime? transactionDate,
  //   String? cvNumber,
  //   String? originTerminal,
  // }) async {
  //   assert(amount > 0, 'The refund amount must be greater than zero');

  //   try {
  //     // Delegate the refund process to the platform
  //     return CieloDeeplinkPaymentsPlatform.instance.refund(
  //       amount: amount,
  //       transactionDate: transactionDate,
  //       cvNumber: cvNumber,
  //       originTerminal: originTerminal,
  //     );
  //   } catch (e) {
  //     // Emit the error through the stream
  //     rethrow;
  //   }
  // }

  /// Reprints the last transaction receipt.
  /// Returns a [String] containing the reprint result, or
  /// `null` if the operation fails.
  /// Throws an exception if an error occurs during platform communication.
  /// This method is only available on Android.
  // Future<String?> reprint() {
  //   try {
  //     return CieloDeeplinkPaymentsPlatform.instance.reprint();
  //   } catch (e) {
  //     rethrow;
  //   }
  // }
}
