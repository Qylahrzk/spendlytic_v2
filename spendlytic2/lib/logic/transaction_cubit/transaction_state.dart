import '../../data/models/transaction_model.dart';

abstract class TransactionState {}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  final List<TransactionModel> transactions;
  final double totalExpenses;
  final double totalBudget; // ✅ NEW FIELD

  TransactionLoaded({
    required this.transactions,
    required this.totalExpenses,
    required this.totalBudget,
  });
}

class TransactionError extends TransactionState {
  final String message;
  TransactionError(this.message);
}
