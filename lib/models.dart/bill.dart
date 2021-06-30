import 'dart:math';

import 'expense.dart';
import 'rate.dart';

class Bill {
  String id; // Id
  String userId; //Id del Usuario
  DateTime discountDate; //Fecha de Descuento
  DateTime dueDate; // Fecha de VencimientoFecha de Descuento
  DateTime billDate; // Fecha de Giro
  double nominalValue; // Valor nominal
  double initialTotal; //Costos iniciales
  double finalTotal; // Costos finales
  List<Expense> initialExpenses; // Lista de Gastos iniciales
  List<Expense> finalExpenses; // Lista de Gastos finales
  int days; // Numero de dias
  double interestRate; // TEP (i')
  double discountRate; // Descuento %
  double discount; // Valor del Descuento
  double netWorth; // Valor neto
  double valueToReceive; // Valor a recibir
  double cashFlow; // Flujo
  double currentTCEARate; // TCEA
  Rate rate; // Tasa ingresa por el usuario
  Rate tcea; // TCEA usada

  Bill({
    required this.id,
    required this.userId,
    required this.discountDate,
    required this.dueDate,
    required this.billDate,
    required this.nominalValue,
    required this.initialTotal,
    required this.finalTotal,
    required this.initialExpenses,
    required this.finalExpenses,
    required this.days,
    required this.interestRate,
    required this.discountRate,
    required this.discount,
    required this.netWorth,
    required this.valueToReceive,
    required this.cashFlow,
    required this.currentTCEARate,
    required this.rate,
    required this.tcea,
  });

  factory Bill.createToFirestore(
    String id,
    String userId,
    DateTime discountDate,
    DateTime dueDate,
    DateTime billDate,
    double nominalValue,
    double initialTotal,
    double finalTotal,
    List<Expense> initialExpenses,
    List<Expense> finalExpenses,
    String rateType,
    String rateTerm,
    double rateValue,
    int rateDays,
    int daysPerYear,
  ) {
    int days = dueDate.difference(discountDate).inDays;

    Rate rate =
        Rate.fromBill(rateType, rateTerm, rateValue, rateDays, daysPerYear);
    Rate tcea = Rate.createTCEA(rate);

    double interestRate = pow(1 + tcea.value, days / daysPerYear) - 1;
    double discountRate = interestRate / (1 + interestRate);
    double discount = nominalValue * discountRate;
    double netWorth = nominalValue - discount;
    double valueToReceive = netWorth - initialTotal;
    double cashFlow = nominalValue + finalTotal;

    double currentTCEARate =
        pow(cashFlow / valueToReceive, daysPerYear / days) - 1;

    return Bill(
      id: id,
      userId: userId,
      discountDate: discountDate,
      dueDate: dueDate,
      billDate: billDate,
      nominalValue: nominalValue,
      initialTotal: initialTotal,
      finalTotal: finalTotal,
      initialExpenses: initialExpenses,
      finalExpenses: finalExpenses,
      days: days,
      interestRate: interestRate,
      discountRate: discountRate,
      discount: discount,
      netWorth: netWorth,
      valueToReceive: valueToReceive,
      cashFlow: cashFlow,
      currentTCEARate: currentTCEARate,
      rate: rate,
      tcea: tcea,
    );
  }

  factory Bill.fromFirestore(
    String id,
    String userId,
    DateTime discountDate,
    DateTime dueDate,
    DateTime billDate,
    double nominalValue,
    double initialTotal,
    double finalTotal,
    List<Expense> initialExpenses,
    List<Expense> finalExpenses,
    int days,
    double interestRate,
    double discountRate,
    double discount,
    double netWorth,
    double valueToReceive,
    double cashFlow,
    double currentTCEARate,
    Rate rate,
    Rate tcea,
  ) {
    return Bill(
      id: id,
      userId: userId,
      discountDate: discountDate,
      dueDate: dueDate,
      billDate: billDate,
      nominalValue: nominalValue,
      initialTotal: initialTotal,
      finalTotal: finalTotal,
      initialExpenses: initialExpenses,
      finalExpenses: finalExpenses,
      days: days,
      interestRate: interestRate,
      discountRate: discountRate,
      discount: discount,
      netWorth: netWorth,
      valueToReceive: valueToReceive,
      cashFlow: cashFlow,
      currentTCEARate: currentTCEARate,
      rate: rate,
      tcea: tcea,
    );
  }

  Map<String, dynamic> toFirestore() {
    List<Map> initialExpensesMap = [];
    List<Map> finalExpensesMap = [];

    for (Expense expense in initialExpenses) {
      initialExpensesMap.add(expense.toFirestore());
    }

    for (Expense expense in finalExpenses) {
      finalExpensesMap.add(expense.toFirestore());
    }

    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'discountDate': discountDate,
      'dueDate': dueDate,
      'billDate': billDate,
      'nominalValue': nominalValue,
      'initialTotal': initialTotal,
      'finalTotal': finalTotal,
      'initialExpenses': initialExpensesMap,
      'finalExpenses': finalExpensesMap,
      'days': days,
      'interestRate': interestRate,
      'discountRate': discountRate,
      'discount': discount,
      'netWorth': netWorth,
      'valueToReceive': valueToReceive,
      'cashFlow': cashFlow,
      'currentTCEARate': currentTCEARate,
      'rate': rate.toFirestore(),
      'tcea': tcea.toFirestore(),
    };
  }
}
