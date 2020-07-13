import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:salarymanager/models/DayWork.dart';
import 'package:salarymanager/models/Employee.dart';
import 'package:salarymanager/models/MonthWork.dart';
import 'package:salarymanager/models/Salary.dart';
import 'package:salarymanager/models/Work.dart';
import 'package:salarymanager/extensions/DateExtensions.dart';

class WorkProvider with ChangeNotifier {
  Firestore _firestore = Firestore.instance;
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  FirebaseUser user;

  Employee _currentEmployee;

  set currentEmployee(Employee employee) => _currentEmployee = employee;

  Employee get employee => _currentEmployee;

  List<MonthWork> _monthWorks = [];
  int monthWorkIndex;
  int dayWorkIndex;

  DayWork get dayWork => _monthWorks[monthWorkIndex].dayWorks[dayWorkIndex];

  getMonthWork(String month) async {
    int index = _monthWorks.indexWhere((element) =>
        element.month == month && element.employeeId == _currentEmployee.id);
    if (index == -1) {
      if (user == null) user = await _firebaseAuth.currentUser();
      await _firestore
          .collection('Users')
          .document(user.uid)
          .collection('Work')
          .where('employeeId', isEqualTo: _currentEmployee.id)
          .where('month', isEqualTo: month)
          .limit(1)
          .getDocuments()
          .then((value) {
        if (value.documents.isNotEmpty) {
          if (value.documents[0].data != null)
            _monthWorks.add(MonthWork.fromJson(value.documents[0].data));
        } else {
          DocumentReference docRef = _firestore
              .collection('Users')
              .document(user.uid)
              .collection('Work')
              .document();
          MonthWork _tempMonthWork = MonthWork(
              month: month,
              dayWorks: [],
              employeeId: _currentEmployee.id,
              id: docRef.documentID);
          _monthWorks.add(_tempMonthWork);
        }
        monthWorkIndex = _monthWorks.length - 1;
        notifyListeners();
      }).catchError((e) {
        print('getMonthWork e: $e');
        notifyListeners();
      });
      monthWorkIndex = _monthWorks.length - 1;
    } else {
      monthWorkIndex = index;
    }
  }

  Future getDayWork(String date) async {
    await getMonthWork(date.dateToMonth());
    int index = _monthWorks[monthWorkIndex]
        .dayWorks
        .indexWhere((element) => element.date == date);
    if (index == -1) {
      _monthWorks[monthWorkIndex].dayWorks.add(DayWork(
            date: date,
            works: [],
            isAbsent: false,
            advance: 0,
          ));
      dayWorkIndex = _monthWorks[monthWorkIndex].dayWorks.length - 1;
    } else {
      dayWorkIndex = index;
    }
    notifyListeners();
  }

  addWorkToDayWork(Work _newWork, int advance) {
    if (_newWork.item.name.isNotEmpty &&
        _newWork.rate != 0 &&
        _newWork.quantity != 0)
      _monthWorks[monthWorkIndex].dayWorks[dayWorkIndex].works.add(_newWork);
    if (advance != null) {
      _monthWorks[monthWorkIndex].monthAdvance -=
          _monthWorks[monthWorkIndex].dayWorks[dayWorkIndex].advance;
      _monthWorks[monthWorkIndex].dayWorks[dayWorkIndex].advance = advance;
      _monthWorks[monthWorkIndex].monthAdvance += advance;
    }
    notifyListeners();
  }

  Future<bool> saveWorkData() async {
    if (user == null) user = await _firebaseAuth.currentUser();
    WriteBatch writeBatch = _firestore.batch();
    _monthWorks.forEach((monthWork) {
      monthWork.absents = 0;
      monthWork.dayWorks.forEach((dayWork) {
        if (dayWork.isAbsent) monthWork.absents++;
      });
    });
    _monthWorks.forEach((monthWork) {
      DocumentReference docRef = _firestore
          .collection('Users')
          .document(user.uid)
          .collection('Work')
          .document(monthWork.id);
      writeBatch.setData(docRef, monthWork.toMap());
    });
    return await writeBatch.commit().then((value) {
      return true;
    }).catchError((e) {
      return false;
    });
  }

  Salary _salary;

  Salary get salary => _salary;

  calculateSalary(
      DateTime initialDate, DateTime finalDate, int advanceToDeduct) async {
    _salary = null;
    double sal = 0;
    int absents = 0;
    finalDate = finalDate.add(Duration(days: 1));
    for (var i = initialDate;
        i.difference(finalDate) != Duration(days: 0);
        i = i.add(Duration(days: 1))) {
      await getDayWork(i.formatDate());
      _monthWorks[monthWorkIndex].dayWorks[dayWorkIndex].works.forEach((work) {
        sal += (work.quantity * work.rate);
      });
      if (_monthWorks[monthWorkIndex].dayWorks[dayWorkIndex].isAbsent)
        absents++;
    }
    finalDate = finalDate.subtract(Duration(days: 1));
    sal -= advanceToDeduct;
    _salary = Salary(
        employeeId: _currentEmployee.id,
        amount: sal.round(),
        advanceDeducted: advanceToDeduct,
        initialDate: initialDate.formatDate(),
        finalDate: finalDate.formatDate(),
        absents: absents);
    notifyListeners();
  }
}
