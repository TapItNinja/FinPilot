import 'package:flutter/material.dart';

import '../../domain/entities/transaction_entity.dart';

class TransactionCard extends StatelessWidget {
  final TransactionEntity transaction;

  const TransactionCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.type == TransactionType.credit;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

      child: ListTile(
        leading: CircleAvatar(child: Text(transaction.merchant[0])),

        title: Text(transaction.merchant),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(transaction.category),

            Text(transaction.source, style: const TextStyle(fontSize: 12)),
          ],
        ),

        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          crossAxisAlignment: CrossAxisAlignment.end,

          children: [
            Text(
              '${isCredit ? '+' : '-'} ₹${transaction.amount}',
              style: TextStyle(
                color: isCredit ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(transaction.status.name, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
