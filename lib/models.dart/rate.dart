import 'dart:math';

class Rate {
  String type; // Tipo de Tasa (Efectiva o Nominal)
  String term; // Periodo de la tasa
  double value; // Valor de la tasa
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

  factory Rate.fromMap(Map data) {
    return Rate(
      type: data['type'],
      term: data['term'],
      value: data['value'],
      days: data['days'],
      daysPerYear: data['daysPerYear'],
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

  Map<String, dynamic> toFirestore() => <String, dynamic>{
        'type': type,
        'term': term,
        'value': value,
        'days': days,
        'daysPerYear': daysPerYear,
      };
}
