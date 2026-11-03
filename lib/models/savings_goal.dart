class SavingsGoal {
  final int? id;
  final String title;
  final double targetAmount;
  final double currentAmount;

  SavingsGoal({
    this.id,
    required this.title,
    required this.targetAmount,
    this.currentAmount = 0.0,
  });

  double get progress {
    if (targetAmount <= 0) return 0.0;
    final p = currentAmount / targetAmount;
    return p > 1.0 ? 1.0 : p;
  }

  double get percentage => (progress * 100);

  bool get isCompleted => currentAmount >= targetAmount;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
    };
  }

  factory SavingsGoal.fromMap(Map<String, dynamic> map) {
    return SavingsGoal(
      id: map['id'] as int?,
      title: map['title'] as String,
      targetAmount: (map['target_amount'] as num).toDouble(),
      currentAmount: (map['current_amount'] as num).toDouble(),
    );
  }

  SavingsGoal copyWith({
    int? id,
    String? title,
    double? targetAmount,
    double? currentAmount,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
    );
  }
}

