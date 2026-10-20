# Expense Tracker 💰

A simple and modern **Expense Tracker** application built with Flutter and SQLite. Track your daily expenses, organize spending by category, and monitor your total expenses with a clean and user-friendly interface.

## ✨ Features

- **Add Expenses:** Enter an expense title, amount, and category.
- **Expense Categories:** Organize expenses into bills, food, entertainment, transportation, and other.
- **View Expenses:** Display saved expenses in a list, with the most recent shown first.
- **Delete Expenses:** Remove expenses you no longer need.
- **Total Expenses:** Calculate and display the total amount spent in EGP.
- **Local Database:** Store expense records locally.
- **Cross-Platform Support:** Configure database support for Android and Flutter Web.

## 🛠️ Technologies Used

- Flutter
- Dart
- SQLite
- `sqflite`
- `sqflite_common_ffi_web`
- `path`
- Material Design

## 📱 Screenshots

Add screenshots of your application here.

```text
screenshots/
├── home_screen.png
├── add_expense.png
└── expenses_list.png
```

## 🚀 Getting Started

### Prerequisites

Make sure you have installed:

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Dart SDK](https://dart.dev/get-dart)
- [Visual Studio Code](https://code.visualstudio.com/) or another IDE
- Chrome for running the Web version

### Installation

1. Clone the repository:

   ```bash
   git clone YOUR_GITHUB_REPOSITORY_URL
   ```

2. Navigate to the project directory:

   ```bash
   cd session_3_10
   ```

3. Install dependencies:

   ```bash
   flutter pub get
   ```

### Running on Android

```bash
flutter run
```

### Running on Web

Configure the Web database package:

```bash
flutter pub add sqflite_common_ffi_web
dart run sqflite_common_ffi_web:setup
```

Make sure the database factory is initialized before `runApp()` in `main.dart`:

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  runApp(const MyApp());
}
```

Then run:

```bash
flutter run -d chrome
```

## 📂 Project Structure

```text
lib/
├── helper/
│   └── DataBaseHelper.dart
├── models/
│   └── expense_model.dart
└── main.dart
```

The project may contain additional screens or folders depending on your implementation.

## 💾 Database Schema

The application uses an `expenses` table with the following fields:

| Column | Type | Description |
|---|---|---|
| `id` | INTEGER | Auto-incrementing primary key |
| `title` | TEXT | Expense title |
| `category` | TEXT | Expense category |
| `amount` | REAL | Expense amount |

## 🎯 Learning Objectives

This project demonstrates:

- Building Flutter UIs with Material Design.
- Managing state with `StatefulWidget` and `setState`.
- Creating reusable database helper methods.
- Performing SQLite CRUD operations.
- Using asynchronous programming with `async` and `await`.
- Validating user input.
- Calculating totals from stored data.
- Configuring database support for Flutter Web.

## 🔮 Future Improvements

- Edit existing expenses.
- Filter expenses by category.
- Search expenses by title.
- Add dates to expense records.
- Display spending charts and statistics.
- Add monthly budgets and spending limits.
- Export expense reports.

## 👨‍💻 Author

**Abdulrhman**

Thanks for checking out my Expense Tracker project!

If you find this project useful, feel free to ⭐ the repository.

## 📄 License

This project is open source and available under the MIT License. Add a `LICENSE` file to the repository if you choose to distribute it under that license.
