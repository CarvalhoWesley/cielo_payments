import 'dart:async';
import 'dart:convert';

import 'package:cielo_payments/cielo_payments.dart';
import 'package:cielo_payments/models/order_request/order_request.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'cielo_deeplink_payments_platform_interface.dart';

/// The [MethodChannelCieloDeeplinkPayments] class is the default implementation
/// of [CieloDeeplinkPaymentsPlatform], using method channels to communicate
/// with native platform code for handling Cielo payments and refunds.
///
/// This implementation manages state to ensure only one operation is
/// processed at a time and handles communication with the native platform
/// via the `MethodChannel`.
class MethodChannelCieloDeeplinkPayments extends CieloDeeplinkPaymentsPlatform {
  static final _controller = StreamController<Order>.broadcast();
  static Stream<Order> get onTransaction => _controller.stream;

  /// The [MethodChannel] usedc to interact with native platform code.
  ///
  /// This channel communicates with the platform using the channel name `cielo_payments`.
  @visibleForTesting
  final methodChannel = const MethodChannel('cielo_payments');

  /// Tracks whether a payment or refund operation is currently in progress.
  bool _transactionInProgress = false;
  
  /// Completer para aguardar o fim da impressão
  Completer<void>? _printCompleter;
  
  /// Contador de itens de impressão esperados
  int _expectedPrintResponses = 0;

  /// Creates an instance of [MethodChannelCieloDeeplinkPayments].
  MethodChannelCieloDeeplinkPayments() {
    _startListener();
  }

  void _startListener() async {
    methodChannel.setMethodCallHandler((call) async {
      try {
        if (call.method == 'onDeeplinkResponse') {
          debugPrint('[CALLBACK] Received deeplink response');
          String? response = call.arguments['response'];
          
          // Decrementa o contador de respostas esperadas PRIMEIRO
          if (_expectedPrintResponses > 0) {
            _expectedPrintResponses--;
            debugPrint('[CALLBACK] Print response. Remaining: $_expectedPrintResponses');
            
            // Só completa quando todas as impressões terminarem
            if (_expectedPrintResponses == 0) {
              debugPrint('[CALLBACK] All prints completed! Completing completer and resetting state');
              _transactionInProgress = false;
              
              // Completa o Completer de forma assíncrona para evitar deadlock
              final completer = _printCompleter;
              _printCompleter = null;
              
              Future.microtask(() {
                debugPrint('[CALLBACK] Completing completer asynchronously');
                completer?.complete();
              });
              
              debugPrint('[CALLBACK] Scheduled completer completion');
            }
          } else {
            // Não é impressão, é pagamento - faz o parse do Order
            debugPrint('[CALLBACK] Payment response, parsing Order');
            if (response?.isNotEmpty ?? false) {
              var coverted = String.fromCharCodes(
                  base64Decode(response!.replaceAll("\n", "")));
              debugPrint(coverted);

              final order = Order.fromJson(coverted);
              _controller.add(order);
            }
            _transactionInProgress = false;
          }
        }
      } catch (e) {
        debugPrint('[CALLBACK] Error: $e');
        _transactionInProgress = false;
        _expectedPrintResponses = 0;
        _printCompleter?.completeError(e);
        _printCompleter = null;
        rethrow;
      }
    });
  }

  /// Processes a payment request via the native platform.
  ///
  /// [value] is the payment value and must be greater than zero.
  /// [paymentCode] specifies the type of payment (credit or debit).
  /// [reference] is the transaction identifier and cannot be empty.
  /// [installments] specifies the number of installments (between 1 and 12).
  /// [clientId] is the client ID for authentication.
  /// [accessToken] is the access token for authentication.
  /// Returns a [Order] object containing the transaction details, or
  /// `null` if a transaction is already in progress or if the result is `null`.
  ///
  /// Throws an exception if an error occurs during platform communication.
  @override
  Future<void> payment(OrderRequest order, String urlCallback) async {
    try {
      if (_transactionInProgress) return;

      _transactionInProgress = true;

      await methodChannel.invokeMethod(
        'paymentDeeplink',
        <String, dynamic>{
          'request': order.toJsonBase64(),
          'urlCallback': urlCallback,
        },
      );
    } catch (e) {
      _transactionInProgress = false;
      rethrow;
    }
  }

  /// Processes a payment request via the native platform.
  ///
  /// [value] is the payment value and must be greater than zero.
  /// [paymentCode] specifies the type of payment (credit or debit).
  /// [reference] is the transaction identifier and cannot be empty.
  /// [installments] specifies the number of installments (between 1 and 12).
  /// [clientId] is the client ID for authentication.
  /// [accessToken] is the access token for authentication.
  /// Returns a [Order] object containing the transaction details, or
  /// `null` if a transaction is already in progress or if the result is `null`.
  ///
  /// Throws an exception if an error occurs during platform communication.
  @override
  Future<void> print(List<ItemPrintModel> items, String urlCallback) async {
    debugPrint('[PRINT] Method called with ${items.length} items');
    try {
      // Aguarda transação anterior terminar
      debugPrint('[PRINT] Checking if transaction in progress: $_transactionInProgress');
      while (_transactionInProgress) {
        debugPrint('[PRINT] Waiting for previous transaction to finish...');
        await Future.delayed(const Duration(seconds: 1));
      }

      debugPrint('[PRINT] Setting transaction in progress');
      _transactionInProgress = true;
      _printCompleter = Completer<void>();

      final List<String> requests = [];
      for (var item in items) {
        final object = await item.toPrint();
        final request = base64.encode(utf8.encode(jsonEncode(object)));
        requests.add(request);
      }

      // Define quantas respostas esperamos (uma para cada item)
      _expectedPrintResponses = requests.length;
      debugPrint('Starting print with ${requests.length} items');

      debugPrint('[PRINT] Calling method channel');
      await methodChannel.invokeMethod(
        'printDeeplink',
        <String, dynamic>{
          'requests': requests,
          'urlCallback': urlCallback,
        },
      );
      
      debugPrint('[PRINT] Method channel returned, waiting for completer');
      // Aguarda todas as impressões completarem
      await _printCompleter!.future;
      debugPrint('[PRINT] Completer completed! Method returning.');
    } catch (e) {
      debugPrint('[PRINT] Error: $e');
      _transactionInProgress = false;
      _expectedPrintResponses = 0;
      _printCompleter = null;
      rethrow;
    }
  }
}
