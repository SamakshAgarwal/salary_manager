import 'dart:convert';

class Salary {
  String employeeId;
  int amount;
  int advanceDeducted;
  String initialDate;
  String finalDate;
  int absents;

  Salary(
      {this.employeeId,
      this.amount,
      this.initialDate,
      this.finalDate,
      this.advanceDeducted,
      this.absents});

  factory Salary.fromJson(Map<String, dynamic> json) {
    return Salary(
      employeeId: json['employeeId'],
      amount: json['amount'],
      advanceDeducted: json['advanceDeducted'],
      initialDate: json['initialDate'],
      finalDate: json['finalDate'],
      absents: json['absents'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'employeeId': employeeId,
      'amount': amount,
      'advanceDeducted': advanceDeducted,
      'initialDate': initialDate,
      'finalDate': finalDate,
      'absents': absents,
    };
  }
}
