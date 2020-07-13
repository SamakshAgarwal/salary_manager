import 'package:flutter/foundation.dart';
import 'package:salarymanager/models/DayWork.dart';

class MonthWork {
  String month;
  List<DayWork> dayWorks;
  int absents;
  int monthAdvance;
  String employeeId;
  String id;

  MonthWork(
      {@required this.month,
      @required this.dayWorks,
      @required this.employeeId,
      @required this.id}) {
    absents = 0;
    monthAdvance = 0;
    dayWorks.forEach((element) {
      if (element.isAbsent) absents++;
    });
    dayWorks.forEach((element) {
      monthAdvance = monthAdvance + element.advance;
    });
  }

  factory MonthWork.fromJson(Map<String, dynamic> json) {
    return MonthWork(
      month: json['month'],
      dayWorks: <DayWork>[
        ...json['dayWorks'].map((dayWork) {
          return DayWork.fromJson(dayWork);
        }).toList(),
      ],
      employeeId: json['employeeId'],
      id: json['id'],
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'month': month,
      'dayWorks': [...dayWorks.map((dayWork) => dayWork.toMap()).toList()],
      'absents': absents,
      'monthAdvance': monthAdvance,
      'employeeId': employeeId,
      'id': id
    };
  }
}
