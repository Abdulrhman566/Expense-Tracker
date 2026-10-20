# 💰 Expense Tracker

A modern and user-friendly **Expense Tracker application built with Flutter and SQLite**. Easily manage your daily expenses, organize spending by category, track your total spending, and visualize your financial habits through interactive charts.

## ✨ Features

- ➕ **Add Expenses** — Record expenses with a title, amount, and category.
- ✏️ **Edit Expenses** — Update existing expense information.
- 🗑️ **Delete Expenses** — Remove unwanted expenses with confirmation.
- 📋 **Expense History** — View all saved expenses, with the latest displayed first.
- 💵 **Total Spending** — Automatically calculate the total amount of recorded expenses.
- 🗂️ **Expense Categories** — Organize expenses into Food, Bills, Transportation, Entertainment, and Other.
- 🥧 **Pie Chart** — Visualize the percentage of spending across categories.
- 📊 **Bar Chart** — Compare expenses between different categories.
- 💾 **Local Database** — Store expense records using SQLite.
- 🌐 **Flutter Web Support** — Run the application in a browser with the appropriate database configuration.
- 🎨 **Modern UI** — Enjoy a clean interface with category icons, summary cards, and a consistent purple theme.

## 🛠️ Built With

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform application development |
| Dart | Programming language |
| SQLite | Local data persistence |
| `sqflite` | Database operations |
| `sqflite_common_ffi_web` | SQLite support for Flutter Web |
| `fl_chart` | Interactive pie and bar charts |
| `path` | Database path management |
| Material Design | User interface components |

## 📸 Screenshots

Add screenshots of the application here to demonstrate its interface and functionality.

```text
screenshots/
├── home_screen.png
├── add_expense.png
├── edit_expense.png
├── pie_chart.png
└── bar_chart.png
```

After adding your screenshots to the repository, display them in this section:

```markdown
![Home Screen](screenshots/home_screen.png)

![Add Expense](screenshots/add_expense.png)

![Expense Analytics](screenshots/pie_chart.png)
```

## 🚀 Getting Started

Follow these steps to run the project locally.

### Prerequisites

Make sure you have installed:

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Dart SDK](https://dart.dev/get-dart)
- [Visual Studio Code](https://code.visualstudio.com/) or another Flutter-compatible IDE
- Google Chrome for running the Web version

### Installation

**1. Clone the repository**

```bash
git clone https://github.com/Abdulrhman566/Expense-Tracker.git
```

**2. Navigate to the project directory**

```bash
cd Expense-Tracker
```

**3. Install dependencies**

```bash
flutter pub get
```

**4. Run the application**

For an Android emulator or connected device:

```bash
flutter run
```

For Google Chrome:

```bash
flutter run -d chrome
```

## 🌐 Flutter Web Configuration

The Web version requires a compatible SQLite database factory.

If you have not configured Web database support yet, add the package:

```bash
flutter pub add sqflite_common_ffi_web
```

Run the setup command if required by your installed package version:

```bash
dart run sqflite_common_ffi_web:setup
```

Initialize the database factory before accessing the database in `main.dart`:

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

Replace `MyApp` with the name of your application's root widget if necessary.

**Note:** Follow the setup instructions for the version of `sqflite_common_ffi_web` installed in your project. Database initialization must happen before opening the database.

## 📂 Project Structure

The main files are organized by responsibility:

```text
lib/
├── helper/
│   └── DataBaseHelper.dart
├── models/
│   └── expense_model.dart
├── pages/
│   └── expeense_tracker.dart
└── main.dart
```

Your repository may contain additional files or folders depending on your implementation.

### Code Organization

- **`models/`** — Defines the expense data model and map conversions.
- **`helper/`** — Manages database initialization and CRUD operations.
- **`pages/`** — Contains the main interface, expense forms, expense list, and charts.
- **`main.dart`** — Initializes and launches the application.

## 💾 Database Schema

The application stores expense records in an `expenses` table.

| Column | Type | Description |
|---|---|---|
| `id` | INTEGER | Auto-incrementing primary key |
| `title` | TEXT | Name or description of the expense |
| `category` | TEXT | Expense category |
| `amount` | REAL | Amount spent |

### Database Operations

The database helper supports the following operations:

- **Create:** Insert new expenses.
- **Read:** Retrieve saved expenses.
- **Update:** Edit existing expense records.
- **Delete:** Remove expense records.
- **Calculate totals:** Sum all recorded expense amounts.
- **Group by category:** Calculate category totals for data visualization.

## 📊 Expense Analytics

The app includes two types of charts to make spending easier to understand.

**Pie Chart**

Displays the relative contribution of each category to total spending.

**Bar Chart**

Compares the total spending for individual categories, making it easier to identify where most of the money goes.

The charts and summary information refresh after expense records are added, edited, or deleted.

## 🎯 What I Learned

Through this project, I practiced and improved my Flutter development skills, including:

- Building user interfaces with Flutter and Material Design.
- Managing UI state with `StatefulWidget` and `setState`.
- Integrating SQLite for local data persistence.
- Implementing complete CRUD operations.
- Using asynchronous programming with `async` and `await`.
- Validating user input and handling errors.
- Writing SQL queries with `SUM()` and `GROUP BY`.
- Visualizing data using the `fl_chart` package.
- Building reusable forms for creating and editing records.
- Configuring database support for Flutter Web.

## 🔮 Future Improvements

Potential enhancements for future versions include:

- 📅 Add expense dates and monthly summaries.
- 🔍 Search expenses by title.
- 🗂️ Filter expenses by category.
- 🎯 Set monthly budgets and spending limits.
- 📤 Export expense reports to CSV or PDF.
- 🌙 Introduce dark mode.
- ☁️ Add cloud synchronization and user accounts.
- 📈 Track spending trends over time.

## 👨‍💻 Author

**Abdulrhman**

GitHub: [@Abdulrhman566](https://github.com/Abdulrhman566)

### ⭐ Support

If you find this project useful, consider giving the repository a star. Feedback and suggestions are always welcome!

## 📄 License

Add a `LICENSE` file to the repository if you intend to distribute this project under an open-source license, and update this section to identify the license you choose.
