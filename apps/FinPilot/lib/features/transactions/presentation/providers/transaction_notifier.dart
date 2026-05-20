import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/transaction_repository.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../data/datasources/transaction_local_datasource.dart';


final transactionLocalDataSourceProvider = Provider<TransactionLocalDataSource>(
  (ref) {
    return TransactionLocalDataSource();
  },
);
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final localDataSource = ref.read(transactionLocalDataSourceProvider);

  return TransactionRepository(localDataSource);
});

final transactionNotifierProvider =
    AsyncNotifierProvider<TransactionNotifier, List<TransactionEntity>>(
      TransactionNotifier.new,
    );

class TransactionNotifier extends AsyncNotifier<List<TransactionEntity>> {
  @override
  Future<List<TransactionEntity>> build() async {
    return ref.watch(transactionRepositoryProvider).getTransactions();
  }

  Future<void> refreshTransactions() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      return ref.read(transactionRepositoryProvider).getTransactions();
    });
  }
}
//we are using AsyncNotifier because we are dealing with asynchronous data fetching and we want to handle loading and error states more effectively.
//AsyncNotifier provides built-in support for managing asynchronous state, including loading and error states, which simplifies our code and improves the user experience when fetching transactions.
//import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../../data/repositories/transaction_repository.dart';
// import '../../domain/entities/transaction_entity.dart';

// final transactionRepositoryProvider =
//     Provider<TransactionRepository>((ref) {

//   return TransactionRepository();

// });

// final transactionNotifierProvider =
//     StateNotifierProvider<
//         TransactionNotifier,
//         AsyncValue<List<TransactionEntity>>>((ref) {

//   final repository =
//       ref.read(transactionRepositoryProvider);

//   return TransactionNotifier(repository);

// });

// class TransactionNotifier
//     extends StateNotifier<
//         AsyncValue<List<TransactionEntity>>> {

//   final TransactionRepository repository;

//   TransactionNotifier(this.repository)
//       : super(const AsyncLoading());

//   Future<void> fetchTransactions() async {

//     try {

//       final transactions =
//           await repository.getTransactions();

//       state = AsyncData(transactions);

//     } catch (e, stackTrace) {

//       state = AsyncError(e, stackTrace);

//     }
//   }
// }

//this is the old way of doing it. now we are using the reactive way with AsyncNotifier which is more concise and easier to manage asynchronous state.