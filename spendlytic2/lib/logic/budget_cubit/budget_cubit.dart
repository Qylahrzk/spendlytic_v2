import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../data/models/budget_model.dart'; // Ensure model is imported
import 'budget_state.dart';

class BudgetCubit extends Cubit<BudgetState> {
  final TransactionRepository _repo;

  BudgetCubit(this._repo) : super(BudgetInitial());

  Future<void> loadBudgets() async {
    emit(BudgetLoading());
    try {
      final budgets = await _repo.getBudgets();
      emit(BudgetLoaded(budgets));
    } catch (e) {
      emit(BudgetError("Failed to load budgets: $e"));
    }
  }

  Future<void> setBudget(String category, double amount) async {
    // 1. Get current list (if loaded)
    List<BudgetModel> currentList = [];
    if (state is BudgetLoaded) {
      currentList = List.from((state as BudgetLoaded).budgets);
    }

    // 2. Optimistic Update (Update UI instantly)
    // Remove existing budget for this category
    currentList.removeWhere((b) => b.category == category);

    // Add the new one (Simulate a model)
    final newBudget = BudgetModel(
      id: 0, // Temp ID, doesn't matter for UI
      userId: '',
      category: category,
      amount: amount,
      createdAt: DateTime.now(),
    );
    currentList.add(newBudget);

    // Emit the new state immediately!
    emit(BudgetLoaded(currentList));

    try {
      // 3. Save to DB in background
      await _repo.setBudget(category, amount);
      // We don't need to reload here because we already updated the UI!
    } catch (e) {
      // 4. Rollback on failure (Optional, but good practice)
      emit(BudgetError("Failed to save. Please refresh."));
      loadBudgets();
    }
  }
}
