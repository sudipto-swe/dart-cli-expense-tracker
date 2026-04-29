import '../models/expense.dart';
import 'storage_service.dart';

/// Business logic layer for managing expenses.
///
/// Demonstrates:
/// - .where() — filtering lists
/// - .map() — transforming lists
/// - .fold() — reducing lists to a single value
/// - Separation of concerns from storage and presentation
class ExpenseService {
  final StorageService _storageService;
  List<Expense> _expenses;

  /// Creates an [ExpenseService] backed by the given [StorageService].
  /// Loads existing expenses from disk immediately.
  ExpenseService({StorageService? storageService})
      : _storageService = storageService ?? const StorageService(),
        _expenses = <Expense>[] {
    _expenses = _storageService.loadExpenses();
  }

  /// Returns an unmodifiable view of all expenses.
  List<Expense> get allExpenses => List<Expense>.unmodifiable(_expenses);

  /// Generates the next unique ID based on existing expenses.
  ///
  /// Uses .fold() to find the maximum existing ID, then adds 1.
  int _nextId() {
    if (_expenses.isEmpty) {
      return 1;
    }

    // .fold() — reduces the list to a single value (the max ID)
    // Starting from 0, compare each expense's id to find the maximum
    int maxId = _expenses.fold<int>(
      0,
      (int currentMax, Expense expense) =>
          expense.id > currentMax ? expense.id : currentMax,
    );

    return maxId + 1;
  }

  /// Adds a new expense and persists to disk.
  Expense addExpense({
    required String title,
    required double amount,
    required Category category,
    DateTime? date,
  }) {
    Expense newExpense = Expense(
      id: _nextId(),
      title: title,
      amount: amount,
      category: category,
      date: date ?? DateTime.now(),
    );

    _expenses.add(newExpense);
    _storageService.saveExpenses(_expenses);

    return newExpense;
  }

  /// Returns expenses filtered by the given [category].
  ///
  /// Uses .where() to filter — returns only expenses matching the category.
  List<Expense> getExpensesByCategory(Category category) {
    // .where() — returns a lazy Iterable of elements matching the predicate
    List<Expense> filtered = _expenses
        .where((Expense expense) => expense.category == category)
        .toList();

    return filtered;
  }

  /// Returns expenses for the given [year] and [month].
  ///
  /// Uses .where() with a compound condition on the date.
  List<Expense> getExpensesByMonth(int year, int month) {
    List<Expense> filtered = _expenses
        .where((Expense expense) =>
            expense.date.year == year && expense.date.month == month)
        .toList();

    return filtered;
  }

  /// Calculates the total amount across all expenses.
  ///
  /// Uses .fold() — starts at 0.0 and accumulates each expense's amount.
  double getTotalSpent() {
    double total = _expenses.fold<double>(
      0.0,
      (double sum, Expense expense) => sum + expense.amount,
    );

    return total;
  }

  /// Calculates total spent for a specific list of expenses.
  ///
  /// Uses .fold() — same pattern, but on a filtered subset.
  double getTotalForExpenses(List<Expense> expenses) {
    double total = expenses.fold<double>(
      0.0,
      (double sum, Expense expense) => sum + expense.amount,
    );

    return total;
  }

  /// Returns a breakdown of spending per category as a Map.
  ///
  /// Demonstrates chaining .where(), .fold(), and .map() together.
  /// Each entry: { Category: { total: double, percentage: double } }
  Map<Category, Map<String, double>> getCategoryBreakdown() {
    double totalSpent = getTotalSpent();

    if (totalSpent == 0) {
      return <Category, Map<String, double>>{};
    }

    Map<Category, Map<String, double>> breakdown =
        <Category, Map<String, double>>{};

    // Iterate over each category in the enum
    for (Category category in Category.values) {
      // .where() — filter expenses for this category
      List<Expense> categoryExpenses = _expenses
          .where((Expense expense) => expense.category == category)
          .toList();

      // .fold() — sum up amounts for this category
      double categoryTotal = categoryExpenses.fold<double>(
        0.0,
        (double sum, Expense expense) => sum + expense.amount,
      );

      if (categoryTotal > 0) {
        double percentage = (categoryTotal / totalSpent) * 100;
        breakdown[category] = <String, double>{
          'total': categoryTotal,
          'percentage': percentage,
        };
      }
    }

    return breakdown;
  }

  /// Returns the category with the highest total spending.
  ///
  /// Uses .map() to transform categories into (category, total) pairs,
  /// then .fold() to find the maximum.
  /// Returns null if there are no expenses.
  Category? getHighestSpendingCategory() {
    if (_expenses.isEmpty) {
      return null;
    }

    Map<Category, Map<String, double>> breakdown = getCategoryBreakdown();

    if (breakdown.isEmpty) {
      return null;
    }

    // .entries gives us MapEntry<Category, Map<String, double>> items
    // .fold() finds the entry with the highest 'total'
    MapEntry<Category, Map<String, double>> highest =
        breakdown.entries.fold<MapEntry<Category, Map<String, double>>>(
      breakdown.entries.first,
      (MapEntry<Category, Map<String, double>> current,
              MapEntry<Category, Map<String, double>> entry) =>
          (entry.value['total'] ?? 0) > (current.value['total'] ?? 0)
              ? entry
              : current,
    );

    return highest.key;
  }

  /// Returns the titles of all expenses, demonstrating .map() on its own.
  ///
  /// .map() transforms List<Expense> → Iterable<String> (lazy),
  /// then .toList() materializes it.
  List<String> getAllTitles() {
    List<String> titles =
        _expenses.map((Expense expense) => expense.title).toList();

    return titles;
  }
}
