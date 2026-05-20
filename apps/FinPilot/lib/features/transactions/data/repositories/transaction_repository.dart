import '../datasources/transaction_local_datasource.dart';
import '../../domain/entities/transaction_entity.dart';

class TransactionRepository {
  final TransactionLocalDataSource localDataSource;

  TransactionRepository(this.localDataSource);

  Future<List<TransactionEntity>> getTransactions() async {
    final cachedTransactions = await localDataSource.getCachedTransactions();

    if (cachedTransactions.isNotEmpty) {
      _refreshTransactionsInBackground();

      return cachedTransactions;
    }

    final remoteTransactions = await _fetchRemoteTransactions();

    await localDataSource.cacheTransactions(remoteTransactions);

    return remoteTransactions;
  }

  Future<void> _refreshTransactionsInBackground() async {
    final remoteTransactions = await _fetchRemoteTransactions();

    await localDataSource.cacheTransactions(remoteTransactions);
  }

  Future<List<TransactionEntity>> _fetchRemoteTransactions() async {
    await Future.delayed(const Duration(seconds: 1));

    return [
      TransactionEntity(
        id: '1',
        amount: 249,
        currencyCode: CurrencyCode.inr,
        merchant: 'Zepto',
        timestamp: DateTime.now(),
        category: 'Food',
        type: TransactionType.debit,
        source: 'HDFC Savings',
        status: TransactionStatus.completed,
        isRecurring: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),

      TransactionEntity(
        id: '2',
        amount: 799,
        currencyCode: CurrencyCode.inr,
        merchant: 'Amazon',
        timestamp: DateTime.now(),
        category: 'Shopping',
        type: TransactionType.debit,
        source: 'ICICI Credit Card',
        status: TransactionStatus.completed,
        isRecurring: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),

      TransactionEntity(
        id: '3',
        amount: 45000,
        currencyCode: CurrencyCode.inr,
        merchant: 'Salary',
        timestamp: DateTime.now(),
        category: 'Income',
        type: TransactionType.credit,
        source: 'HDFC Salary Account',
        status: TransactionStatus.completed,
        isRecurring: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }
}
