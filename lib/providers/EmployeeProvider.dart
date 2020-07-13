import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:salarymanager/models/Employee.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;
import 'package:salarymanager/models/Salary.dart';

class EmployeeProvider with ChangeNotifier {
  Firestore _firestore = Firestore.instance;
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  FirebaseUser user;
  List<Employee> _employees;
  FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  get employees => _employees;

  Employee _currentEmployee;

  set currentEmployee(Employee employee) => _currentEmployee = employee;

  Future<bool> getEmployees() async {
    print(_employees);
    if (user == null) user = await _firebaseAuth.currentUser();
    if (_employees == null)
      return await _firestore
          .collection('Users')
          .document(user.uid)
          .collection('Employees')
          .getDocuments()
          .then((value) {
        _employees = [
          ...value.documents.map((doc) {
            return Employee.fromJson(doc.data);
          }).toList()
        ];
        notifyListeners();
        return true;
      }).catchError((e) {
        print('getEmployees e: $e');
        notifyListeners();
        return false;
      });
  }

  Future<bool> updateAdvance(int advance) async {
    print('prov advance: $advance');
    _currentEmployee.totalAdvance += advance;
    print(_currentEmployee.toMap());
    return await _firestore
        .collection('Users')
        .document(user.uid)
        .collection('Employees')
        .document(_currentEmployee.id)
        .updateData(_currentEmployee.toMap())
        .then((value) {
      notifyListeners();
      return true;
    }).catchError((e) {
      notifyListeners();
      return false;
    });
  }

  Future<bool> addEmployee(Employee _newEmployee, File imageFile) async {
    if (user == null) user = await _firebaseAuth.currentUser();
    String imageUrl;

    DocumentReference empDocRef = _firestore
        .collection('Users')
        .document(user.uid)
        .collection('Employees')
        .document();
    _newEmployee.id = empDocRef.documentID;
    if (imageFile != null)
      imageUrl = await uploadImage(imageFile, _newEmployee.id);
    _newEmployee.image = imageUrl;
    return await empDocRef.setData(_newEmployee.toMap()).then((value) {
      _employees.add(_newEmployee);
      notifyListeners();
      return true;
    }).catchError((e) {
      print('addEmployee e: $e');
      deleteImage(_newEmployee.id);
      notifyListeners();
      return false;
    });
  }

  Future<bool> deleteEmployee(String _employeeId) async {
    if (user == null) user = await _firebaseAuth.currentUser();
    return await _firestore
        .collection('Users')
        .document(user.uid)
        .collection('Employees')
        .document('$_employeeId')
        .delete()
        .then((value) {
      deleteImage(_employeeId);
      _employees.removeWhere((element) => element.id == _employeeId);
      notifyListeners();
      return true;
    }).catchError((e) {
      notifyListeners();
      return false;
    });
  }

  Future<String> uploadImage(File file, String employeeId) async {
    print('Uploading');
    Uint8List imgIntList = await file.readAsBytes();
    img.Image image = img.decodeImage(imgIntList);
    image = img.copyResize(image, width: 128);
    Uint8List uploadableFile = img.encodeJpg(image, quality: 60);
    return await _firebaseStorage
        .ref()
        .child(user.uid)
        .child('Employees/$employeeId')
        .putData(uploadableFile)
        .onComplete
        .then((value) async {
      print('Uploaded');
      return await value.ref.getDownloadURL().then((value) {
        return value;
      });
    }).catchError((e) {
      print('uploadImage e: $e');
      return null;
    });
  }

  Future deleteImage(String employeeId) async {
    return await _firebaseStorage
        .ref()
        .child(user.uid)
        .child('Employees/$employeeId')
        .delete()
        .then((value) async {})
        .catchError((e) {
      print('deleteImage e: $e');
      return null;
    });
  }

  Future addSalary(Salary _newSalary) async {
    print('adding salary');
    return await _firestore
        .collection('Users')
        .document(user.uid)
        .collection('Employees')
        .document(_currentEmployee.id)
        .collection('Salary')
        .document('${_newSalary.initialDate}-${_newSalary.finalDate}')
        .setData(_newSalary.toMap())
        .then((value)async {
      await updateDeductedAdvance(_newSalary.advanceDeducted);
      print('success');
      notifyListeners();
      return true;
    }).catchError((e) {
      print('addSalary e: $e');
      notifyListeners();
      return false;
    });
  }

  Future  updateDeductedAdvance(int advanceDeducted) async {
    return await _firestore
        .collection('Users')
        .document(user.uid)
        .collection('Employees')
        .document(_currentEmployee.id)
        .updateData({
      'totalAdvance': (_currentEmployee.totalAdvance - advanceDeducted)
    }).then((value) {
      print('updated advance');
      return true;
    }).catchError((e) {
      print('updateDeductedAdvance');
      return false;
    });
  }
}
