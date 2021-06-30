import 'package:fipro/models.dart/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fipro/providers/auth_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:fipro/widgets/logo_widget.dart';
import 'package:fipro/widgets/header_button_widget.dart';
import 'package:fipro/widgets/title_widget.dart';
import 'package:fipro/widgets/subtitle_widget.dart';
import 'package:fipro/widgets/label_widget.dart';
import 'package:fipro/widgets/toast_widget.dart';
import 'package:fipro/widgets/button_widget.dart';
import 'package:fipro/widgets/loading_widget.dart';

import 'package:fipro/services/database_service.dart';
import 'package:fipro/services/settings_service.dart';

import 'package:fipro/models.dart/expense.dart';
import 'package:fipro/models.dart/bill.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DatabaseService _databaseService = DatabaseService();
  FToast fToast = FToast();
  AuthProvider? auth;
  Settings settings = Settings.init();

  bool loading = false;

  DateTime? discountDate;
  DateTime? dueDate;
  DateTime? billDate;

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

  double valueToReceiveTotal = 0.0;

  //ToDo: XIRR/TIR

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

  String getDateText(DateTime? date) {
    if (date == null) {
      return 'Selecciona una fecha';
    } else {
      return DateFormat('MM/dd/yyyy').format(date);
    }
  }

  Future pickDiscountDate() async {
    final initialDate = DateTime.now();
    final newDate = await showDatePicker(
      context: context,
      initialDate: discountDate ?? initialDate,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 5),
    );

    if (newDate == null) return;

    setState(() => discountDate = newDate);
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

  Future pickBillDate() async {
    final initialDate = DateTime.now();
    final newDate = await showDatePicker(
      context: context,
      initialDate: billDate ?? initialDate,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 5),
    );

    if (newDate == null) return;

    setState(() => billDate = newDate);
  }

  _startLoading() {
    loading = true;
    fToast.removeQueuedCustomToasts();
    Widget toast = LoadingWidget();
    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 60),
    );
  }

  _stopLoading() {
    fToast.removeQueuedCustomToasts();
    loading = false;
  }

  _showToast(String message, [bool error = false]) {
    Widget toast = ToastWidget(message: message, error: error);
    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 2),
    );
  }

  Future<void> loadBills() async {
    try {
      List<Bill> loadedBills = await _databaseService.loadBills(auth!.uid);
      double loadedValueToReceive = 0.0;
      for (Bill bill in loadedBills) {
        loadedValueToReceive += bill.valueToReceive;
      }
      _stopLoading();
      setState(() {
        bills = loadedBills;
        valueToReceiveTotal = loadedValueToReceive;
      });
      _showToast('Cargado con exito');
    } on Error catch (e) {
      _showToast('Error al cargar, actualice la pagina', true);
    }
  }

  Future<void> addBill() async {
    if (loading) return;

    _startLoading();

    if (discountDate == null) {
      _stopLoading();
      _showToast('Seleccione una "Fecha de Descuento"', true);
      return;
    }

    if (dueDate == null) {
      _stopLoading();
      _showToast('Seleccione una "Fecha de Vencimiento"', true);
      return;
    }

    if (billDate == null) {
      _stopLoading();
      _showToast('Seleccione una "Fecha de Giro"', true);
      return;
    }

    if (nominalValue == null) {
      _stopLoading();
      _showToast('Agregue una "Valor Nominal"', true);
      return;
    }

    if (rateValue == null) {
      _stopLoading();
      _showToast('Agregue una "Tasa ${settings.rateType}"', true);
      return;
    }

    try {
      Bill bill = await _databaseService.createBill(
        auth!.uid,
        discountDate!,
        dueDate!,
        billDate!,
        double.parse(nominalValue!),
        initialTotal,
        finalTotal,
        initialExpenses,
        finalExpenses,
        settings.rateType,
        rateTerm,
        double.parse(rateValue!) / 100,
        rateDays,
        int.parse(daysPerYear),
      );

      _stopLoading();
      setState(() {
        bills.add(bill);
        valueToReceiveTotal += bill.valueToReceive;
        _showToast('Agregado con exito');
      });
    } on Error catch (e) {
      _stopLoading();
      _showToast('Error al agregar: $e', true);
    }
  }

  Future<void> deleteBill(Bill bill) async {
    if (loading) return;

    _startLoading();

    try {
      await _databaseService.deleteBill(bill.id);
      _stopLoading();
      setState(() {
        valueToReceiveTotal -= bill.valueToReceive;
        bills.remove(bill);
      });
      _showToast("Eliminado con exito");
    } on Error catch (e) {
      _stopLoading();
      _showToast('Error al eliminar: $e', true);
    }
  }

  Future<void> openSettings() async {
    var result =
        await SettingsService.displayDialogOKCallBack(context, settings);

    if (result != null) {
      setState(() {
        settings = result;
      });
    }
  }

  Future<void> logout() async {
    if (loading) return;

    _startLoading();

    try {
      AuthProvider auth = Provider.of<AuthProvider>(context, listen: false);
      await auth.signOut();
      _stopLoading();
      _showToast("Logout successful");
    } on FirebaseAuthException catch (e) {
      _stopLoading();
      _showToast(e.message.toString(), true);
    } on Error catch (e) {
      _stopLoading();
      _showToast(e.toString(), true);
    }
  }

  @override
  void initState() {
    super.initState();
    loading = false;
    auth = Provider.of<AuthProvider>(context, listen: false);
    fToast.init(context);
    loadBills();
  }

  @override
  void dispose() {
    super.dispose();
    loading = false;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double cardWidth = (width / 8) * 3;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80.0,
        title: LogoWidget(fontSize: 48, alternative: true),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          HeaderButton(
            title: 'Settings',
            onPressed: openSettings,
          ),
          HeaderButton(
            title: 'Logout',
            onPressed: logout,
          ),
        ],
      ),
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
                              LabelWidget(label: 'Fecha de Descuento'),
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
                                        getDateText(discountDate),
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      onPressed: () => pickDiscountDate(),
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
                                        getDateText(dueDate),
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
                              LabelWidget(label: 'Fecha de Giro'),
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
                                        getDateText(billDate),
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      onPressed: () => pickBillDate(),
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
                              LabelWidget(label: 'Tasa ${settings.rateType}'),
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
            SizedBox(height: 32.0),
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
                            "Gastos Iniciales: ${initialTotal.toStringAsFixed(2)}",
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
                            "Gastos Finales: ${finalTotal.toStringAsFixed(2)}",
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 32.0),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                child: Column(
                  children: [
                    SizedBox(height: 32.0),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 32.0),
                      child: ButtonWidget(
                        text: 'Agregar',
                        onPressed: addBill,
                      ),
                    ),
                    SizedBox(height: 32.0),
                    Container(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: DataTable(
                          columns: [
                            DataColumn(label: Text('N')),
                            DataColumn(label: Text('Fecha de Descuento')),
                            DataColumn(label: Text('Fecha de Giro')),
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
                            DataColumn(label: Text('Acciones')),
                          ],
                          rows: bills.map((e) {
                            int index = bills.indexOf(e);
                            return DataRow(cells: [
                              DataCell(Text((index + 1).toString())),
                              DataCell(Text(getDateText(e.discountDate))),
                              DataCell(Text(getDateText(e.billDate))),
                              DataCell(Text(e.nominalValue.toStringAsFixed(2))),
                              DataCell(Text(getDateText(e.dueDate))),
                              DataCell(Text(e.days.toString())),
                              DataCell(Text(
                                  "${(e.interestRate * 100).toStringAsFixed(3)}%")),
                              DataCell(Text(
                                  "${(e.discountRate * 100).toStringAsFixed(3)}%")),
                              DataCell(Text(e.discount.toStringAsFixed(2))),
                              DataCell(Text(e.initialTotal.toStringAsFixed(2))),
                              DataCell(Text(e.finalTotal.toStringAsFixed(2))),
                              DataCell(Text(e.netWorth.toStringAsFixed(2))),
                              DataCell(
                                  Text(e.valueToReceive.toStringAsFixed(2))),
                              DataCell(Text(e.cashFlow.toStringAsFixed(2))),
                              DataCell(Text(
                                  "${(e.currentTCEARate * 100).toStringAsFixed(4)}%")),
                              DataCell(
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () => deleteBill(e),
                                ),
                              ),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
                    SizedBox(height: 32.0),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 32.0),
                      width: double.infinity,
                      child: Text(
                        "Valor a Recibir: ${valueToReceiveTotal.toStringAsFixed(2)}",
                        textAlign: TextAlign.end,
                      ),
                    ),
                    SizedBox(height: 16.0),
                  ],
                ),
              ),
            ),
            SizedBox(height: 32.0),
          ],
        ),
      ),
    );
  }
}
