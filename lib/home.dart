import 'package:flutter/material.dart';
import 'core/widgets/custom_bottom_navigation.dart';
import 'accounts/accountsscreen.dart';
import 'contas_a_pagar/billscreensscreen.dart';
import 'transacoes/transactionsscreen.dart';
import 'drescreen.dart';
import 'investmentos/investmentsscreen.dart';
import 'reportsscreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.index});

  final int index;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const int _minIndex = 0;
  static const int _maxIndex = 5;
  
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = _validateIndex(widget.index);
  }

  int _validateIndex(int index) {
    if (index < _minIndex || index > _maxIndex) {
      return _minIndex;
    }
    return index;
  }

  static const List<Widget> _widgetOptions = <Widget>[
    AccountsScreen(),
    ContasAPagarScreen(),
    TransactionsScreen(),
    DREScreen(),
    InvestmentsScreen(),
    ReportsScreen(),
  ];

  void _onNavigationTap(int index) {
    if (index < _minIndex || index >= _widgetOptions.length) {
      return;
    }
    
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _selectedIndex,
        onTap: _onNavigationTap,
      ),
    );
  }
}