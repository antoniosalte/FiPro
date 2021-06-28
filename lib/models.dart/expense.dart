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
}
