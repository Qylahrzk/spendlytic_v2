import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../data/models/transaction_model.dart';
import 'transaction_state.dart';

class TransactionCubit extends Cubit<TransactionState> {
  final TransactionRepository _repo;

  TransactionCubit(this._repo) : super(TransactionInitial());

  Future<void> loadTransactions() async {
    emit(TransactionLoading());
    try {
      // Fetch both concurrently
      final results = await Future.wait([
        _repo.getTransactions(),
        _repo.getTotalBudget(),
      ]);

      final transactions = results[0] as List<TransactionModel>;
      final budget = results[1] as double;

      final totalExpenses = transactions.fold(
        0.0,
        (sum, item) => sum + item.amount,
      );

      emit(
        TransactionLoaded(
          transactions: transactions,
          totalExpenses: totalExpenses,
          totalBudget: budget,
        ),
      );
    } catch (e) {
      emit(TransactionError("Failed to fetch data: $e"));
    }
  }

  Future<void> addTransaction({
    required String title,
    required double amount,
    required String category,
  }) async {
    try {
      await _repo.addTransaction(
        title: title,
        amount: amount,
        category: category,
      );
      // ✅ REFRESH IMMEDIATELY to show the new item
      await loadTransactions();
    } catch (e) {
      emit(TransactionError("Failed to add: $e"));
    }
  }
}
