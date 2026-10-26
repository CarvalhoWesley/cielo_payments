import 'package:cielo_payments/cielo_mifare_platform_interface.dart';
import 'package:cielo_payments/enums/mifare/mifare_key_type_enum.dart';
import 'package:cielo_payments/models/mifare/mifare_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The [MethodChannelCieloMifare] class is the default implementation of
/// [CieloMifarePlatform], using the `cielo_payments` method channel.
class MethodChannelCieloMifare extends CieloMifarePlatform {
  /// The [MethodChannel] used to interact with native platform code.
  @visibleForTesting
  final methodChannel = const MethodChannel('cielo_payments');

  @override
  Future<MifareCard> detectCard() async {
    final uuid = await methodChannel.invokeMethod<String>('mifareDetectCard');
    return MifareCard(uuid: uuid ?? '');
  }

  @override
  Future<void> authenticateSector({
    required int sector,
    required Uint8List key,
    required MifareKeyTypeEnum keyType,
  }) {
    return methodChannel.invokeMethod('mifareAuthenticateSector', {
      'sector': sector,
      'key': key,
      'keyType': keyType.value,
    });
  }

  @override
  Future<Uint8List> readBlock({required int sector, required int block}) async {
    final data = await methodChannel.invokeMethod<Uint8List>(
        'mifareReadBlock', {'sector': sector, 'block': block});
    return data ?? Uint8List(16);
  }

  @override
  Future<void> writeBlock({
    required int sector,
    required int block,
    required Uint8List data,
  }) {
    return methodChannel.invokeMethod('mifareWriteBlock', {
      'sector': sector,
      'block': block,
      'data': data,
    });
  }

  @override
  Future<void> incrementValue({
    required int sector,
    required int block,
    required int value,
  }) {
    return methodChannel.invokeMethod('mifareIncrementValue', {
      'sector': sector,
      'block': block,
      'value': value,
    });
  }

  @override
  Future<void> decrementValue({
    required int sector,
    required int block,
    required int value,
  }) {
    return methodChannel.invokeMethod('mifareDecrementValue', {
      'sector': sector,
      'block': block,
      'value': value,
    });
  }

  @override
  Future<void> backupBlock({
    required int sector,
    required int block,
    required int destinationBlock,
  }) {
    return methodChannel.invokeMethod('mifareBackupBlock', {
      'sector': sector,
      'block': block,
      'destinationBlock': destinationBlock,
    });
  }

  @override
  Future<void> restoreBlock({
    required int sector,
    required int block,
    required int destinationBlock,
  }) {
    return methodChannel.invokeMethod('mifareRestoreBlock', {
      'sector': sector,
      'block': block,
      'destinationBlock': destinationBlock,
    });
  }

  @override
  Future<void> powerOff() => methodChannel.invokeMethod('mifarePowerOff');

  @override
  Future<void> cancelDetection() =>
      methodChannel.invokeMethod('mifareCancelDetection');
}
