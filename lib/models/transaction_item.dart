class TransactionItem {
  final int? id;
  final String title;
  final double amount;
  final String type; // 'income' | 'expense'
  final String category;
  final String date; // YYYY-MM-DD

  TransactionItem({
    this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
  });

  bool get isIncome => type == 'income';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type,
      'category': category,
      'date': date,
    };
  }

  factory TransactionItem.fromMap(Map<String, dynamic> map) {
    return TransactionItem(
      id: map['id'] as int?,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] as String,
      category: map['category'] as String,
      date: map['date'] as String,
    );
  }
}

