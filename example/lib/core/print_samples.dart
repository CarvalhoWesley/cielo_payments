import 'dart:convert';

import 'package:cielo_payments/cielo_payments.dart';
import 'package:flutter/services.dart';

/// Itens de exemplo usados nos testes de impressão.
Future<List<ItemPrintModel>> samplePrintItems({bool withImage = true}) async {
  final items = [
    ItemPrintModel.text(
      content: 'Alinhamento à esquerda',
      align: AlignModeEnum.left,
      typeFace: TypeFaceEnum.normal,
    ),
    ItemPrintModel.text(
      content: 'Centralizado',
      align: AlignModeEnum.center,
      typeFace: TypeFaceEnum.bold,
    ),
    ItemPrintModel.text(
      content: 'Alinhado à direita',
      align: AlignModeEnum.right,
      typeFace: TypeFaceEnum.italic,
    ),
  ];
  if (withImage) {
    final logo = await rootBundle.load('assets/images/logo.png');
    items.add(ItemPrintModel.image(
      content: base64Encode(
          logo.buffer.asUint8List(logo.offsetInBytes, logo.lengthInBytes)),
    ));
  }
  items.add(ItemPrintModel.linewrap(lines: 4));
  return items;
}
