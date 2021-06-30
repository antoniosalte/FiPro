import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:fipro/models.dart/bill.dart';
import 'package:fipro/models.dart/expense.dart';
import 'package:fipro/models.dart/rate.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Bill>> loadBills(String uid) async {
    List<Bill> bills = [];

    QuerySnapshot query = await _firestore
        .collection('bills')
        .where('userId', isEqualTo: uid)
        .get();

    for (DocumentSnapshot document in query.docs) {
      Map data = document.data() as Map<String, dynamic>;

      List<Expense> initialExpenses = [];
      List<Expense> finalExpenses = [];

      List<dynamic> initialExpensesMap = data['initialExpenses'];
      List<dynamic> finalExpensesMap = data['initialExpenses'];

      initialExpensesMap.forEach((element) {
        Expense expense = Expense.fromMap(element);
        initialExpenses.add(expense);
      });

      finalExpensesMap.forEach((element) {
        Expense expense = Expense.fromMap(element);
        finalExpenses.add(expense);
      });

      Rate rate = Rate.fromMap(data['rate']);
      Rate tcea = Rate.fromMap(data['tcea']);

      Bill bill = Bill.fromFirestore(
        data['id'],
        data['userId'],
        data['discountDate'].toDate(),
        data['dueDate'].toDate(),
        data['billDate'].toDate(),
        data['nominalValue'],
        data['initialTotal'],
        data['finalTotal'],
        initialExpenses,
        finalExpenses,
        data['days'],
        data['interestRate'],
        data['discountRate'],
        data['discount'],
        data['netWorth'],
        data['valueToReceive'],
        data['cashFlow'],
        data['currentTCEARate'],
        rate,
        tcea,
      );

      bills.add(bill);
    }

    return bills;
  }

  Future<Bill> createBill(
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
  ) async {
    DocumentReference documentReference = _firestore.collection('bills').doc();

    Bill bill = Bill.createToFirestore(
        documentReference.id,
        userId,
        discountDate,
        dueDate,
        billDate,
        nominalValue,
        initialTotal,
        finalTotal,
        initialExpenses,
        finalExpenses,
        rateType,
        rateTerm,
        rateValue,
        rateDays,
        daysPerYear);

    await documentReference.set(bill.toFirestore());

    return bill;
  }

  Future<void> deleteBill(String billId) async {
    await _firestore.collection('bills').doc(billId).delete();
  }
}
