import 'package:flutter/material.dart';
import '../../../transactions/presentation/screens/transaction_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() {
    return _AppShellState();
  }
}

class _AppShellState extends State<AppShell> {
  int currentIndex = 0;

  final screens = [
    const TransactionScreen(),
    const Center(child: Text('Statistics')),
    const Center(child: Text('AI Chat')),
    const Center(child: Text('Settings')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],

      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,

          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  currentIndex = 0;
                });
              },
              icon: const Icon(Icons.home),
            ),

            IconButton(
              onPressed: () {
                setState(() {
                  currentIndex = 1;
                });
              },
              icon: const Icon(Icons.bar_chart),
            ),

            const SizedBox(width: 40),

            IconButton(
              onPressed: () {
                setState(() {
                  currentIndex = 2;
                });
              },
              icon: const Icon(Icons.smart_toy),
            ),

            IconButton(
              onPressed: () {
                setState(() {
                  currentIndex = 3;
                });
              },
              icon: const Icon(Icons.settings),
            ),
          ],
        ),
      ),
    );
  }
}
