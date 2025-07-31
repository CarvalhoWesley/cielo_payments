import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:cielo_payments/cielo_payments.dart';
import 'package:cielo_payments/models/order_request/order_request.dart';
import 'package:cielo_payments/models/order_request/order_request_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: PaymentApp(),
    );
  }
}

class PaymentApp extends StatefulWidget {
  const PaymentApp({super.key});

  @override
  State<PaymentApp> createState() => _PaymentAppState();
}

class _PaymentAppState extends State<PaymentApp>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TextEditingController valueController = TextEditingController(text: '12.50');
  String? mensagem;
  String? mensagemTransacoes;
  final List<Order> _successfulTransactions = [];

  late StreamSubscription listenDeeplink;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    CieloPayments.deeplink.init(
      clientId: 'pekop9oVJoD6yPFepY6pVQI0VDS1XxpHjwAooiQ0Av6BfuAXVU',
      accessToken: '19L5cEBLblVycvisy4Y8Q9xZuIFBezbKSfhXyGMtUdCXUd6Dfv',
      urlCallback: 'cielo_example_app://response',
    );

    listenDeeplink = CieloPayments.deeplink.onTransactionListener((order) {
      _addTransaction(order);
    });
  }

  void _addTransaction(Order order) {
    if (order.code != null) {
      setState(() {
        mensagem = order.reason;
      });
    }

    if (order.status != 'PAID') return;

    setState(() {
      _successfulTransactions.insert(0, order);
    });
  }

  double _convertAmount(Order order) {
    final amount = order.price.toString();
    final amountDouble = double.parse(
        '${amount.substring(0, amount.length - 2)}.${amount.substring(amount.length - 2)}');
    return amountDouble;
  }

  Future<void> _processPrint() async {
    FocusScope.of(context).unfocus();

    final logo = await rootBundle.load('assets/images/logo.png');
    String base64 = base64Encode(logo.buffer.asUint8List());

    CieloPayments.deeplink.print(
      [
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
        ItemPrintModel.image(content: base64),
        ItemPrintModel.linewrap(lines: 4),
      ],
    );
  }

  Future<void> _processPayment(
    PaymentCodeEnum type, {
    int installments = 1,
  }) async {
    FocusScope.of(context).unfocus();
    if (valueController.text.isEmpty) return;

    final valor = double.parse(valueController.text);

    try {
      final order = OrderRequest(
        email: 'carvalhowesley@gmail.com',
        value: (valor * 100).toInt().toString(),
        paymentCode: type,
        reference: const Uuid().v4(),
        installments: installments,
        items: [
          OrderRequestItem(
            name: 'Produto 1',
            quantity: 1,
            unitPrice: (valor * 100).toInt(),
            sku: '1',
            unitOfMeasure: 'unidade',
          ),
        ],
      );

      CieloPayments.deeplink.payment(order);
    } catch (e) {
      log(e.toString());
      setState(() {
        mensagem = 'Erro ao realizar pagamento';
      });
    }
  }

  Future<void> _processReprintLastTransaction() async {
    // FocusScope.of(context).unfocus();

    // try {
    //   final result = await CieloPayments.deeplink.reprint();
    //   if (result != null) {
    //     setState(() {
    //       mensagem = result;
    //     });
    //   }
    // } catch (e) {
    //   log(e.toString());
    //   setState(() {
    //     mensagem = 'Erro ao realizar pagamento';
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cielo Payments'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pagamento'),
            Tab(text: 'Transações'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Pagamento Tab
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: valueController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  decoration: const InputDecoration(
                    hintText: 'Valor',
                    contentPadding: EdgeInsets.all(10.0),
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed: () =>
                          _processPayment(PaymentCodeEnum.creditoAVista),
                      child: const Text('CRÉDITO'),
                    ),
                    ElevatedButton(
                      onPressed: () => _processPayment(
                        PaymentCodeEnum.creditoAVista,
                        installments: 12,
                      ),
                      child: const Text('CRÉDITO 12X'),
                    ),
                    ElevatedButton(
                      onPressed: () =>
                          _processPayment(PaymentCodeEnum.debitoAVista),
                      child: const Text('DÉBITO'),
                    ),
                    ElevatedButton(
                      onPressed: () =>
                          _processPayment(PaymentCodeEnum.voucherAlimentacao),
                      child: const Text('VOUCHER'),
                    ),
                    ElevatedButton(
                      onPressed: () => _processPayment(PaymentCodeEnum.pix),
                      child: const Text('PIX'),
                    ),
                    ElevatedButton(
                      onPressed: () => _processReprintLastTransaction(),
                      child: const Text('REIMPRIMIR ÚLTIMO CUPOM'),
                    ),
                    ElevatedButton(
                      onPressed: () => _processPrint(),
                      child: const Text('TESTAR IMPRESSORA'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (mensagem != null)
                  Column(
                    children: [
                      const Divider(),
                      const Text('Resultado:'),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(mensagem!),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          // Transações Tab
          SizedBox(
            child: Column(
              children: [
                if (mensagemTransacoes != null)
                  Column(
                    children: [
                      const Text('Resultado Reembolso:'),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(mensagemTransacoes!),
                      ),
                    ],
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _successfulTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = _successfulTransactions[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        child: ListTile(
                          title:
                              Text('CV: ${transaction.id ?? 'Sem informação'}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Valor: ${_convertAmount(transaction).toStringAsFixed(2)}'),
                              const Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // FilledButton(
                                  //   onPressed: () async {
                                  //     final refund = await CieloPayments
                                  //         .deeplink
                                  //         .checkStatus(
                                  //       callerId: transaction.callerId!,
                                  //     );

                                  //     if (refund != null) {
                                  //       setState(() {
                                  //         mensagemTransacoes =
                                  //             '${refund.result} - ${refund.resultDetails}';
                                  //       });
                                  //     }
                                  //   },
                                  //   child: const Text('Status'),
                                  // ),
                                  // FilledButton(
                                  //   onPressed: () async {
                                  //     final refund =
                                  //         await CieloPayments.deeplink.refund(
                                  //       amount: _convertAmount(transaction),
                                  //       transactionDate: DateTime.now(),
                                  //       cvNumber: transaction.id,
                                  //     );

                                  //     if (refund != null) {
                                  //       setState(() {
                                  //         mensagemTransacoes =
                                  //             '${refund.result} - ${refund.resultDetails}';
                                  //       });

                                  //       if (refund.result ==
                                  //           TransactionResultEnum
                                  //               .success.value) {
                                  //         _successfulTransactions
                                  //             .removeAt(index);
                                  //       }
                                  //     }
                                  //   },
                                  //   child: const Text('Reembolsar'),
                                  // ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
