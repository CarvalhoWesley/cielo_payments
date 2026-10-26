import 'package:cielo_payments/cielo_payments.dart';
import 'package:flutter/material.dart';

import 'core/app_log.dart';
import 'deeplink/deeplink_page.dart';
import 'deeplink/deeplink_store.dart';
import 'logs/logs_page.dart';
import 'mifare/mifare_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  CieloPayments.deeplink.init(
    clientId: 'pekop9oVJoD6yPFepY6pVQI0VDS1XxpHjwAooiQ0Av6BfuAXVU',
    accessToken: '19L5cEBLblVycvisy4Y8Q9xZuIFBezbKSfhXyGMtUdCXUd6Dfv',
    urlCallback: 'cielo_example_app://response',
  );

  // Retornos do Deeplink vão para o log central e para a aba Transações
  DeeplinkStore.listen();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cielo Payments',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF00AEEF),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  static const _titles = [
    'Deeplink',
    'Mifare',
    'Logs',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_index])),
      body: IndexedStack(
        index: _index,
        children: const [
          DeeplinkPage(),
          MifarePage(),
          LogsPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          const NavigationDestination(
              icon: Icon(Icons.open_in_new), label: 'Deeplink'),
          const NavigationDestination(
              icon: Icon(Icons.contactless), label: 'Mifare'),
          NavigationDestination(
            icon: ValueListenableBuilder(
              valueListenable: AppLog.entries,
              builder: (context, entries, _) => Badge(
                isLabelVisible: entries.any((e) => e.isError),
                child: const Icon(Icons.terminal),
              ),
            ),
            label: 'Logs',
          ),
        ],
      ),
    );
  }
}
