import 'package:cielo_payments/cielo_payments.dart';
import 'package:cielo_payments/models/order_request/order_request.dart';
import 'package:cielo_payments/models/order_request/order_request_item.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../core/app_log.dart';
import '../core/ui.dart';

class DeeplinkPaymentTab extends StatefulWidget {
  const DeeplinkPaymentTab({super.key});

  @override
  State<DeeplinkPaymentTab> createState() => _DeeplinkPaymentTabState();
}

class _DeeplinkPaymentTabState extends State<DeeplinkPaymentTab>
    with ActionRunner, AutomaticKeepAliveClientMixin {
  final _value = TextEditingController(text: '12.50');

  @override
  LogSource get logSource => LogSource.deeplink;

  @override
  bool get wantKeepAlive => true;

  Future<String?> _pay(PaymentCodeEnum type, {int installments = 1}) async {
    final cents = (parseAmount(_value.text) * 100).round();
    await CieloPayments.deeplink.payment(OrderRequest(
      email: 'teste@exemplo.com',
      value: cents.toString(),
      paymentCode: type,
      reference: const Uuid().v4(),
      installments: installments,
      items: [
        OrderRequestItem(
          name: 'Produto 1',
          quantity: 1,
          unitPrice: cents,
          sku: '1',
          unitOfMeasure: 'unidade',
        ),
      ],
    ));
    return 'app da Cielo aberto; o resultado chega em Transações e Logs';
  }

  @override
  void dispose() {
    _value.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final enabled = !busy;
    return ActionPage(busy: busy, children: [
      Section(
        title: 'Nova transação',
        hint: 'Abre o app de pagamento da Cielo. Ao terminar, o resultado '
            'volta para este app e aparece em Transações e na aba Logs.',
        children: [
          FieldWrap(children: [
            AppField(controller: _value, label: 'Valor (R\$)', numeric: true),
          ]),
          ActionWrap(children: [
            ActionButton(
              label: 'Crédito',
              icon: Icons.credit_card,
              primary: true,
              onPressed: enabled
                  ? () => run(
                      'Crédito', () => _pay(PaymentCodeEnum.creditoAVista))
                  : null,
            ),
            ActionButton(
              label: 'Crédito 12x',
              icon: Icons.credit_card,
              onPressed: enabled
                  ? () => run(
                      'Crédito 12x',
                      () => _pay(PaymentCodeEnum.creditoAVista,
                          installments: 12))
                  : null,
            ),
            ActionButton(
              label: 'Débito',
              icon: Icons.payment,
              onPressed: enabled
                  ? () =>
                      run('Débito', () => _pay(PaymentCodeEnum.debitoAVista))
                  : null,
            ),
            ActionButton(
              label: 'Voucher',
              icon: Icons.card_giftcard,
              onPressed: enabled
                  ? () => run('Voucher',
                      () => _pay(PaymentCodeEnum.voucherAlimentacao))
                  : null,
            ),
            ActionButton(
              label: 'PIX',
              icon: Icons.qr_code,
              onPressed: enabled
                  ? () => run('PIX', () => _pay(PaymentCodeEnum.pix))
                  : null,
            ),
          ]),
        ],
      ),
    ]);
  }
}
