import 'package:cielo_payments/cielo_deeplink_payments_method_channel.dart';
import 'package:cielo_payments/models/order/order.dart';
import 'package:cielo_payments/models/order_request/order_request.dart';
import 'package:cielo_payments/models/pos/item_print_model.dart';

/// The [CieloDeeplinkPaymentsPlatform] abstract class defines the contract
/// for platform-specific implementations of Cielo deeplink payments.
///
/// This class acts as an interface, delegating calls to a specific platform
/// implementation. By default, the [MethodChannelCieloDeeplinkPayments]
/// implementation is used.
///
/// Developers can override the platform implementation by setting
/// [CieloDeeplinkPaymentsPlatform.instance] to a custom implementation.
abstract class CieloDeeplinkPaymentsPlatform {
  /// The current instance of [CieloDeeplinkPaymentsPlatform].
  ///
  /// By default, this is set to [MethodChannelCieloDeeplinkPayments].
  static CieloDeeplinkPaymentsPlatform instance =
      MethodChannelCieloDeeplinkPayments();

  static Stream<Order> get onTransaction =>
      MethodChannelCieloDeeplinkPayments.onTransaction;

  /// Processes a payment with the provided parameters.
  ///
  /// [value] is the payment value and must be greater than zero.
  /// [paymentCode] specifies the type of payment (credit, debit, voucher or pix).
  /// [reference] is the transaction identifier and cannot be empty.
  /// [installments] specifies the number of installments.
  /// [clientId] is the client ID for authentication.
  /// [accessToken] is the access token for authentication.
  /// Returns a [Order] object containing transaction details, or
  /// `null` if the transaction fails.
  ///
  /// This method must be implemented by a platform-specific class.
  Future<void> payment(OrderRequest order, String urlCallback);

  /// Processes a refund for a transaction with the provided parameters.
  ///
  /// [amount] is the refund amount and must be greater than zero.
  /// [transactionDate] (optional) specifies the date of the original transaction.
  /// [cvNumber] (optional) is the control number of the transaction (CV).
  /// [originTerminal] (optional) identifies the origin terminal.
  ///
  /// Returns a [Order] object containing refund details, or
  /// `null` if the operation fails.
  ///
  /// This method must be implemented by a platform-specific class.
  // Future<Order?> refund({
  //   required double amount,
  //   DateTime? transactionDate,
  //   String? cvNumber,
  //   String? originTerminal,
  // });

  /// Reprints a last transaction receipt.
  /// Returns a [String] containing the reprint result, or `null` if the operation fails.
  Future<void> print(List<ItemPrintModel> items, String urlCallback);
}
