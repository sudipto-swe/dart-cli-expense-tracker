import 'dart:convert';
import 'dart:io';

import '../models/expense.dart';

/// Handles reading and writing [Expense] data to a JSON file.
///
/// Demonstrates:
/// - File I/O with dart:io
/// - JSON encoding/decoding with dart:convert
/// - Exception handling for missing files and corrupt data
/// - Functional collection methods: .map()
class StorageService {
  final String filePath;

  /// Creates a [StorageService] that reads/writes to [filePath].
  const StorageService({this.filePath = 'expenses.json'});

  /// Loads all expenses from the JSON file.
  ///
  /// - If the file doesn't exist, returns an empty list (and prints a notice).
  /// - If the file contains invalid JSON, returns an empty list with a warning.
  /// - Uses `.map()` to transform each JSON object into an [Expense].
  List<Expense> loadExpenses() {
    File file = File(filePath);

    if (!file.existsSync()) {
      print('  📂 No existing data file found. Starting fresh!\n');
      return <Expense>[];
    }

    try {
      String contents = file.readAsStringSync();

      // Handle empty file gracefully
      if (contents.trim().isEmpty) {
        return <Expense>[];
      }

      // Decode the JSON string into a List<dynamic>
      List<dynamic> jsonList = jsonDecode(contents) as List<dynamic>;

      // .map() — transforms each JSON map into an Expense object
      // .toList() — converts the lazy Iterable into a concrete List
      List<Expense> expenses = jsonList
          .map((dynamic item) => Expense.fromJson(item as Map<String, dynamic>))
          .toList();

      return expenses;
    } on FormatException catch (e) {
      print('  ⚠️  Warning: Corrupt data file. Starting fresh.');
      print('  Details: ${e.message}\n');
      return <Expense>[];
    } on FileSystemException catch (e) {
      print('  ⚠️  Warning: Could not read file. Starting fresh.');
      print('  Details: ${e.message}\n');
      return <Expense>[];
    }
  }

  /// Saves the given list of expenses to the JSON file.
  ///
  /// Uses `.map()` to convert each [Expense] to its JSON representation,
  /// then encodes with indentation for readability.
  void saveExpenses(List<Expense> expenses) {
    File file = File(filePath);

    // .map() — converts each Expense to a Map<String, dynamic>
    List<Map<String, dynamic>> jsonList =
        expenses.map((Expense expense) => expense.toJson()).toList();

    // JsonEncoder with indent for pretty-printed output
    JsonEncoder encoder = JsonEncoder.withIndent('  ');
    String jsonString = encoder.convert(jsonList);

    try {
      file.writeAsStringSync(jsonString);
    } on FileSystemException catch (e) {
      print('  ❌ Error: Could not save data.');
      print('  Details: ${e.message}\n');
    }
  }
}
