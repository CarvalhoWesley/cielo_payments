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
  static CieloDeeplinkPayments deeplink = CieloDeeplinkPayments();
}
