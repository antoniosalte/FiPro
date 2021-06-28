import 'dart:math';

import 'expense.dart';

class Bill {
  DateTime emissionDate; //Fecha de Emision
  DateTime dueDate; // Fecha de VencimientoFecha de Descuento
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
    required this.emissionDate,
    required this.dueDate,
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

  factory Bill.fromMenu(
    DateTime emissionDate,
    DateTime dueDate,
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
    int days = dueDate.difference(emissionDate).inDays;

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
      emissionDate: emissionDate,
      dueDate: dueDate,
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
}

class Rate {
  String type; // Tipo de Tasa (Efectiva o Nominal)
  String term; // Periodo de la tasa
  double value;
  int days; // Dias de la tasa
  int daysPerYear; // Dias por año

  Rate({
    required this.type,
    required this.term,
    required this.value,
    required this.days,
    required this.daysPerYear,
  });

  factory Rate.fromBill(
      String type, String term, double value, int days, int daysPerYear) {
    return Rate(
      type: type,
      term: term,
      value: value,
      days: days,
      daysPerYear: daysPerYear,
    );
  }

  factory Rate.createTCEA(Rate rate) {
    num? value;

    if (rate.type == "Nominal") {
      int n = 12;
      int m = rate.days ~/ 30;
      value = pow(1 + (rate.value / m), n) - 1;
    } else if (rate.type == "Efectiva") {
      value = pow(1 + rate.value, 360 / rate.days) - 1;
    }

    return Rate(
      type: "Efectiva",
      term: "Anual",
      value: value!.toDouble(),
      days: 360,
      daysPerYear: rate.daysPerYear,
    );
  }
}
