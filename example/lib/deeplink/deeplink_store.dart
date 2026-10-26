import 'package:cielo_payments/cielo_payments.dart';
import 'package:flutter/foundation.dart';

import '../core/app_log.dart';

/// Estado compartilhado entre as abas do Deeplink.
class DeeplinkStore {
  DeeplinkStore._();

  static final transactions = ValueNotifier<List<Order>>([]);

  /// Escuta os retornos do app da Cielo: registra no log e guarda os pagos.
  static void listen() {
    CieloPayments.deeplink.onTransactionListener((order) {
      if (order.code != null) {
        AppLog.add(LogSource.deeplink, '[${order.code}] ${order.reason}',
            isError: true);
        return;
      }
      AppLog.add(LogSource.deeplink,
          'Pedido ${order.number ?? order.id}: ${order.status} | R\$ ${amountToDouble(order.price).toStringAsFixed(2)}');
      if (order.status == 'PAID') {
        transactions.value = [order, ...transactions.value];
      }
    });
  }

  /// O deeplink devolve o valor em centavos (ex.: 1050 = R$ 10,50).
  static double amountToDouble(int? amount) => (amount ?? 0) / 100;
}
