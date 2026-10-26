import 'dart:typed_data';

import 'package:cielo_payments/cielo_mifare_platform_interface.dart';
import 'package:cielo_payments/cielo_payments.dart';
import 'package:flutter_test/flutter_test.dart';

/// Cartão Mifare 1K em memória.
class FakeMifarePlatform extends CieloMifarePlatform {
  final blocks = List.generate(64, (_) => Uint8List(16));
  int? authenticated;
  int powerOffs = 0;

  @override
  Future<MifareCard> detectCard() async {
    authenticated = null;
    return const MifareCard(uuid: 'AABBCCDD');
  }

  @override
  Future<void> authenticateSector({
    required int sector,
    required Uint8List key,
    required MifareKeyTypeEnum keyType,
  }) async =>
      authenticated = sector;

  void _check(int sector) {
    if (authenticated != sector) throw StateError('setor não autenticado');
  }

  @override
  Future<Uint8List> readBlock({required int sector, required int block}) async {
    _check(sector);
    return Uint8List.fromList(blocks[sector * 4 + block]);
  }

  @override
  Future<void> writeBlock({
    required int sector,
    required int block,
    required Uint8List data,
  }) async {
    _check(sector);
    blocks[sector * 4 + block] = Uint8List.fromList(data);
  }

  @override
  Future<void> powerOff() async => powerOffs++;

  @override
  Future<void> cancelDetection() async {}

  @override
  Future<void> incrementValue(
          {required int sector, required int block, required int value}) =>
      throw UnimplementedError();

  @override
  Future<void> decrementValue(
          {required int sector, required int block, required int value}) =>
      throw UnimplementedError();

  @override
  Future<void> backupBlock(
          {required int sector,
          required int block,
          required int destinationBlock}) =>
      throw UnimplementedError();

  @override
  Future<void> restoreBlock(
          {required int sector,
          required int block,
          required int destinationBlock}) =>
      throw UnimplementedError();
}

void main() {
  late FakeMifarePlatform fake;

  setUp(() {
    fake = FakeMifarePlatform();
    CieloMifarePlatform.instance = fake;
  });

  Matcher cashlessError(String code) =>
      throwsA(isA<MifareCashlessException>().having((e) => e.code, 'code', code));

  test('abre, recarrega, debita e estorna', () async {
    var card = await CieloMifareCashless.openCard(
        value: 50, eventId: 'EVT001', name: 'Fulano');
    expect(card.opened, isTrue);
    expect(card.value, 50);
    expect(card.uuid, 'AABBCCDD');

    card = await CieloMifareCashless.recharge(value: 10, eventId: 'EVT001');
    expect(card.value, 60);
    expect(card.openValue, 60);

    card = await CieloMifareCashless.debit(value: 25.5, eventId: 'EVT001');
    expect(card.value, 34.5);

    card = await CieloMifareCashless.refund(value: 5.5, eventId: 'EVT001');
    expect(card.value, 40);
    expect(card.name, 'Fulano');
    expect(fake.powerOffs, 4);
  });

  test('grava no layout compatível com Stone/PagSeguro', () async {
    await CieloMifareCashless.openCard(value: 50, eventId: 'EVT001');
    expect(String.fromCharCodes(fake.blocks[1]), '***********50.00');
    expect(fake.blocks[8][0], '1'.codeUnitAt(0));
  });

  test('regras de negócio', () async {
    await expectLater(
        CieloMifareCashless.debit(value: 1), cashlessError('cartao_nao_aberto'));
    await CieloMifareCashless.openCard(value: 10, eventId: 'EVT001');
    await expectLater(CieloMifareCashless.openCard(value: 10, eventId: 'EVT001'),
        cashlessError('cartao_ja_aberto'));
    await expectLater(
        CieloMifareCashless.debit(value: 11), cashlessError('saldo_insuficiente'));
    await expectLater(CieloMifareCashless.readCard(eventId: 'OUTRO'),
        cashlessError('evento_nao_compativel'));
    expect(() => CieloMifareCashless.recharge(value: 0),
        cashlessError('valor_invalido'));
  });

  test('format fecha o cartão', () async {
    await CieloMifareCashless.openCard(value: 10, eventId: 'EVT001');
    await CieloMifareCashless.format();
    final card = await CieloMifareCashless.readCard();
    expect(card.opened, isFalse);
    expect(card.value, 0);
  });
}
