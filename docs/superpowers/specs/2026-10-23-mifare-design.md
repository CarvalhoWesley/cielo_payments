# Mifare (Cielo Smart) — Design

## Objetivo

Adicionar ao plugin `cielo_payments` suporte a cartões Mifare Classic 1K na
Cielo Smart, nas três camadas (nativo Kotlin, Dart, app de exemplo), seguindo
o padrão já usado em `stone_payments` (API de baixo nível + camada cashless de
evento).

Referência Cielo: https://docs.cielo.com.br/cielo-smart/docs/cashless e
https://docs.cielo.com.br/cielo-smart/docs/operacoes-suportadas-pelo-mifare

## Integração Cielo

Sem SDK. Cada operação é uma Intent para o pacote `cielo.lio.cashless`
iniciada com `startService`:

| Operação | Action | Extras |
|---|---|---|
| Detectar | `cielo.lio.cashless.mifare.DETECT` | — |
| Autenticar | `...mifare.AUTHENTICATE` | `sector`, `key`, `keyType` (A/B) |
| Ler | `...mifare.READ` | `sector`, `block` |
| Gravar | `...mifare.WRITE` | `sector`, `block`, `data` |
| Incrementar | `...mifare.INCREMENT` | `sector`, `block`, `value` |
| Decrementar | `...mifare.DECREMENT` | `sector`, `block`, `value` |
| Backup | `...mifare.BACKUP` | `sector`, `block`, `destinationBlock` |
| Restore | `...mifare.RESTORE` | `sector`, `block`, `destinationBlock` |
| Desativar | `...mifare.DEACTIVATE` | — |

Extras comuns: `cbType`, `cbPackage`, `cbAction`. Retorno: `result`
(`"R00"` = sucesso), `detail` (mensagem), `data` (bytes; UID no DETECT, bloco
no READ).

## Decisão: retorno via Broadcast

`cbType = "B"`. Para cada operação o plugin gera um `cbAction` único
(`br.com.joelabs.cielo_payments.MIFARE_<OP>_<seq>`), registra em runtime um
`BroadcastReceiver` para essa action (com `RECEIVER_EXPORTED` no Android 13+),
chama `startService` e resolve o `MethodChannel.Result` ao receber o broadcast,
desregistrando o receiver. Alternativas descartadas: Service (exige componente
exportado no manifest e ponte via singleton) e Activity (reabre a tela Flutter).

## Nativo (Kotlin)

- `usecases/MifareUsecase.kt`, instanciado no `CieloPaymentsPlugin` junto do
  `DeeplinkUsecase`, recebendo o `Context` da Activity.
- Métodos do canal `cielo_payments`:
  `mifareDetectCard`, `mifareAuthenticateSector`, `mifareReadBlock`,
  `mifareWriteBlock`, `mifareIncrementValue`, `mifareDecrementValue`,
  `mifareBackupBlock`, `mifareRestoreBlock`, `mifarePowerOff`
  (DEACTIVATE), `mifareCancelDetection` (desregistra o receiver pendente e
  responde `ABORTED`; em seguida envia DEACTIVATE).
- Uma operação por vez; chamada concorrente → erro `BUSY`.
- Erros (`PlatformException.code`):
  - `result != "R00"` → code = valor de `result`, message = `detail`;
  - serviço não encontrado / `SecurityException` → `NO_SERVICE`;
  - sem resposta em 30 s (DETECT: 60 s) → `TIMEOUT`;
  - cancelado → `ABORTED`.
- Retornos: DETECT → UID em hex maiúsculo (String); READ → `ByteArray`;
  demais → `null`.
- Manifest do plugin: `<uses-permission android:name="cielo.lio.permission.CASHLESS"/>`
  e `<package android:name="cielo.lio.cashless"/>` em `<queries>`.

## Dart

Mesmo padrão platform interface / method channel do `cielo_deeplink_*`:

- `lib/enums/mifare/mifare_key_type_enum.dart` — `typeA`, `typeB` (valor `"A"`/`"B"`).
- `lib/models/mifare/mifare_card.dart` — `MifareCard { String uuid }`.
- `lib/models/mifare/mifare_cashless_card.dart` — igual ao da Stone.
- `lib/cielo_mifare_platform_interface.dart`,
  `lib/cielo_mifare_method_channel.dart` (canal `cielo_payments`).
- `lib/cielo_mifare.dart` — `CieloMifare`, exposto como `CieloPayments.mifare`:
  - `Future<MifareCard> detectCard()`
  - `Future<void> authenticateSector({required int sector, required Uint8List key, MifareKeyTypeEnum keyType = typeA})` — assert key 6 bytes
  - `Future<Uint8List> readBlock({required int sector, required int block})`
  - `Future<void> writeBlock({required int sector, required int block, required Uint8List data})` — assert 16 bytes
  - `incrementValue` / `decrementValue({sector, block, required int value})`
  - `backupBlock` / `restoreBlock({sector, block, required int destinationBlock})`
  - `powerOff()`, `cancelDetection()`
  - `block` é relativo ao setor (0..3), como na documentação Cielo.
- `lib/cielo_mifare_cashless.dart` — `CieloMifareCashless`, port de
  `StoneMifareCashless` com o mesmo layout de blocos (absolutos 1, 2, 4, 5, 6,
  8, 9, 12 convertidos para setor/bloco), compatível com cartões
  Stone/PagSeguro. Métodos: `readCard`, `openCard`, `recharge`, `debit`,
  `refund`, `clearCard`. Erros de regra → `MifareCashlessException(code, message)`.
- `cielo_payments.dart` exporta enum, modelos, `CieloMifareCashless` e a exceção.

## App de exemplo

`example/lib/mifare/` espelhando a Stone: `mifare_page.dart` (abas),
`mifare_session.dart`, `card_tab.dart` (detectar/UID), `blocks_tab.dart`
(auth/ler/gravar/inc/dec/backup/restore por setor e bloco),
`event_tab.dart` (cashless). Botão "Mifare" no `main.dart`.

## Testes

- `test/cielo_mifare_method_channel_test.dart`: argumentos e conversões do canal (mock).
- `test/cielo_mifare_cashless_test.dart`: regras de abrir/recarga/débito/estorno
  com uma platform fake em memória.
- Nativo: validação manual em terminal Cielo Smart.

## Fora de escopo

Mifare 4K / Ultralight, helpers de texto estilo Getnet, iOS.
