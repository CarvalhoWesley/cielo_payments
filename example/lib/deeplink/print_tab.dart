import 'package:cielo_payments/cielo_payments.dart';
import 'package:flutter/material.dart';

import '../core/app_log.dart';
import '../core/print_samples.dart';
import '../core/ui.dart';

class DeeplinkPrintTab extends StatefulWidget {
  const DeeplinkPrintTab({super.key});

  @override
  State<DeeplinkPrintTab> createState() => _DeeplinkPrintTabState();
}

class _DeeplinkPrintTabState extends State<DeeplinkPrintTab> with ActionRunner {
  @override
  LogSource get logSource => LogSource.deeplink;

  @override
  Widget build(BuildContext context) {
    final enabled = !busy;
    return ActionPage(busy: busy, children: [
      Section(
        title: 'Impressora do POS',
        hint: 'Imprime pelo app da Cielo (deeplink).',
        children: [
          ActionWrap(children: [
            ActionButton(
              label: 'Imprimir texto',
              icon: Icons.text_snippet,
              primary: true,
              onPressed: enabled
                  ? () => run('Imprimir texto', () async {
                        await CieloPayments.deeplink
                            .print(await samplePrintItems(withImage: false));
                        return null;
                      })
                  : null,
            ),
            ActionButton(
              label: 'Imprimir texto + imagem',
              icon: Icons.image,
              onPressed: enabled
                  ? () => run('Imprimir texto + imagem', () async {
                        await CieloPayments.deeplink
                            .print(await samplePrintItems());
                        return null;
                      })
                  : null,
            ),
            ActionButton(
              label: 'Impressão múltipla (5x)',
              icon: Icons.print,
              onPressed: enabled
                  ? () => run('Impressão múltipla', () async {
                        for (var i = 0; i < 5; i++) {
                          await CieloPayments.deeplink
                              .print(await samplePrintItems(withImage: false));
                        }
                        return '5 impressões concluídas';
                      })
                  : null,
            ),
          ]),
        ],
      ),
    ]);
  }
}
