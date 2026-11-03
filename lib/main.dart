import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/transaction_screen.dart';
import 'screens/savings_screen.dart';
import 'widgets/transaction_dialog.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SmartPocketApp());
}

class SmartPocketApp extends StatelessWidget {
  const SmartPocketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartPocket',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A8A),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final GlobalKey<HomeScreenState> _homeKey = GlobalKey<HomeScreenState>();
  final GlobalKey<TransactionScreenState> _transactionKey = GlobalKey<TransactionScreenState>();
  final GlobalKey<SavingsScreenState> _savingsKey = GlobalKey<SavingsScreenState>();

  void _refreshAll() {
    _homeKey.currentState?.loadData();
    _transactionKey.currentState?.loadTransactions();
    _savingsKey.currentState?.loadGoals();
  }

  void _openQuickAddDialog() {
    showDialog(
      context: context,
      builder: (_) => TransactionDialog(
        onSaved: _refreshAll,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        key: _homeKey,
        onNavigateToTransactions: () {
          setState(() => _currentIndex = 1);
        },
      ),
      TransactionScreen(
        key: _transactionKey,
        onDataChanged: _refreshAll,
      ),
      SavingsScreen(
        key: _savingsKey,
        onDataChanged: _refreshAll,
      ),
    ];

    final titles = [
      'SmartPocket',
      'Riwayat Transaksi',
      'Target Tabungan',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          titles[_currentIndex],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 28),
            tooltip: 'Catat Transaksi Cepat',
            onPressed: _openQuickAddDialog,
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
          if (index == 0) _homeKey.currentState?.loadData();
          if (index == 1) _transactionKey.currentState?.loadTransactions();
          if (index == 2) _savingsKey.currentState?.loadGoals();
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Transaksi',
          ),
          NavigationDestination(
            icon: Icon(Icons.savings_outlined),
            selectedIcon: Icon(Icons.savings),
            label: 'Tabungan',
          ),
        ],
      ),
    );
  }
}
