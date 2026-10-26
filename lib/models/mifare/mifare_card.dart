/// Cartão Mifare detectado pelo serviço cashless da Cielo.
class MifareCard {
  /// UID do cartão em hexadecimal maiúsculo (ex.: "17401059").
  final String uuid;

  /// Cria um [MifareCard].
  const MifareCard({required this.uuid});

  @override
  String toString() => 'MifareCard(uuid: $uuid)';
}
