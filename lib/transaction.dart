import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
// import 'package:json_annotation/json_annotation.dart';

part 'transaction.g.dart';

@HiveType(typeId: 0)
class Transaction extends HiveObject {
  @HiveField(0)
  String description;

  @HiveField(1)
  double amount;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  bool isIncome;

  Transaction({
    required this.description,
    required this.amount,
    required this.date,
    required this.isIncome,
  });
    @override
  String toString() {
    return 'Transaction(topic: $description, amount: $amount, category: $isIncome, date: $date)';
  }

}
