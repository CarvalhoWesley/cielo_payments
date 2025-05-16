/// Enum representing different payment codes.
/// This enum is used to identify various payment methods and types.
enum PaymentCodeEnum {
  debitoAVista("DEBITO_AVISTA"),
  debitoPagtoFaturaDebito("DEBITO_PAGTO_FATURA_DEBITO"),
  creditoAVista("CREDITO_AVISTA"),
  creditoParceladoLoja("CREDITO_PARCELADO_LOJA"),
  creditoParceladoAdm("CREDITO_PARCELADO_ADM"),
  creditoParceladoBnco("CREDITO_PARCELADO_BNCO"),
  preAutorizacao("PRE_AUTORIZACAO"),
  creditoParceladoCliente("CREDITO_PARCELADO_CLIENTE"),
  creditoCrediarioCredito("CREDITO_CREDIARIO_CREDITO"),
  voucherAlimentacao("VOUCHER_ALIMENTACAO"),
  voucherRefeicao("VOUCHER_REFEICAO"),
  voucherAutomotivo("VOUCHER_AUTOMOTIVO"),
  voucherCultura("VOUCHER_CULTURA"),
  voucherPedagio("VOUCHER_PEDAGIO"),
  voucherBeneficios("VOUCHER_BENEFICIOS"),
  voucherAuto("VOUCHER_AUTO"),
  voucherConsultaSaldo("VOUCHER_CONSULTA_SALDO"),
  voucherValePedagio("VOUCHER_VALE_PEDAGIO"),
  creditoCrediarioVenda("CREDIARIO_VENDA"),
  creditoCrediarioSimulacao("CREDIARIO_SIMULACAO"),
  cartaoLojaAVista("CARTAO_LOJA_AVISTA"),
  cartaoLojaParceladoLoja("CARTAO_LOJA_PARCELADO_LOJA"),
  cartaoLojaParcelado("CARTAO_LOJA_PARCELADO"),
  cartaoLojaParceladoBanco("CARTAO_LOJA_PARCELADO_BANCO"),
  cartaoLojaPagtoFaturaCheque("CARTAO_LOJA_PAGTO_FATURA_CHEQUE"),
  cartaoLojaPagtoFaturaDinheiro("CARTAO_LOJA_PAGTO_FATURA_DINHEIRO"),
  frotas("FROTAS"),
  pix("PIX");

  final String value;

  const PaymentCodeEnum(this.value);

  static PaymentCodeEnum get(String value) {
    return PaymentCodeEnum.values
        .firstWhere((element) => element.value == value);
  }
}
