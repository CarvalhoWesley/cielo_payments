import 'dart:typed_data';

import 'package:cielo_payments/cielo_mifare_method_channel.dart';
import 'package:cielo_payments/enums/mifare/mifare_key_type_enum.dart';
import 'package:cielo_payments/models/mifare/mifare_card.dart';

/// The [CieloMifarePlatform] abstract class defines the contract for
/// platform-specific implementations of the Cielo Smart Mifare service.
///
/// By default, the [MethodChannelCieloMifare] implementation is used.
/// Developers can override it by setting [CieloMifarePlatform.instance].
abstract class CieloMifarePlatform {
  /// The current instance of [CieloMifarePlatform].
  static CieloMifarePlatform instance = MethodChannelCieloMifare();

  /// Mifare - Detect card
  Future<MifareCard> detectCard();

  /// Mifare - Authenticate sector
  Future<void> authenticateSector({
    required int sector,
    required Uint8List key,
    required MifareKeyTypeEnum keyType,
  });

  /// Mifare - Read block
  Future<Uint8List> readBlock({required int sector, required int block});

  /// Mifare - Write block
  Future<void> writeBlock({
    required int sector,
    required int block,
    required Uint8List data,
  });

  /// Mifare - Increment value
  Future<void> incrementValue({
    required int sector,
    required int block,
    required int value,
  });

  /// Mifare - Decrement value
  Future<void> decrementValue({
    required int sector,
    required int block,
    required int value,
  });

  /// Mifare - Backup block
  Future<void> backupBlock({
    required int sector,
    required int block,
    required int destinationBlock,
  });

  /// Mifare - Restore block
  Future<void> restoreBlock({
    required int sector,
    required int block,
    required int destinationBlock,
  });

  /// Mifare - Deactivate
  Future<void> powerOff();

  /// Mifare - Cancel detection
  Future<void> cancelDetection();
}
