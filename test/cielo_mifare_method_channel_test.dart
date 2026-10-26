import 'package:cielo_payments/cielo_mifare_method_channel.dart';
import 'package:cielo_payments/cielo_payments.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final platform = MethodChannelCieloMifare();
  final calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(platform.methodChannel, (call) async {
      calls.add(call);
      switch (call.method) {
        case 'mifareDetectCard':
          return '17401059';
        case 'mifareReadBlock':
          return Uint8List.fromList(List.generate(16, (i) => i));
        case 'mifareWriteBlock':
          throw PlatformException(code: 'R05', message: 'falha');
      }
      return null;
    });
  });

  test('detectCard retorna o UID', () async {
    final card = await platform.detectCard();
    expect(card.uuid, '17401059');
  });

  test('authenticateSector envia setor, chave e tipo', () async {
    final key = Uint8List.fromList(List.filled(6, 0xFF));
    await platform.authenticateSector(
        sector: 2, key: key, keyType: MifareKeyTypeEnum.typeB);
    expect(calls.single.method, 'mifareAuthenticateSector');
    expect(calls.single.arguments,
        {'sector': 2, 'key': key, 'keyType': 'B'});
  });

  test('readBlock retorna os bytes', () async {
    final data = await platform.readBlock(sector: 1, block: 0);
    expect(data.length, 16);
    expect(calls.single.arguments, {'sector': 1, 'block': 0});
  });

  test('erro nativo vira PlatformException com o código da Cielo', () {
    expect(
      platform.writeBlock(sector: 1, block: 0, data: Uint8List(16)),
      throwsA(isA<PlatformException>().having((e) => e.code, 'code', 'R05')),
    );
  });

  test('backupBlock envia o bloco de destino', () async {
    await platform.backupBlock(sector: 3, block: 1, destinationBlock: 2);
    expect(calls.single.method, 'mifareBackupBlock');
    expect(calls.single.arguments,
        {'sector': 3, 'block': 1, 'destinationBlock': 2});
  });
}
