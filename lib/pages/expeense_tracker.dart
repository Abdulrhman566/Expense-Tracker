import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:session_3_10/helper/DataBaseHelper.dart';
import 'package:session_3_10/models/expense_model.dart';

class ExpeenseTracker extends StatefulWidget {
  const ExpeenseTracker({super.key});

  @override
  State<ExpeenseTracker> createState() => _ExpeenseTrackerState();
}

class _ExpeenseTrackerState extends State<ExpeenseTracker> {
  List<ExpenseModel> expenses = [];
  Map<String, double> categoryTotals = {};

  double totalExpense = 0;
  bool isLoading = true;

  final List<String> categories = [
    'food',
    'bills',
    'transportation',
    'entertainment',
    'other',
  ];

  final Map<String, String> categoryLabels = {
    'food': 'Food',
    'bills': 'Bills',
    'transportation': 'Transport',
    'entertainment': 'Entertainment',
    'other': 'Other',
  };

  @override
  void initState() {
    super.initState();
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    try {
      final loadedExpenses = await Databasehelper.instance.getexpense();
      final total = await Databasehelper.instance.getTotalExpense();
      final totals = await Databasehelper.instance.getExpensesByCategory();

      if (!mounted) return;

      setState(() {
        expenses = loadedExpenses;
        totalExpense = total;
        categoryTotals = totals;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error loading expenses: $e')));
    }
  }

  IconData getCategoryIcon(String category) {
    switch (category) {
      case 'food':
        return Icons.restaurant;
      case 'bills':
        return Icons.receipt_long;
      case 'transportation':
        return Icons.directions_car;
      case 'entertainment':
        return Icons.movie;
      default:
        return Icons.category;
    }
  }

  Color getCategoryColor(String category) {
    switch (category) {
      case 'food':
        return Colors.orange;
      case 'bills':
        return Colors.blue;
      case 'transportation':
        return Colors.green;
      case 'entertainment':
        return Colors.purple;
      default:
        return Colors.teal;
    }
  }

  Future<void> showAddExpenseDialog() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ExpenseFormSheet(
          onSave: (expense) async {
            await Databasehelper.instance.insertExpense(expense);
            await loadExpenses();
          },
        );
      },
    );
  }

  Future<void> showEditExpenseDialog(ExpenseModel expense) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ExpenseFormSheet(
          existingExpense: expense,
          onSave: (updatedExpense) async {
            await Databasehelper.instance.updateExpense(updatedExpense);
            await loadExpenses();
          },
        );
      },
    );
  }

  Future<void> deleteExpense(int? id) async {
    if (id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Expense'),
          content: const Text('Are you sure you want to delete this expense?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await Databasehelper.instance.deleteExpense(id);
      await loadExpenses();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense deleted successfully')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error deleting expense: $e')));
    }
  }

  Widget buildTotalCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF673AB7), Color(0xFF9575CD)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Expenses',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Text(
            '\$${totalExpense.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${expenses.length} expenses recorded',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget buildPieChart() {
    final entries = categoryTotals.entries
        .where((entry) => entry.value > 0)
        .toList();

    final total = entries.fold<double>(0, (sum, entry) => sum + entry.value);

    if (entries.isEmpty || total <= 0) {
      return const SizedBox(
        height: 180,
        child: Center(child: Text('No expense data to display')),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: 40,
              sections: entries.map((entry) {
                final percentage = entry.value / total * 100;

                return PieChartSectionData(
                  color: getCategoryColor(entry.key),
                  value: entry.value,
                  title: '${percentage.toStringAsFixed(0)}%',
                  radius: 75,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 12,
          children: entries.map((entry) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: getCategoryColor(entry.key),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  categoryLabels[entry.key] ?? entry.key,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget buildBarChart() {
    // Keep a consistent category order for chart labels.
    final chartCategories = categories
        .where((category) => (categoryTotals[category] ?? 0) > 0)
        .toList();

    if (chartCategories.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(child: Text('No expense data to display')),
      );
    }

    final amounts = chartCategories
        .map((category) => categoryTotals[category] ?? 0.0)
        .toList();

    final maxAmount = amounts.reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 280,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxAmount * 1.2 + 1,
          minY: 0,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 45),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 45,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();

                  if (index < 0 ||
                      index >= chartCategories.length ||
                      value != index.toDouble()) {
                    return const SizedBox.shrink();
                  }

                  final category = chartCategories[index];
                  final label = categoryLabels[category] ?? category;

                  // No SideTitleWidget needed.
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: true),
          barGroups: List.generate(chartCategories.length, (index) {
            final category = chartCategories[index];

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: amounts[index],
                  width: 20,
                  color: getCategoryColor(category),
                  borderRadius: BorderRadius.circular(5),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget buildSectionCard({required String title, required Widget child}) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }

  Widget buildExpenseItem(ExpenseModel expense) {
    final categoryColor = getCategoryColor(expense.category);

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: categoryColor.withValues(alpha: 0.12),
          child: Icon(getCategoryIcon(expense.category), color: categoryColor),
        ),
        title: Text(
          expense.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(categoryLabels[expense.category] ?? expense.category),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '\$${expense.amount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            IconButton(
              tooltip: 'Edit expense',
              icon: const Icon(
                Icons.edit_outlined,
                color: Colors.blue,
                size: 20,
              ),
              onPressed: () => showEditExpenseDialog(expense),
            ),
            IconButton(
              tooltip: 'Delete expense',
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 20,
              ),
              onPressed: () => deleteExpense(expense.id),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      appBar: AppBar(
        title: const Text(
          'Expense Tracker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadExpenses,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  buildTotalCard(),
                  const SizedBox(height: 20),
                  buildSectionCard(
                    title: 'Expenses by Category',
                    child: buildPieChart(),
                  ),
                  const SizedBox(height: 16),
                  buildSectionCard(
                    title: 'Category Comparison',
                    child: buildBarChart(),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Recent Expenses',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (expenses.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: Text('No expenses yet. Tap + to add one.'),
                      ),
                    )
                  else
                    ...expenses.map(buildExpenseItem),
                  const SizedBox(height: 80),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddExpenseDialog,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Reusable form for adding and editing expenses.
class ExpenseFormSheet extends StatefulWidget {
  final ExpenseModel? existingExpense;
  final Future<void> Function(ExpenseModel expense) onSave;

  const ExpenseFormSheet({
    super.key,
    this.existingExpense,
    required this.onSave,
  });

  @override
  State<ExpenseFormSheet> createState() => _ExpenseFormSheetState();
}

class _ExpenseFormSheetState extends State<ExpenseFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController titleController;
  late final TextEditingController amountController;

  final List<String> categories = [
    'food',
    'bills',
    'transportation',
    'entertainment',
    'other',
  ];

  final Map<String, String> categoryLabels = {
    'food': 'Food',
    'bills': 'Bills',
    'transportation': 'Transportation',
    'entertainment': 'Entertainment',
    'other': 'Other',
  };

  late String selectedCategory;
  bool isSaving = false;

  bool get isEditing => widget.existingExpense != null;

  @override
  void initState() {
    super.initState();

    final expense = widget.existingExpense;

    titleController = TextEditingController(text: expense?.title ?? '');

    amountController = TextEditingController(
      text: expense?.amount.toString() ?? '',
    );

    selectedCategory = categories.contains(expense?.category)
        ? expense!.category
        : 'other';
  }

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    super.dispose();
  }

  Future<void> saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    final title = titleController.text.trim();
    final amount = double.tryParse(amountController.text.trim());

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter an amount greater than zero')),
      );
      return;
    }

    final expense = ExpenseModel(
      id: widget.existingExpense?.id,
      title: title,
      category: selectedCategory,
      amount: amount,
    );

    setState(() {
      isSaving = true;
    });

    try {
      await widget.onSave(expense);

      if (!mounted) return;

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not save expense: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isEditing ? 'Edit Expense' : 'Add Expense',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: titleController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: 'Expense title',
                    hintText: 'e.g. Grocery shopping',
                    prefixIcon: const Icon(Icons.edit),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    hintText: '0.00',
                    prefixIcon: const Icon(Icons.attach_money),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  validator: (value) {
                    final amount = double.tryParse(value?.trim() ?? '');

                    if (amount == null || amount <= 0) {
                      return 'Enter a valid amount greater than zero';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    prefixIcon: const Icon(Icons.category_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  items: categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(categoryLabels[category] ?? category),
                    );
                  }).toList(),
                  onChanged: isSaving
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() {
                              selectedCategory = value;
                            });
                          }
                        },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isSaving ? null : saveExpense,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(isEditing ? 'Update Expense' : 'Save Expense'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
