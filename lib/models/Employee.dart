import 'dart:convert';

import 'package:flutter/foundation.dart';

class Employee {
  String id;
  String name;
  String image;
  List<String> category;
  int totalAdvance;

  Employee(
      {@required this.name, @required this.category, @required this.image,@required this.totalAdvance});

  factory Employee.fromJson(Map<String, dynamic> json) {
    Employee _temp = Employee(
      name: json['name'],
      category: <String>[...json['category'].toList()],
      image: json['image'],
      totalAdvance:json['totalAdvance']
    );
    _temp.id = json['id'];
    return _temp;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'image': image,
      'category': category,
      'totalAdvance':totalAdvance
    };
  }
}
