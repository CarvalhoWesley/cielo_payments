import 'dart:typed_data';

import 'package:cielo_payments/cielo_mifare_platform_interface.dart';
import 'package:cielo_payments/enums/mifare/mifare_key_type_enum.dart';
import 'package:cielo_payments/models/mifare/mifare_card.dart';

/// The [CieloMifare] class provides access to Mifare Classic 1K cards on the
/// Cielo Smart through the `cielo.lio.cashless` service.
///
/// Flow: [detectCard] → [authenticateSector] → read/write/value operations
/// → [powerOff]. `block` is relative to the sector (0..3).
///
/// On failure a `PlatformException` is thrown. The code is the `result`
/// returned by Cielo (anything other than `R00`) or one of: `BUSY`,
/// `TIMEOUT`, `NO_SERVICE`, `ABORTED`, `NFC_ERROR`.
///
/// Example:
/// ```dart
/// await CieloPayments.mifare.detectCard();
/// try {
///   await CieloPayments.mifare.authenticateSector(sector: 1, key: key);
///   final data = await CieloPayments.mifare.readBlock(sector: 1, block: 0);
/// } finally {
///   await CieloPayments.mifare.powerOff();
/// }
/// ```
class CieloMifare {
  /// Aguarda a aproximação de um cartão e o ativa.
  ///
  /// Após as operações no cartão, chame [powerOff].
  Future<MifareCard> detectCard() {
    return CieloMifarePlatform.instance.detectCard();
  }

  /// Autentica [sector] (0..15) com a chave de 6 bytes [key].
  Future<void> authenticateSector({
    required int sector,
    required Uint8List key,
    MifareKeyTypeEnum keyType = MifareKeyTypeEnum.typeA,
  }) {
    assert(key.length == 6, 'A chave Mifare deve ter 6 bytes.');
    return CieloMifarePlatform.instance
        .authenticateSector(sector: sector, key: key, keyType: keyType);
  }

  /// Lê os 16 bytes do [block] (0..3) do [sector].
  Future<Uint8List> readBlock({required int sector, required int block}) {
    return CieloMifarePlatform.instance.readBlock(sector: sector, block: block);
  }

  /// Grava 16 bytes no [block] (0..3) do [sector].
  Future<void> writeBlock({
    required int sector,
    required int block,
    required Uint8List data,
  }) {
    assert(data.length == 16, 'O bloco Mifare deve ter 16 bytes.');
    return CieloMifarePlatform.instance
        .writeBlock(sector: sector, block: block, data: data);
  }

  /// Incrementa [value] (0..127) num bloco de valor.
  Future<void> incrementValue({
    required int sector,
    required int block,
    required int value,
  }) {
    assert(value >= 0 && value <= 127, 'O valor deve estar entre 0 e 127.');
    return CieloMifarePlatform.instance
        .incrementValue(sector: sector, block: block, value: value);
  }

  /// Decrementa [value] (0..127) num bloco de valor.
  Future<void> decrementValue({
    required int sector,
    required int block,
    required int value,
  }) {
    assert(value >= 0 && value <= 127, 'O valor deve estar entre 0 e 127.');
    return CieloMifarePlatform.instance
        .decrementValue(sector: sector, block: block, value: value);
  }

  /// Copia o bloco de valor [block] para [destinationBlock] (mesmo setor).
  Future<void> backupBlock({
    required int sector,
    required int block,
    required int destinationBlock,
  }) {
    return CieloMifarePlatform.instance.backupBlock(
        sector: sector, block: block, destinationBlock: destinationBlock);
  }

  /// Restaura o bloco de valor [block] em [destinationBlock] (mesmo setor).
  Future<void> restoreBlock({
    required int sector,
    required int block,
    required int destinationBlock,
  }) {
    return CieloMifarePlatform.instance.restoreBlock(
        sector: sector, block: block, destinationBlock: destinationBlock);
  }

  /// Desativa a antena e encerra a sessão do cartão.
  Future<void> powerOff() {
    return CieloMifarePlatform.instance.powerOff();
  }

  /// Cancela a operação em andamento (ex.: espera pelo cartão).
  Future<void> cancelDetection() {
    return CieloMifarePlatform.instance.cancelDetection();
  }
}
