import 'package:flutter/material.dart';

import '../core/ui.dart';
import 'deeplink_store.dart';

class DeeplinkTransactionsTab extends StatelessWidget {
  const DeeplinkTransactionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ActionPage(busy: false, children: [
      ValueListenableBuilder(
        valueListenable: DeeplinkStore.transactions,
        builder: (context, transactions, _) => Section(
          title: 'Transações aprovadas',
          hint: transactions.isEmpty
              ? 'Nenhuma transação nesta sessão. Faça um pagamento na aba Pagamento.'
              : 'Pedidos pagos nesta sessão.',
          children: [
            for (final o in transactions)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.receipt),
                title: Text(
                    'R\$ ${DeeplinkStore.amountToDouble(o.price).toStringAsFixed(2)}'),
                subtitle: Text('Pedido ${o.number ?? o.id ?? '-'}'),
              ),
          ],
        ),
      ),
    ]);
  }
}
