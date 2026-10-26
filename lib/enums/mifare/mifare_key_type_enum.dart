/// Enum to define the Mifare key type used to authenticate a sector
/// [MifareKeyTypeEnum.typeA] = "A"
/// [MifareKeyTypeEnum.typeB] = "B"
enum MifareKeyTypeEnum {
  /// Key A
  typeA('A'),

  /// Key B
  typeB('B');

  /// Value sent to the Cielo cashless service
  final String value;

  const MifareKeyTypeEnum(this.value);
}
