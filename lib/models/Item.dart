import 'package:flutter/foundation.dart';

class Item {
  String id;
  String name;
  String image;
  List<String> category;

  Item(
      {@required this.id,
      @required this.name,
      @required this.image,
      @required this.category});

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      category: <String>[...json['category'].toList()],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'category': category,
    };
  }
}
