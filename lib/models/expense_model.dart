class ExpenseModel {
  final int? id;
  final String title;
  final String category;
  final double amount;

  ExpenseModel({
    this.id,
    required this.title,
    required this.category,
    required this.amount,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'category': category,
      'amount': amount,
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] as int?,
      title: (map['title'] as String?) ?? '',
      category: (map['category'] as String?) ?? '',
      amount: ((map['amount'] as num?) ?? 0).toDouble(),
    );
  }
}
