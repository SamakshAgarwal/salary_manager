import 'package:flutter/cupertino.dart';

import 'Item.dart';

class Work {
  String itemId;
  double rate;
  int quantity;
  Item item;

  Work({
    @required this.itemId,
    @required this.rate,
    @required this.quantity,
  });

  factory Work.fromJson(Map<String, dynamic> json) {
    return Work(
        itemId: json['itemId'],
        rate: json['rate'],
        quantity: json['quantity']);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'itemId': itemId,
      'rate': rate,
      'quantity': quantity,
    };
  }
}
