import 'package:flutter_test/flutter_test.dart';
import 'package:smartpocket/models/transaction_item.dart';
import 'package:smartpocket/models/savings_goal.dart';

void main() {
  group('SmartPocket Models Test', () {
    test('TransactionItem calculations and serialization', () {
      final item = TransactionItem(
        id: 1,
        title: 'Makan Siang',
        amount: 25000,
        type: 'expense',
        category: 'Makanan',
        date: '2026-11-02',
      );

      expect(item.isIncome, false);
      expect(item.toMap()['amount'], 25000.0);

      final fromMap = TransactionItem.fromMap(item.toMap());
      expect(fromMap.title, 'Makan Siang');
      expect(fromMap.isIncome, false);
    });

    test('SavingsGoal progress and percentage calculation', () {
      final goal = SavingsGoal(
        id: 1,
        title: 'Beli Sepeda',
        targetAmount: 2000000,
        currentAmount: 500000,
      );

      expect(goal.progress, 0.25);
      expect(goal.percentage, 25.0);
      expect(goal.isCompleted, false);

      final completedGoal = goal.copyWith(currentAmount: 2000000);
      expect(completedGoal.progress, 1.0);
      expect(completedGoal.percentage, 100.0);
      expect(completedGoal.isCompleted, true);
    });
  });
}
