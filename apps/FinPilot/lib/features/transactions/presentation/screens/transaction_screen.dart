import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/transaction_card.dart';

import '../providers/transaction_notifier.dart';

class TransactionScreen extends ConsumerWidget {
  const TransactionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionState = ref.watch(transactionNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),

      body: transactionState.when(
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },

        error: (error, stackTrace) {
          return Center(child: Text('Error: $error'));
        },

        data: (transactions) {
          return ListView.builder(
            itemCount: transactions.length,

            itemBuilder: (context, index) {
              final transaction = transactions[index];

              return TransactionCard(transaction: transaction);
            },
          );
        },
      ),
    );
  }
}
