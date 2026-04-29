/// Enum representing the available expense categories.
///
/// Each category has a [label] for display and a factory constructor
/// [fromString] for safe deserialization from JSON.
enum Category {
  food('Food'),
  transport('Transport'),
  bills('Bills'),
  health('Health'),
  other('Other');

  final String label;

  const Category(this.label);

  /// Converts a raw string (e.g. from JSON) into a [Category].
  /// Returns [Category.other] if the string doesn't match any known value.
  static Category fromString(String value) {
    // .firstWhere with orElse — no need for `!` or try-catch
    return Category.values.firstWhere(
      (Category category) => category.name == value,
      orElse: () => Category.other,
    );
  }
}

/// Represents a single expense entry.
///
/// All fields use explicit types and null safety.
/// The class is immutable — create a new instance to "update" an expense.
class Expense {
  final int id;
  final String title;
  final double amount;
  final Category category;
  final DateTime date;

  /// Creates an [Expense] with all required fields.
  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
  });

  /// Deserializes an [Expense] from a JSON [Map].
  ///
  /// Uses null-aware operators and safe casts to handle malformed data.
  /// If a field is missing or the wrong type, sensible defaults are used.
  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['title'] as String?) ?? 'Untitled',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      category: Category.fromString((json['category'] as String?) ?? 'other'),
      date:
          DateTime.tryParse((json['date'] as String?) ?? '') ?? DateTime.now(),
    );
  }

  /// Serializes this [Expense] to a JSON-compatible [Map].
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'amount': amount,
      'category': category.name,
      'date': date.toIso8601String(),
    };
  }

  /// A human-readable representation of the expense for the CLI table.
  @override
  String toString() {
    String formattedDate =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    String formattedAmount = amount.toStringAsFixed(2);
    String displayTitle =
        title.length > 20 ? '${title.substring(0, 17)}...' : title;
    return '| ${id.toString().padRight(4)} '
        '| ${displayTitle.padRight(20)} '
        '| \$${formattedAmount.padLeft(10)} '
        '| ${category.label.padRight(12)} '
        '| $formattedDate |';
  }
}
