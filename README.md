<div align="center">

# 💰 CLI Expense Tracker

**A feature-rich command-line expense tracker built with pure Dart — no Flutter, no external packages.**

[![Dart CI](https://github.com/sudiptoswe/dart-cli-expense-tracker/actions/workflows/dart.yml/badge.svg)](https://github.com/sudiptoswe/dart-cli-expense-tracker/actions/workflows/dart.yml)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green)
![Platform](https://img.shields.io/badge/Platform-CLI-orange)

[Features](#-features) •
[Quick Start](#-quick-start) •
[Architecture](#-architecture) •
[Concepts Covered](#-dart-concepts-covered) •
[Contributing](#-contributing)

</div>

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| ➕ **Add Expense** | Title, amount, category, and date with full input validation |
| 📄 **View All** | Formatted ASCII table of every expense |
| 🏷️ **Filter by Category** | View expenses for Food, Transport, Bills, Health, or Other |
| 📊 **Monthly Summary** | Total spent, category breakdown with visual bar chart, highest spending |
| 💾 **Persistent Storage** | Auto-saves to `expenses.json` — loads on startup |
| 🛡️ **Error Handling** | Invalid input re-prompts at the same step (never kicks you back to menu) |
| ↩️ **Cancel Anytime** | Type `q` at any prompt to cancel and return to menu |

## 🚀 Quick Start

### Prerequisites

- [Dart SDK](https://dart.dev/get-dart) 3.0 or later

### Run Locally

```bash
# Clone the repository
git clone https://github.com/sudiptoswe/dart-cli-expense-tracker.git
cd dart-cli-expense-tracker

# Get dependencies (none external — just resolves SDK)
dart pub get

# Run the tracker
dart run bin/main.dart
```

### Run in GitHub Codespaces ☁️

> **No local setup needed!** This repo includes a devcontainer configuration.

1. Click the green **`<> Code`** button on the repo page
2. Select the **Codespaces** tab
3. Click **Create codespace on main**
4. Once loaded, open the terminal and run:
   ```bash
   dart run bin/main.dart
   ```

### Compile to Native Binary

```bash
dart compile exe bin/main.dart -o expense_tracker
./expense_tracker
```

## 📸 Demo

```
  ╔══════════════════════════════════════════╗
  ║       💰 CLI Expense Tracker v1.0        ║
  ║       Built with Pure Dart                ║
  ╚══════════════════════════════════════════╝

  ┌────────────────────────────────┐
  │         📋 Main Menu           │
  ├────────────────────────────────┤
  │  1. ➕ Add Expense             │
  │  2. 📄 View All Expenses       │
  │  3. 🏷️  View by Category        │
  │  4. 📊 Monthly Summary         │
  │  5. 🚪 Exit                    │
  └────────────────────────────────┘
  Enter your choice (1-5): 2

  ──────────────────────────────────────────────────────────────────────────
  │ 📄 All Expenses (3 total)                                              │
  ──────────────────────────────────────────────────────────────────────────
  | ID   | Title                | Amount      | Category     | Date       |
  ──────────────────────────────────────────────────────────────────────────
  | 1    | Lunch at cafe        | $     15.50 | Food         | 2026-04-30 |
  | 2    | Uber ride            | $      8.75 | Transport    | 2026-04-30 |
  | 3    | Electricity bill     | $    120.00 | Bills        | 2026-04-28 |
  ──────────────────────────────────────────────────────────────────────────

  Total spent: $144.25
```

## 🏗️ Architecture

```
dart-cli-expense-tracker/
├── bin/
│   └── main.dart                    # CLI entry point — menu loop & input handling
├── lib/
│   ├── models/
│   │   └── expense.dart             # Expense class + Category enum (OOP)
│   ├── services/
│   │   ├── expense_service.dart     # Business logic (.where, .map, .fold)
│   │   └── storage_service.dart     # JSON file I/O (dart:io, dart:convert)
│   └── utils/
│       └── formatter.dart           # CLI formatting (tables, currency, bars)
├── .github/
│   └── workflows/
│       └── dart.yml                 # CI: format → analyze → compile
├── .devcontainer/
│   └── devcontainer.json            # GitHub Codespaces config
├── pubspec.yaml                     # Zero external dependencies
└── README.md
```

### Design Decisions

- **Layered Architecture** — Model → Service → UI separation, each layer has a single responsibility
- **Immutable Model** — `Expense` uses `const` constructor, all fields are `final`
- **Enhanced Enums** — `Category` carries its display label and has a safe `fromString` factory
- **No Singletons** — Services are injected via constructor, making them testable

## 📚 Dart Concepts Covered

This project was built as a **learning exercise** to solidify core Dart fundamentals:

### Object-Oriented Programming
- Classes with named constructors and factory constructors
- Enhanced enums with fields and methods
- `const` constructors for immutable objects
- Private constructors (`Formatter._()`) for utility classes
- Encapsulation with `_private` fields and public getters

### Null Safety
- Explicit types everywhere — no `var`, no `dynamic`
- `String?` / `int?` / `double?` with `tryParse` for safe parsing
- Null-coalescing operators (`??`, `?.`)
- **Zero uses of `!`** (bang operator)

### Functional Collection Methods
| Method | Usage | File |
|--------|-------|------|
| `.where()` | Filter expenses by category/month | `expense_service.dart` |
| `.map()` | Transform JSON ↔ Expense objects | `storage_service.dart` |
| `.fold()` | Sum totals, find max ID, find highest category | `expense_service.dart` |
| `.forEach()` | Print formatted table rows | `formatter.dart` |
| `.firstWhere()` | Enum deserialization with `orElse` | `expense.dart` |

### File I/O & Serialization
- `dart:io` for `File` read/write
- `dart:convert` for `jsonEncode`/`jsonDecode`
- `toJson()` / `fromJson()` pattern
- Exception handling: `FormatException`, `FileSystemException`

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/delete-expense`)
3. Commit your changes (`git commit -m 'Add delete expense feature'`)
4. Push to the branch (`git push origin feature/delete-expense`)
5. Open a Pull Request

### Ideas for Extension

- [ ] Delete an expense by ID
- [ ] Edit an existing expense
- [ ] Search expenses by title keyword
- [ ] Export to CSV format
- [ ] Date range filtering
- [ ] Budget limits with warnings

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

<div align="center">
  <b>Built with ❤️ in pure Dart</b>
</div>
