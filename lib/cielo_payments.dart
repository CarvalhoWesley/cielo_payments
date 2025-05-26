import 'package:cielo_payments/cielo_deeplink_payments.dart';

export 'enums/order/payment_code_enum.dart';
export 'enums/pos/align_mode_enum.dart';
export 'enums/pos/type_face_enum.dart';
export 'models/order/order.dart';
export 'models/pos/item_print_model.dart';

/// The [CieloPayments] class serves as a facade for accessing and
/// managing instances of [CieloDeeplinkPayments].
///
/// This class provides a static interface for retrieving and optionally
/// replacing the [CieloDeeplinkPayments] instance, enabling flexibility
/// in testing or extending functionality.
class CieloPayments {
  static CieloDeeplinkPayments _deeplink = CieloDeeplinkPayments();

  /// Exposes the instance of the `CieloDeeplinkPayments` class.
  ///
  /// This allows access to the payment and refund functionalities
  /// implemented in [CieloDeeplinkPayments].
  ///
  /// Example:
  /// ```dart
  /// final deeplink = CieloPayments.deeplink;
  /// ```
  static CieloDeeplinkPayments get deeplink => _deeplink;

  /// Replaces the instance of `CieloDeeplinkPayments` if needed.
  ///
  /// This method can be used to provide a mock or alternative implementation
  /// for testing or extending functionality.
  ///
  /// Example:
  /// ```dart
  /// CieloPayments.deeplink = MockCieloDeeplinkPayments();
  /// ```
  ///
  /// [instance] must be a valid instance of [CieloDeeplinkPayments].
  static set deeplink(CieloDeeplinkPayments instance) {
    _deeplink = instance;
  }
}
