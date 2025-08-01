// File: lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'accounts/accountsscreen.dart';
import 'contas_a_pagar/billscreensscreen.dart';
import 'transacoes/transactionsscreen.dart';
import 'drescreen.dart';
import 'investmentos/investmentsscreen.dart';
import 'reportsscreen.dart';

class HomeScreen extends StatefulWidget {
  final int index;

  const HomeScreen({super.key, required this.index});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.index;
  }

  static final List<Widget> _widgetOptions = <Widget>[
    const AccountsScreen(),
    const ContasAPagarScreen(),
    const TransactionsScreen(),
    const DREScreen(),
    const InvestmentsScreen(),
    const ReportsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey[700],
        itemShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        itemPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), // Adjusted padding
        items: [
          SalomonBottomBarItem(
            icon: const Icon(Icons.account_balance),
            title: const Text('Contas'), // Shorter label
            selectedColor: Colors.blue,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.receipt_long),
            title: const Text('Pagar'), // Shorter label
            selectedColor: Colors.orange,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.compare_arrows),
            title: const Text('Trans.'), // Shorter label
            selectedColor: Colors.purple,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.analytics),
            title: const Text('DRE'),
            selectedColor: Colors.teal,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.area_chart),
            title: const Text('Invest.'), // Shorter label
            selectedColor: Colors.green,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.description),
            title: const Text('Relat.'), // Shorter label
            selectedColor: Colors.red,
          ),
        ],
      ),
    );
  }
}