import 'package:fipro/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:fipro/widgets/header_widget.dart';

import 'package:fipro/widgets/title_widget.dart';
import 'package:fipro/widgets/subtitle_widget.dart';
import 'package:fipro/widgets/label_widget.dart';

import 'package:fipro/models.dart/expense.dart';
import 'package:fipro/models.dart/bill.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime? emissionDate;
  DateTime? dueDate;

  String rateType = "Efectiva";
  String daysPerYear = "360";
  String rateTerm = "Semestral";
  String? nominalValue;
  String? rateValue;

  int rateDays = 180;

  String? initialReason;
  String initialValueType = "Efectivo";
  String? initialValue;
  double initialTotal = 0.0;

  String? finalReason;
  String finalValueType = "Efectivo";
  String? finalValue;
  double finalTotal = 0.0;

  List<Expense> initialExpenses = [];
  List<Expense> finalExpenses = [];

  List<Bill> bills = [];

  List<String> rateTerms = [
    "Anual",
    "Semestral",
    "Cuatrimestral",
    "Trimestral",
    "Bimestral",
    "Mensual",
    "Quincenal",
    "Diario"
  ];

  Map<String, int> rateMap = {
    "Anual": 360,
    "Semestral": 180,
    "Cuatrimestral": 120,
    "Trimestral": 90,
    "Bimestral": 60,
    "Mensual": 30,
    "Quincenal": 15,
    "Diario": 1
  };

  List<String> valueTypes = ["Efectivo", "Credito"];

  final _amountValidator = RegExp('^\$|^(0|([1-9][0-9]{0,}))(\\.[0-9]{0,})?\$');

  String getText(DateTime? date) {
    if (date == null) {
      return 'Selecciona una fecha';
    } else {
      return DateFormat('MM/dd/yyyy').format(date);
    }
  }

  Future pickEmissionDate() async {
    final initialDate = DateTime.now();
    final newDate = await showDatePicker(
      context: context,
      initialDate: emissionDate ?? initialDate,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 5),
    );

    if (newDate == null) return;

    setState(() => emissionDate = newDate);
  }

  Future pickDueDate() async {
    final initialDate = DateTime.now();
    final newDate = await showDatePicker(
      context: context,
      initialDate: dueDate ?? initialDate,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 5),
    );

    if (newDate == null) return;

    setState(() => dueDate = newDate);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double cardWidth = (width / 8) * 3;

    return Scaffold(
      appBar: HeaderWidget(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 24.0),
            TitleWidget(title: 'Letra Descontada a Tasa Nominal'),
            SizedBox(height: 24.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Card(
                  child: Container(
                    width: cardWidth,
                    padding: EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SubtitleWidget(title: "Datos de Letra"),
                        SizedBox(height: 16.0),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              LabelWidget(label: 'Fecha de Emision'),
                              Flexible(
                                child: Container(
                                  width: double.infinity,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  child: Center(
                                    child: TextButton(
                                      child: Text(
                                        getText(emissionDate),
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      onPressed: () => pickEmissionDate(),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              LabelWidget(label: 'Fecha de Vencimiento'),
                              Flexible(
                                child: Container(
                                  width: double.infinity,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  child: Center(
                                    child: TextButton(
                                      child: Text(
                                        getText(dueDate),
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      onPressed: () => pickDueDate(),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              LabelWidget(label: 'Valor Nominal'),
                              Flexible(
                                child: TextField(
                                  keyboardType: TextInputType.numberWithOptions(
                                    decimal: true,
                                    signed: false,
                                  ),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        _amountValidator),
                                  ],
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    height: 1.0,
                                  ),
                                  onChanged: ((value) => {
                                        setState(() {
                                          nominalValue = value;
                                        })
                                      }),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  child: Container(
                    width: cardWidth,
                    padding: EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SubtitleWidget(title: "Tasa y Plazo"),
                        SizedBox(height: 16.0),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              LabelWidget(label: 'Dias por año'),
                              Flexible(
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  child: Center(
                                    child: DropdownButton<String>(
                                      value: daysPerYear,
                                      underline: Container(
                                        height: 0,
                                      ),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          daysPerYear = newValue!;
                                        });
                                      },
                                      items: <String>["360", "365"]
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              LabelWidget(label: 'Plazo de Tasa'),
                              Flexible(
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey,
                                            width: 1,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(4.0),
                                        ),
                                        child: Center(
                                          child: DropdownButton<String>(
                                            value: rateTerm,
                                            underline: Container(
                                              height: 0,
                                            ),
                                            onChanged: (String? newValue) {
                                              setState(() {
                                                rateTerm = newValue!;
                                                rateDays = rateMap[rateTerm]!;
                                              });
                                            },
                                            items: rateTerms
                                                .map<DropdownMenuItem<String>>(
                                                    (String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 4.0),
                                    Flexible(
                                      child: Container(
                                        width: double.infinity,
                                        height: 50.0,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey,
                                            width: 1,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(4.0),
                                        ),
                                        child: Center(
                                          child: Text(
                                              "$rateDays dia${rateDays > 1 ? 's' : ''}"),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              LabelWidget(label: 'Tasa $rateType'),
                              Flexible(
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: TextField(
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                          decimal: true,
                                          signed: false,
                                        ),
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                        ),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              _amountValidator),
                                        ],
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          height: 1.0,
                                        ),
                                        onChanged: ((value) => {
                                              setState(() {
                                                rateValue = value;
                                              })
                                            }),
                                      ),
                                    ),
                                    SizedBox(width: 8.0),
                                    Text(
                                      "%",
                                      style: TextStyle(fontSize: 24.0),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Container(
                    width: cardWidth,
                    padding: EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SubtitleWidget(title: "Gastos Iniciales"),
                        SizedBox(height: 16.0),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              LabelWidget(label: 'Motivo'),
                              Flexible(
                                flex: 3,
                                child: TextField(
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    height: 1.0,
                                  ),
                                  onChanged: ((value) => {
                                        setState(() {
                                          initialReason = value;
                                        })
                                      }),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              LabelWidget(label: 'Valor'),
                              Flexible(
                                flex: 3,
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey,
                                            width: 1,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(4.0),
                                        ),
                                        child: Center(
                                          child: DropdownButton<String>(
                                            value: initialValueType,
                                            underline: Container(
                                              height: 0,
                                            ),
                                            onChanged: (String? newValue) {
                                              setState(() {
                                                initialValueType = newValue!;
                                              });
                                            },
                                            items: valueTypes
                                                .map<DropdownMenuItem<String>>(
                                                    (String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 4.0),
                                    Flexible(
                                      child: TextField(
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                          decimal: true,
                                          signed: false,
                                        ),
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                        ),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              _amountValidator),
                                        ],
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          height: 1.0,
                                        ),
                                        onChanged: ((value) => {
                                              setState(() {
                                                initialValue = value;
                                              })
                                            }),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8.0),
                        ButtonWidget(
                          text: "Agregar",
                          onPressed: () {
                            setState(() {
                              double value = double.parse(initialValue!);
                              initialExpenses.add(
                                Expense.fromMenu(
                                  "Initial",
                                  initialReason!,
                                  initialValueType,
                                  value,
                                ),
                              );
                              initialTotal += value;
                            });
                          },
                        ),
                        Container(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: [
                                DataColumn(label: Text('Index')),
                                DataColumn(label: Text('Motivo')),
                                DataColumn(label: Text('Valor')),
                                DataColumn(label: Text('Tipo')),
                                DataColumn(label: Text('Acciones')),
                              ],
                              rows: initialExpenses.map((e) {
                                int index = initialExpenses.indexOf(e);
                                return DataRow(cells: [
                                  DataCell(Text((index + 1).toString())),
                                  DataCell(Text(e.reason)),
                                  DataCell(Text(e.value.toString())),
                                  DataCell(Text(e.valueType)),
                                  DataCell(
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () {
                                        setState(() {
                                          initialTotal -= e.value;
                                          initialExpenses.remove(e);
                                        });
                                      },
                                    ),
                                  ),
                                ]);
                              }).toList(),
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          child: Text(
                            initialTotal.toStringAsFixed(2),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  child: Container(
                    width: cardWidth,
                    padding: EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SubtitleWidget(title: "Gastos Finales"),
                        SizedBox(height: 16.0),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              LabelWidget(label: 'Motivo'),
                              Flexible(
                                flex: 3,
                                child: TextField(
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    height: 1.0,
                                  ),
                                  onChanged: ((value) => {
                                        setState(() {
                                          finalReason = value;
                                        })
                                      }),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              LabelWidget(label: 'Valor'),
                              Flexible(
                                flex: 3,
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey,
                                            width: 1,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(4.0),
                                        ),
                                        child: Center(
                                          child: DropdownButton<String>(
                                            value: finalValueType,
                                            underline: Container(
                                              height: 0,
                                            ),
                                            onChanged: (String? newValue) {
                                              setState(() {
                                                finalValueType = newValue!;
                                              });
                                            },
                                            items: valueTypes
                                                .map<DropdownMenuItem<String>>(
                                                    (String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 4.0),
                                    Flexible(
                                      child: TextField(
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                          decimal: true,
                                          signed: false,
                                        ),
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                        ),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              _amountValidator),
                                        ],
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          height: 1.0,
                                        ),
                                        onChanged: ((value) => {
                                              setState(() {
                                                finalValue = value;
                                              })
                                            }),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8.0),
                        ButtonWidget(
                          text: "Agregar",
                          onPressed: () {
                            setState(() {
                              double value = double.parse(finalValue!);
                              finalExpenses.add(
                                Expense.fromMenu(
                                  "Final",
                                  finalReason!,
                                  finalValueType,
                                  value,
                                ),
                              );
                              finalTotal += value;
                            });
                          },
                        ),
                        Container(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: [
                                DataColumn(label: Text('Index')),
                                DataColumn(label: Text('Motivo')),
                                DataColumn(label: Text('Valor')),
                                DataColumn(label: Text('Tipo')),
                                DataColumn(label: Text('Acciones')),
                              ],
                              rows: finalExpenses.map((e) {
                                int index = finalExpenses.indexOf(e);
                                return DataRow(cells: [
                                  DataCell(Text((index + 1).toString())),
                                  DataCell(Text(e.reason)),
                                  DataCell(Text(e.value.toString())),
                                  DataCell(Text(e.valueType)),
                                  DataCell(
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () {
                                        setState(() {
                                          finalTotal -= e.value;
                                          finalExpenses.remove(e);
                                        });
                                      },
                                    ),
                                  ),
                                ]);
                              }).toList(),
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          child: Text(
                            finalTotal.toStringAsFixed(2),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            ButtonWidget(
              text: 'Add',
              onPressed: (() {
                Bill bill = Bill.fromMenu(
                  emissionDate!,
                  dueDate!,
                  double.parse(nominalValue!),
                  initialTotal,
                  finalTotal,
                  initialExpenses,
                  finalExpenses,
                  rateType,
                  rateTerm,
                  double.parse(rateValue!) / 100,
                  rateDays,
                  int.parse(daysPerYear),
                );
                setState(() {
                  bills.add(bill);
                });
              }),
            ),
            SizedBox(height: 16.0),
            Container(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('N')),
                    DataColumn(label: Text('Valor Nominal')),
                    DataColumn(label: Text('Fecha de Vencimiento')),
                    DataColumn(label: Text('N. de Dias')),
                    DataColumn(label: Text('TEP (i`)')),
                    DataColumn(label: Text('d')),
                    DataColumn(label: Text('Descuentos')),
                    DataColumn(label: Text('Costos Iniciales')),
                    DataColumn(label: Text('Costos Finales')),
                    DataColumn(label: Text('Valor Neto')),
                    DataColumn(label: Text('Valor a Recibir')),
                    DataColumn(label: Text('Flujo')),
                    DataColumn(label: Text('TCEA')),
                  ],
                  rows: bills.map((e) {
                    int index = bills.indexOf(e);
                    return DataRow(cells: [
                      DataCell(Text((index + 1).toString())),
                      DataCell(Text(e.nominalValue.toStringAsFixed(2))),
                      DataCell(
                          Text(e.emissionDate.toString().substring(0, 10))),
                      DataCell(Text(e.days.toString())),
                      DataCell(Text(
                          "${(e.interestRate * 100).toStringAsFixed(3)}%")),
                      DataCell(Text(
                          "${(e.discountRate * 100).toStringAsFixed(3)}%")),
                      DataCell(Text(e.discount.toStringAsFixed(2))),
                      DataCell(Text(e.initialTotal.toStringAsFixed(2))),
                      DataCell(Text(e.finalTotal.toStringAsFixed(2))),
                      DataCell(Text(e.netWorth.toStringAsFixed(2))),
                      DataCell(Text(e.valueToReceive.toStringAsFixed(2))),
                      DataCell(Text(e.cashFlow.toStringAsFixed(2))),
                      DataCell(Text(
                          "${(e.currentTCEARate * 100).toStringAsFixed(4)}%")),
                      // DataCell(
                      //   IconButton(
                      //     icon: Icon(Icons.delete),
                      //     onPressed: () {
                      //       setState(() {
                      //         finalTotal -= e.value;
                      //         finalExpenses.remove(e);
                      //       });
                      //     },
                      //   ),
                      // ),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
