import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:salarymanager/models/Item.dart';
import 'package:image/image.dart' as img;

class UserDataProvider with ChangeNotifier {
  Firestore _firestore = Firestore.instance;
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  FirebaseUser user;

  List<String> _employeeCategories = ['All'];
  List<String> _itemCategories = ['All'];
  List<Item> _items;

  List<String> get employeeCategories => _employeeCategories;

  List<String> get itemCategories => _itemCategories;

  List<Item> get items => _searchItems;

  Future<bool> getUserData() async {
    if (user == null) user = await _firebaseAuth.currentUser();
    if (_items == null) {
      return await _firestore
          .collection('Users')
          .document(user.uid)
          .collection('UserData')
          .document('UserData')
          .get()
          .then((value) {
        if (value.data != null) {
          _employeeCategories = [
            'All',
            if (value.data.containsKey('EmployeeCategories'))
              ...value.data['EmployeeCategories'].toList()
          ];
          _itemCategories = [
            'All',
            if (value.data.containsKey('ItemCategories'))
              ...value.data['ItemCategories'].toList()
          ];
          _items = [
            if (value.data.containsKey('Items'))
              ...value.data['Items'].map((item) {
                return Item.fromJson(item);
              }).toList()
          ];
        } else {
          _items = [];
        }
        _searchItems = _items;
        notifyListeners();
        return true;
      }).catchError((e) {
        print('getUserData e: $e');
        notifyListeners();
        return false;
      });
    }
  }

  addEmployeeCategory(String _newCategory) async {
    if (user == null) user = await _firebaseAuth.currentUser();
    _employeeCategories.add(_newCategory);
    await _firestore
        .collection('Users')
        .document(user.uid)
        .collection('UserData')
        .document('UserData')
        .setData({'EmployeeCategories': _employeeCategories.sublist(1)},
            merge: true).then((value) {
      notifyListeners();
      return true;
    }).catchError((e) {
      print('addEmployeeCategory e: $e');
      notifyListeners();
      return false;
    });
  }

  addItemCategory(String _newCategory) async {
    if (user == null) user = await _firebaseAuth.currentUser();
    _employeeCategories.add(_newCategory);
    await _firestore
        .collection('Users')
        .document(user.uid)
        .collection('UserData')
        .document('UserData')
        .setData({'ItemCategories': _employeeCategories.sublist(1)},
            merge: true).then((value) {
      notifyListeners();
      return true;
    }).catchError((e) {
      print('addItemCategory e: $e');
      notifyListeners();
      return false;
    });
  }

  addItem(Item _newItem, File imageFile) async {
    if (user == null) user = await _firebaseAuth.currentUser();
    String imageUrl;
    DocumentReference docRef = _firestore
        .collection('Users')
        .document(user.uid)
        .collection('UserData')
        .document();
    if (imageFile != null)
      imageUrl = await uploadImage(imageFile, docRef.documentID);
    _newItem.image = imageUrl;
    _newItem.id = docRef.documentID;
    await _firestore
        .collection('Users')
        .document(user.uid)
        .collection('UserData')
        .document('UserData')
        .setData({
      'Items': _items.map((item) {
        return item.toMap();
      }).toList()
    }, merge: true).then((value) {
      _items.add(_newItem);
      notifyListeners();
      return true;
    }).catchError((e) {
      notifyListeners();
      deleteImage(_newItem.id);
      print('addItem e: $e');
      return false;
    });
  }

  deleteItem(String itemId) async {
    _items.removeWhere((element) => element.id == itemId);
    return await _firestore
        .collection('Users')
        .document(user.uid)
        .collection('UserData')
        .document('UserData')
        .setData({
      'Items': _items.map((item) {
        return item.toMap();
      }).toList()
    }, merge: true).then((value) {
      notifyListeners();
      deleteImage(itemId);
      return true;
    }).catchError((e) {
      print('addItem e: $e');
      notifyListeners();
      return false;
    });
  }

  List<Item> _searchItems;

  getItemSearch(String searchText) {
    print(searchText);
    _searchItems = _items.toList();
    _searchItems.retainWhere((element) =>
        element.name.toLowerCase().contains(searchText.toLowerCase()));
    print(_searchItems);
    notifyListeners();
  }

  Future<String> uploadImage(File file, String itemId) async {
    Uint8List imgIntList = await file.readAsBytes();
    img.Image image = img.decodeImage(imgIntList);
    image = img.copyResize(image, width: 128);
    Uint8List uploadableFile = img.encodeJpg(image, quality: 60);
    return await _firebaseStorage
        .ref()
        .child(user.uid)
        .child('Items/$itemId')
        .putData(uploadableFile)
        .onComplete
        .then((value) async {
      return await value.ref.getDownloadURL().then((value) {
        return value;
      });
    }).catchError((e) {
      print('uploadImage e: $e');
      return null;
    });
  }

  Future deleteImage(String itemId) async {
    return await _firebaseStorage
        .ref()
        .child(user.uid)
        .child('Items/$itemId')
        .delete()
        .then((value) async {})
        .catchError((e) {
      print('deleteImage e: $e');
      return null;
    });
  }
}
