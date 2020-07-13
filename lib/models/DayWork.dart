import 'package:flutter/cupertino.dart';

import 'Work.dart';

class DayWork {
  String date;
  List<Work> works;
  bool isAbsent;
  int advance;

  DayWork(
      {@required this.date,
      @required this.works,
      @required this.isAbsent,
      @required this.advance});

  factory DayWork.fromJson(Map<String, dynamic> json) {
    return DayWork(
        date: json['date'],
        works: <Work>[
          ...json['works'].map((work) {
            return Work.fromJson(work);
          }).toList()
        ],
        isAbsent: json['isAbsent'],
        advance: json['advance']);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'date': date,
      'works': [...works.map((work) => work.toMap()).toList()],
      'isAbsent': isAbsent,
      'advance': advance
    };
  }
}
