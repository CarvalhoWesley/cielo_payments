import 'package:cielo_payments/cielo_deeplink_payments.dart';
import 'package:cielo_payments/cielo_mifare.dart';

export 'cielo_mifare.dart';
export 'cielo_mifare_cashless.dart';
export 'enums/mifare/mifare_key_type_enum.dart';

export 'enums/order/payment_code_enum.dart';
export 'enums/pos/align_mode_enum.dart';
export 'enums/pos/type_face_enum.dart';
export 'models/mifare/mifare_card.dart';
export 'models/mifare/mifare_cashless_card.dart';
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

  /// Mifare Classic 1K via serviço cashless da Cielo Smart.
  static CieloMifare mifare = CieloMifare();
}
