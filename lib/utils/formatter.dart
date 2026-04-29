import '../models/expense.dart';

/// Utility class for formatting CLI output.
/// Contains static methods only — no instance state needed.
class Formatter {
  Formatter._();

  static const int _tableWidth = 76;

  static String currency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  static String percentage(double value) {
    return '${value.toStringAsFixed(1)}%';
  }

  static String date(DateTime dateTime) {
    String year = dateTime.year.toString();
    String month = dateTime.month.toString().padLeft(2, '0');
    String day = dateTime.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  static String monthName(int month) {
    const List<String> months = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    if (month < 1 || month > 12) return 'Unknown';
    return months[month - 1];
  }

  static void printDivider() {
    print('  ${'─' * _tableWidth}');
  }

  static void printHeader(String title) {
    print('');
    printDivider();
    print('  │ ${title.padRight(_tableWidth - 4)} │');
    printDivider();
  }

  static void printTableHeader() {
    print('  | ${'ID'.padRight(4)} '
        '| ${'Title'.padRight(20)} '
        '| ${'Amount'.padRight(11)} '
        '| ${'Category'.padRight(12)} '
        '| Date       |');
    printDivider();
  }

  static void printExpenseTable(List<Expense> expenses, String title) {
    printHeader(title);
    printTableHeader();
    if (expenses.isEmpty) {
      print('  |${' No expenses found.'.padRight(_tableWidth - 2)}|');
    } else {
      expenses
          .map((Expense expense) => '  ${expense.toString()}')
          .forEach(print);
    }
    printDivider();
    print('');
  }

  static void printSummary({
    required String period,
    required double totalSpent,
    required Map<Category, Map<String, double>> breakdown,
    required Category? highestCategory,
  }) {
    printHeader('📊 Summary: $period');
    print(
        '  │ Total Spent: ${currency(totalSpent).padRight(_tableWidth - 18)} │');
    printDivider();
    if (breakdown.isEmpty) {
      print('  │${'  No data available.'.padRight(_tableWidth - 2)}│');
    } else {
      breakdown.forEach((Category cat, Map<String, double> data) {
        double total = data['total'] ?? 0.0;
        double pct = data['percentage'] ?? 0.0;
        int barLen = (pct / 100 * 20).round();
        String bar = '█' * barLen + '░' * (20 - barLen);
        print('  │ ${cat.label.padRight(14)} '
            '| ${currency(total).padRight(12)} '
            '| ${percentage(pct).padRight(12)} '
            '| $bar │');
      });
    }
    printDivider();
    if (highestCategory != null) {
      print(
          '  │ 🏆 Highest: ${highestCategory.label.padRight(_tableWidth - 18)} │');
      printDivider();
    }
    print('');
  }

  static void printSuccess(String message) {
    print('  ✅ $message\n');
  }

  static void printError(String message) {
    print('  ❌ $message\n');
  }
}
