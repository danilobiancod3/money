import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class CustomBottomNavigation extends StatelessWidget {
  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  void _handleTap(int index) {
    if (index >= 0 && index < _items.length) {
      onTap(index);
    }
  }

  static final List<SalomonBottomBarItem> _items = [
    SalomonBottomBarItem(
      icon: const Icon(Icons.account_balance_wallet),
      title: const Text('Contas'),
      selectedColor: Colors.blue,
    ),
    SalomonBottomBarItem(
      icon: const Icon(Icons.receipt_long),
      title: const Text('Pagar'),
      selectedColor: Colors.orange,
    ),
    SalomonBottomBarItem(
      icon: const Icon(Icons.compare_arrows),
      title: const Text('Transações'),
      selectedColor: Colors.purple,
    ),
    SalomonBottomBarItem(
      icon: const Icon(Icons.analytics),
      title: const Text('DRE'),
      selectedColor: Colors.teal,
    ),
    SalomonBottomBarItem(
      icon: const Icon(Icons.trending_up),
      title: const Text('Investimentos'),
      selectedColor: Colors.green,
    ),
    SalomonBottomBarItem(
      icon: const Icon(Icons.assessment),
      title: const Text('Relatórios'),
      selectedColor: Colors.red,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final validatedIndex = currentIndex.clamp(0, _items.length - 1);
    
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SalomonBottomBar(
        currentIndex: validatedIndex,
        onTap: _handleTap,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey[600],
        itemShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        itemPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        items: _items,
      ),
    );
  }
}
