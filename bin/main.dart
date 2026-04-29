import 'dart:io';

import '../lib/models/expense.dart';
import '../lib/services/expense_service.dart';
import '../lib/utils/formatter.dart';

/// Entry point for the CLI Expense Tracker.
///
/// Demonstrates:
/// - Interactive CLI with stdin/stdout
/// - Input validation with re-prompting at the exact failing step
/// - Proper null safety (no `!` operator abuse)
/// - Exception handling for invalid user input
void main() {
  print('');
  print('  ╔══════════════════════════════════════════╗');
  print('  ║       💰 CLI Expense Tracker v1.0        ║');
  print('  ║       Built with Pure Dart                ║');
  print('  ╚══════════════════════════════════════════╝');
  print('');

  ExpenseService expenseService = ExpenseService();

  bool running = true;

  while (running) {
    _printMenu();
    String? input = stdin.readLineSync();
    String choice = input?.trim() ?? '';

    switch (choice) {
      case '1':
        _addExpense(expenseService);
        break;
      case '2':
        _viewAll(expenseService);
        break;
      case '3':
        _viewByCategory(expenseService);
        break;
      case '4':
        _monthlySummary(expenseService);
        break;
      case '5':
        running = false;
        print('');
        print('  👋 Goodbye! Your expenses have been saved.');
        print('');
        break;
      default:
        Formatter.printError('Invalid choice. Please enter 1-5.');
    }
  }
}

/// Prints the main menu options.
void _printMenu() {
  print('  ┌────────────────────────────────┐');
  print('  │         📋 Main Menu           │');
  print('  ├────────────────────────────────┤');
  print('  │  1. ➕ Add Expense             │');
  print('  │  2. 📄 View All Expenses       │');
  print('  │  3. 🏷️  View by Category        │');
  print('  │  4. 📊 Monthly Summary         │');
  print('  │  5. 🚪 Exit                    │');
  print('  └────────────────────────────────┘');
  stdout.write('  Enter your choice (1-5): ');
}

/// Prints the category list for selection.
void _printCategoryList() {
  print('  Categories:');
  for (int i = 0; i < Category.values.length; i++) {
    print('    ${i + 1}. ${Category.values[i].label}');
  }
}

/// Handles adding a new expense with full input validation.
/// Each step re-prompts on invalid input instead of returning to the menu.
/// Type 'q' at any step to cancel and go back to the menu.
void _addExpense(ExpenseService service) {
  Formatter.printHeader('➕ Add New Expense');
  print('  (Type "q" at any prompt to cancel)\n');

  // --- Title (loops until valid or cancelled) ---
  String title;
  while (true) {
    String input = _promptString('  Enter title: ');
    if (_isCancelled(input)) return;
    if (input.isEmpty) {
      Formatter.printError('Title cannot be empty. Try again.');
      continue;
    }
    title = input;
    break;
  }

  // --- Amount (loops until valid or cancelled) ---
  double amount;
  while (true) {
    String input = _promptString('  Enter amount (\$): ');
    if (_isCancelled(input)) return;
    double? parsed = double.tryParse(input);
    if (parsed == null || parsed <= 0) {
      Formatter.printError('Amount must be a positive number. Try again.');
      continue;
    }
    amount = parsed;
    break;
  }

  // --- Category (loops until valid or cancelled) ---
  Category category;
  _printCategoryList();
  while (true) {
    String input =
        _promptString('  Choose category (1-${Category.values.length}): ');
    if (_isCancelled(input)) return;
    int? index = int.tryParse(input);
    if (index == null || index < 1 || index > Category.values.length) {
      Formatter.printError(
          'Invalid selection. Enter a number 1-${Category.values.length}.');
      continue;
    }
    category = Category.values[index - 1];
    break;
  }

  // --- Date (loops until valid or cancelled) ---
  DateTime date;
  while (true) {
    String input =
        _promptString('  Enter date (YYYY-MM-DD) or press Enter for today: ');
    if (_isCancelled(input)) return;
    if (input.isEmpty) {
      date = DateTime.now();
      break;
    }
    DateTime? parsed = DateTime.tryParse(input);
    if (parsed == null) {
      Formatter.printError('Invalid date format. Use YYYY-MM-DD. Try again.');
      continue;
    }
    date = parsed;
    break;
  }

  // --- Save ---
  Expense newExpense = service.addExpense(
    title: title,
    amount: amount,
    category: category,
    date: date,
  );

  Formatter.printSuccess(
    'Added: "${newExpense.title}" — ${Formatter.currency(newExpense.amount)} '
    '[${newExpense.category.label}] on ${Formatter.date(newExpense.date)}',
  );
}

/// Displays all expenses in a formatted table.
void _viewAll(ExpenseService service) {
  List<Expense> expenses = service.allExpenses;
  Formatter.printExpenseTable(
      expenses, '📄 All Expenses (${expenses.length} total)');

  if (expenses.isNotEmpty) {
    double total = service.getTotalSpent();
    print('  Total spent: ${Formatter.currency(total)}\n');
  }
}

/// Displays expenses filtered by a user-selected category.
/// Re-prompts on invalid category selection instead of returning to menu.
void _viewByCategory(ExpenseService service) {
  print('');
  print('  Select a category to filter:');
  _printCategoryList();

  while (true) {
    String input =
        _promptString('  Choose category (1-${Category.values.length}): ');
    if (_isCancelled(input)) return;
    int? index = int.tryParse(input);
    if (index == null || index < 1 || index > Category.values.length) {
      Formatter.printError(
          'Invalid selection. Enter a number 1-${Category.values.length}.');
      continue;
    }

    Category category = Category.values[index - 1];

    // .where() is used inside getExpensesByCategory
    List<Expense> filtered = service.getExpensesByCategory(category);
    Formatter.printExpenseTable(
      filtered,
      '🏷️ Expenses: ${category.label} (${filtered.length} found)',
    );

    if (filtered.isNotEmpty) {
      double categoryTotal = service.getTotalForExpenses(filtered);
      print('  Category total: ${Formatter.currency(categoryTotal)}\n');
    }
    break;
  }
}

/// Displays a monthly summary with category breakdown.
/// Re-prompts on invalid year/month instead of returning to menu.
void _monthlySummary(ExpenseService service) {
  print('');

  // --- Year (loops until valid or cancelled) ---
  int year;
  while (true) {
    String input = _promptString('  Enter year (e.g. 2026): ');
    if (_isCancelled(input)) return;
    int? parsed = int.tryParse(input);
    if (parsed == null || parsed < 2000 || parsed > 2100) {
      Formatter.printError('Invalid year. Enter a year between 2000-2100.');
      continue;
    }
    year = parsed;
    break;
  }

  // --- Month (loops until valid or cancelled) ---
  int month;
  while (true) {
    String input = _promptString('  Enter month (1-12): ');
    if (_isCancelled(input)) return;
    int? parsed = int.tryParse(input);
    if (parsed == null || parsed < 1 || parsed > 12) {
      Formatter.printError('Invalid month. Enter a number 1-12.');
      continue;
    }
    month = parsed;
    break;
  }

  // Fetch monthly expenses using .where() inside getExpensesByMonth
  List<Expense> monthlyExpenses = service.getExpensesByMonth(year, month);

  if (monthlyExpenses.isEmpty) {
    Formatter.printError(
        'No expenses found for ${Formatter.monthName(month)} $year.');
    return;
  }

  // Calculate total for the month using .fold()
  double monthlyTotal = monthlyExpenses.fold<double>(
    0.0,
    (double sum, Expense expense) => sum + expense.amount,
  );

  // Build category breakdown for this month using .where() and .fold()
  Map<Category, Map<String, double>> breakdown =
      <Category, Map<String, double>>{};

  for (Category category in Category.values) {
    // .where() filters expenses for this specific category
    List<Expense> catExpenses =
        monthlyExpenses.where((Expense e) => e.category == category).toList();

    // .fold() sums up amounts for this category
    double catTotal = catExpenses.fold<double>(
      0.0,
      (double sum, Expense e) => sum + e.amount,
    );

    if (catTotal > 0) {
      double pct = (catTotal / monthlyTotal) * 100;
      breakdown[category] = <String, double>{
        'total': catTotal,
        'percentage': pct,
      };
    }
  }

  // Find highest category using .fold() on map entries
  Category? highest;
  if (breakdown.isNotEmpty) {
    MapEntry<Category, Map<String, double>> maxEntry =
        breakdown.entries.fold<MapEntry<Category, Map<String, double>>>(
      breakdown.entries.first,
      (MapEntry<Category, Map<String, double>> current,
              MapEntry<Category, Map<String, double>> entry) =>
          (entry.value['total'] ?? 0) > (current.value['total'] ?? 0)
              ? entry
              : current,
    );
    highest = maxEntry.key;
  }

  String period = '${Formatter.monthName(month)} $year';
  Formatter.printSummary(
    period: period,
    totalSpent: monthlyTotal,
    breakdown: breakdown,
    highestCategory: highest,
  );

  // Also show individual expenses for the month
  Formatter.printExpenseTable(
    monthlyExpenses,
    '📋 Expenses for $period (${monthlyExpenses.length} items)',
  );
}

// ─── Input Helper Functions ─────────────────────────────────────────

/// Prompts the user for a string input. Returns empty string if null.
String _promptString(String prompt) {
  stdout.write(prompt);
  String? input = stdin.readLineSync();
  return input?.trim() ?? '';
}

/// Checks if the user typed 'q' or 'Q' to cancel the current operation.
bool _isCancelled(String input) {
  if (input.toLowerCase() == 'q') {
    print('  ↩️  Cancelled. Returning to menu.\n');
    return true;
  }
  return false;
}
