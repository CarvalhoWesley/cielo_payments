# Cielo Payments

[![pub package](https://img.shields.io/pub/v/cielo_payments.svg)](https://pub.dev/packages/cielo_payments)

Um plugin Flutter para integração com terminais de pagamento Cielo LIO através de deeplinks. Permite realizar pagamentos, impressões e outras operações diretamente dos terminais Cielo.

## Características

✅ Pagamentos com cartão de crédito e débito  
✅ Pagamentos PIX  
✅ Vouchers (alimentação, refeição, combustível, etc.)  
✅ Impressão de comprovantes e textos personalizados  
✅ Suporte a parcelamento  
✅ Callbacks assíncronos para resultados de transações  
✅ Fila automática de impressões sequenciais  

## Plataformas Suportadas

| Android | iOS |
|:-------:|:---:|
| ✅      | ❌  |

> **Nota:** Este plugin funciona exclusivamente em terminais Cielo LIO (Android). iOS não é suportado.

## Requisitos

- Flutter SDK: >=3.3.0
- Dart SDK: >=3.1.0 <4.0.0
- Android minSdkVersion: 21
- Terminal Cielo LIO

## Instalação

Adicione o pacote ao seu `pubspec.yaml`:

```yaml
dependencies:
  cielo_payments: ^1.0.0
```

Execute:

```bash
flutter pub get
```

## Configuração

### Android

#### 1. AndroidManifest.xml

Configure o deeplink para receber callbacks do terminal Cielo. Adicione o `intent-filter` na sua `MainActivity`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application>
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            
            <!-- Intent filter padrão -->
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
            
            <!-- Intent filter para deeplinks do Cielo LIO -->
            <intent-filter>
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <!-- Configure o scheme e host conforme seu app -->
                <data android:scheme="seu_app_scheme" android:host="response" />
            </intent-filter>
        </activity>
    </application>
</manifest>
```

**Importante:** 
- Substitua `seu_app_scheme` por um identificador único do seu app (ex: `minhaloja_app`)
- O `android:launchMode="singleTop"` é obrigatório para receber os callbacks corretamente

## Uso

### Inicialização

Inicialize o plugin com suas credenciais Cielo:

```dart
import 'package:cielo_payments/cielo_payments.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription<Order> _transactionSubscription;

  @override
  void initState() {
    super.initState();
    
    // Inicializar o plugin
    CieloPayments.deeplink.init(
      clientId: 'SEU_CLIENT_ID',
      accessToken: 'SEU_ACCESS_TOKEN',
      urlCallback: 'seu_app_scheme://response', // Deve coincidir com o AndroidManifest
    );

    // Escutar callbacks de transações
    _transactionSubscription = CieloPayments.deeplink.onTransactionListener(
      (order) {
        print('Transação recebida: ${order.status}');
        
        if (order.status == 'PAID') {
          // Pagamento aprovado
          print('Pagamento aprovado! ID: ${order.id}');
        } else if (order.code != null) {
          // Erro ou cancelamento
          print('Erro: ${order.reason}');
        }
      },
    );
  }

  @override
  void dispose() {
    _transactionSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomePage());
  }
}
```

### Realizar Pagamento

#### Pagamento em Crédito à Vista

```dart
import 'package:uuid/uuid.dart';

Future<void> processarPagamentoCredito() async {
  final order = OrderRequest(
    email: 'cliente@email.com',
    value: '1250', // R$ 12,50 (em centavos)
    paymentCode: PaymentCodeEnum.creditoAVista,
    reference: const Uuid().v4(), // Identificador único da transação
    installments: 1,
    items: [
      OrderRequestItem(
        name: 'Produto Exemplo',
        quantity: 1,
        unitPrice: 1250,
        sku: 'SKU123',
        unitOfMeasure: 'unidade',
      ),
    ],
  );

  await CieloPayments.deeplink.payment(order);
}
```

#### Pagamento Parcelado

```dart
Future<void> processarPagamentoParcelado() async {
  final order = OrderRequest(
    email: 'cliente@email.com',
    value: '30000', // R$ 300,00
    paymentCode: PaymentCodeEnum.creditoAVista,
    reference: const Uuid().v4(),
    installments: 12, // 12 parcelas
    items: [
      OrderRequestItem(
        name: 'Produto Premium',
        quantity: 1,
        unitPrice: 30000,
        sku: 'PREM001',
        unitOfMeasure: 'unidade',
      ),
    ],
  );

  await CieloPayments.deeplink.payment(order);
}
```

#### Pagamento em Débito

```dart
Future<void> processarPagamentoDebito() async {
  final order = OrderRequest(
    email: 'cliente@email.com',
    value: '5000', // R$ 50,00
    paymentCode: PaymentCodeEnum.debitoAVista,
    reference: const Uuid().v4(),
    installments: 1, // Débito sempre deve ser 1 parcela
    items: [
      OrderRequestItem(
        name: 'Produto Básico',
        quantity: 2,
        unitPrice: 2500,
        sku: 'BAS001',
        unitOfMeasure: 'unidade',
      ),
    ],
  );

  await CieloPayments.deeplink.payment(order);
}
```

#### Pagamento PIX

```dart
Future<void> processarPagamentoPix() async {
  final order = OrderRequest(
    email: 'cliente@email.com',
    value: '7500', // R$ 75,00
    paymentCode: PaymentCodeEnum.pix,
    reference: const Uuid().v4(),
    installments: 1,
    items: [
      OrderRequestItem(
        name: 'Serviço Digital',
        quantity: 1,
        unitPrice: 7500,
        sku: 'SERV001',
        unitOfMeasure: 'serviço',
      ),
    ],
  );

  await CieloPayments.deeplink.payment(order);
}
```

#### Vouchers (Alimentação, Refeição, etc.)

```dart
Future<void> processarVoucherAlimentacao() async {
  final order = OrderRequest(
    email: 'cliente@email.com',
    value: '15000', // R$ 150,00
    paymentCode: PaymentCodeEnum.voucherAlimentacao,
    reference: const Uuid().v4(),
    installments: 1,
    items: [
      OrderRequestItem(
        name: 'Vale Alimentação',
        quantity: 1,
        unitPrice: 15000,
        sku: 'VA001',
        unitOfMeasure: 'vale',
      ),
    ],
  );

  await CieloPayments.deeplink.payment(order);
}
```

### Impressão

#### Imprimir Texto Simples

```dart
Future<void> imprimirTexto() async {
  await CieloPayments.deeplink.print([
    ItemPrintModel.text(
      content: 'Bem-vindo à nossa loja!',
      align: AlignModeEnum.center,
      typeFace: TypeFaceEnum.bold,
    ),
    ItemPrintModel.linewrap(lines: 2), // Pula 2 linhas
  ]);
}
```

#### Imprimir Comprovante Personalizado

```dart
import 'dart:convert';
import 'package:flutter/services.dart';

Future<void> imprimirComprovante() async {
  // Carregar logo do app
  final logo = await rootBundle.load('assets/images/logo.png');
  String base64Logo = base64Encode(logo.buffer.asUint8List());

  await CieloPayments.deeplink.print([
    // Logo centralizada
    ItemPrintModel.image(content: base64Logo),
    ItemPrintModel.linewrap(lines: 1),
    
    // Nome da loja
    ItemPrintModel.text(
      content: 'MINHA LOJA LTDA',
      align: AlignModeEnum.center,
      typeFace: TypeFaceEnum.bold,
    ),
    
    ItemPrintModel.text(
      content: 'CNPJ: 00.000.000/0001-00',
      align: AlignModeEnum.center,
      typeFace: TypeFaceEnum.normal,
    ),
    
    ItemPrintModel.linewrap(lines: 2),
    
    // Detalhes da compra
    ItemPrintModel.text(
      content: 'COMPROVANTE DE VENDA',
      align: AlignModeEnum.center,
      typeFace: TypeFaceEnum.bold,
    ),
    
    ItemPrintModel.linewrap(lines: 1),
    
    ItemPrintModel.text(
      content: 'Produto: Camiseta Básica',
      align: AlignModeEnum.left,
      typeFace: TypeFaceEnum.normal,
    ),
    
    ItemPrintModel.text(
      content: 'Valor: R\$ 49,90',
      align: AlignModeEnum.left,
      typeFace: TypeFaceEnum.normal,
    ),
    
    ItemPrintModel.linewrap(lines: 2),
    
    ItemPrintModel.text(
      content: 'Obrigado pela preferência!',
      align: AlignModeEnum.center,
      typeFace: TypeFaceEnum.italic,
    ),
    
    ItemPrintModel.linewrap(lines: 4),
  ]);
}
```

#### Imprimir QR Code

```dart
Future<void> imprimirQRCode() async {
  await CieloPayments.deeplink.print([
    ItemPrintModel.qrcode(
      content: 'https://www.meusite.com.br/pedido/12345',
    ),
    ItemPrintModel.text(
      content: 'Escaneie para rastrear seu pedido',
      align: AlignModeEnum.center,
      typeFace: TypeFaceEnum.normal,
    ),
  ]);
}
```

#### Imprimir Código de Barras

```dart
Future<void> imprimirCodigoBarras() async {
  await CieloPayments.deeplink.print([
    ItemPrintModel.barcode(
      content: '7891234567890',
      format: 'EAN_13',
    ),
  ]);
}
```

### Tipos de Pagamento Disponíveis

```dart
enum PaymentCodeEnum {
  // Débito
  debitoAVista,                    // Débito à vista
  debitoPagtoFaturaDebito,         // Pagamento de fatura em débito
  
  // Crédito
  creditoAVista,                   // Crédito à vista
  creditoParceladoLoja,            // Parcelado pela loja
  creditoParceladoAdm,             // Parcelado pela administradora
  creditoParceladoBnco,            // Parcelado pelo banco
  preAutorizacao,                  // Pré-autorização
  creditoParceladoCliente,         // Parcelado pelo cliente
  creditoCrediarioCredito,         // Crediário em crédito
  
  // Vouchers
  voucherAlimentacao,              // Vale alimentação
  voucherRefeicao,                 // Vale refeição
  voucherAutomotivo,               // Vale automotivo
  voucherCultura,                  // Vale cultura
  voucherPedagio,                  // Vale pedágio
  voucherBeneficios,               // Vale benefícios
  voucherAuto,                     // Vale auto
  voucherConsultaSaldo,            // Consulta de saldo
  voucherValePedagio,              // Vale pedágio (variante)
  
  // Cartão Loja
  cartaoLojaAVista,                // Cartão loja à vista
  cartaoLojaParceladoLoja,         // Cartão loja parcelado
  cartaoLojaParcelado,             // Cartão loja parcelado (genérico)
  cartaoLojaParceladoBanco,        // Cartão loja parcelado banco
  cartaoLojaPagtoFaturaCheque,     // Pagamento fatura em cheque
  cartaoLojaPagtoFaturaDinheiro,   // Pagamento fatura em dinheiro
  
  // Outros
  creditoCrediarioVenda,           // Crediário venda
  creditoCrediarioSimulacao,       // Crediário simulação
  frotas,                          // Frotas
  pix,                             // PIX
}
```

### Alinhamentos e Estilos de Texto

```dart
// Alinhamentos
enum AlignModeEnum {
  center,  // Centralizado
  left,    // À esquerda
  right,   // À direita
}

// Estilos de fonte
enum TypeFaceEnum {
  normal,  // Normal
  bold,    // Negrito
  italic,  // Itálico
}
```

## Exemplo Completo

```dart
import 'dart:async';
import 'package:cielo_payments/cielo_payments.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class PagamentoPage extends StatefulWidget {
  @override
  _PagamentoPageState createState() => _PagamentoPageState();
}

class _PagamentoPageState extends State<PagamentoPage> {
  late StreamSubscription<Order> _subscription;
  String? _resultado;

  @override
  void initState() {
    super.initState();
    
    CieloPayments.deeplink.init(
      clientId: 'SEU_CLIENT_ID',
      accessToken: 'SEU_ACCESS_TOKEN',
      urlCallback: 'seu_app_scheme://response',
    );

    _subscription = CieloPayments.deeplink.onTransactionListener((order) {
      setState(() {
        if (order.status == 'PAID') {
          _resultado = 'Pagamento aprovado!\nID: ${order.id}';
        } else {
          _resultado = 'Erro: ${order.reason ?? "Desconhecido"}';
        }
      });
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<void> _processarPagamento(double valor) async {
    try {
      final order = OrderRequest(
        email: 'cliente@email.com',
        value: (valor * 100).toInt().toString(), // Converter para centavos
        paymentCode: PaymentCodeEnum.creditoAVista,
        reference: const Uuid().v4(),
        installments: 1,
        items: [
          OrderRequestItem(
            name: 'Compra',
            quantity: 1,
            unitPrice: (valor * 100).toInt(),
            sku: 'PROD001',
            unitOfMeasure: 'unidade',
          ),
        ],
      );

      await CieloPayments.deeplink.payment(order);
    } catch (e) {
      setState(() {
        _resultado = 'Erro ao processar: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pagamento Cielo')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => _processarPagamento(50.00),
              child: Text('Pagar R\$ 50,00'),
            ),
            SizedBox(height: 20),
            if (_resultado != null)
              Text(_resultado!, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
```

## Tratamento de Erros

```dart
try {
  await CieloPayments.deeplink.payment(order);
} catch (e) {
  if (e is AssertionError) {
    // Validação de parâmetros falhou
    print('Erro de validação: $e');
  } else {
    // Outro tipo de erro
    print('Erro ao processar pagamento: $e');
  }
}
```

## Observações Importantes

1. **Valores Monetários**: Sempre envie valores em centavos (ex: R$ 10,50 = 1050)
2. **Parcelas em Débito**: Sempre deve ser 1
3. **Reference**: Use identificadores únicos (UUID recomendado)
4. **LaunchMode**: Configure como `singleTop` no AndroidManifest
5. **Terminal Cielo**: Este plugin só funciona em terminais Cielo LIO

## Problemas Conhecidos

- A impressão de múltiplos itens é processada sequencialmente pelo terminal
- O plugin não funciona em emuladores, apenas em dispositivos Cielo LIO reais

## Contribuindo

Contribuições são bem-vindas! Sinta-se à vontade para abrir issues ou pull requests.

## Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo LICENSE para detalhes.

