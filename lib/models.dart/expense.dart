class Expense {
  String expenseType;
  String reason;
  String valueType;
  double value;

  Expense({
    required this.expenseType,
    required this.reason,
    required this.valueType,
    required this.value,
  });

  factory Expense.fromMenu(
    String expenseType,
    String reason,
    String valueType,
    double value,
  ) {
    return Expense(
      expenseType: expenseType,
      reason: reason,
      valueType: valueType,
      value: value,
    );
  }

  factory Expense.fromMap(
    Map map,
  ) {
    return Expense(
      expenseType: map['expenseType'],
      reason: map['reason'],
      valueType: map['valueType'],
      value: map['value'],
    );
  }

  Map<String, dynamic> toFirestore() => <String, dynamic>{
        'expenseType': expenseType,
        'reason': reason,
        'valueType': valueType,
        'value': value,
      };
}
