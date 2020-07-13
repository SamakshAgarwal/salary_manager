import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:salarymanager/contants/colors.dart';
import 'package:salarymanager/models/Employee.dart';
import 'package:salarymanager/models/Salary.dart';
import 'package:salarymanager/models/Work.dart';
import 'package:salarymanager/providers/EmployeeProvider.dart';
import 'package:salarymanager/providers/WorkProvider.dart';

class SalaryPage extends StatefulWidget {
  SalaryPage();

  @override
  _SalaryPageState createState() => _SalaryPageState();
}

class _SalaryPageState extends State<SalaryPage> {
  WorkProvider workProvider;
  EmployeeProvider employeeProvider;
  Salary salary;
  Employee employee;

  @override
  void initState() {
    workProvider = Provider.of<WorkProvider>(context, listen: false);
    employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
    salary = workProvider.salary;
    employee = workProvider.employee;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Consumer<WorkProvider>(
          builder: (BuildContext context, value, Widget child) {
            salary = workProvider.salary;
            if (salary == null)
              return Center(child: CircularProgressIndicator());
            else
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      CircleAvatar(
                        radius: 56,
                        child: employee.image == null
                            ? Text(
                                '${employee.name[0]}',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline2
                                    .copyWith(color: Colors.white),
                              )
                            : null,
                        backgroundImage: employee.image != null
                            ? NetworkImage(employee.image)
                            : null,
                        backgroundColor: portraitColors[
                            (((employee.name.codeUnitAt(0) - 65) / 26) *
                                        portraitColors.length)
                                    .round() -
                                1],
                      ),
                      Text('${employee.name}',
                          style: Theme.of(context).textTheme.headline4),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Date',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6
                                  .copyWith(fontWeight: FontWeight.normal),
                            ),
                            Text(
                              '${salary.initialDate} - ${salary.finalDate}',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6
                                  .copyWith(fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Card(
                            margin: EdgeInsets.all(8),
                            color: Colors.redAccent,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical:8.0,horizontal: 16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    'Absents',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline6
                                        .copyWith(
                                            fontWeight: FontWeight.normal,
                                            color: Colors.white),
                                  ),
                                  Text(
                                    '${salary.absents}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline6
                                        .copyWith(
                                            fontWeight: FontWeight.normal,
                                            color: Colors.white),
                                  )
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: height / 3.5,
                            child: Card(
                              margin: EdgeInsets.all(8),
                              elevation: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Total Salary',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline6
                                              .copyWith(
                                                  fontWeight: FontWeight.normal,
                                                  color: Colors.black54),
                                        ),
                                        Text(
                                          '₹${salary.amount + salary.advanceDeducted}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline6
                                              .copyWith(
                                                  fontWeight: FontWeight.normal,
                                                  color: Colors.black54),
                                        )
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Advance Deducted',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline6
                                              .copyWith(
                                                  fontWeight: FontWeight.normal,
                                                  color: Colors.orange),
                                        ),
                                        Text(
                                          '- ₹${salary.advanceDeducted}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline6
                                              .copyWith(
                                                  fontWeight: FontWeight.normal,
                                                  color: Colors.orange),
                                        )
                                      ],
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(top: 16),
                                      decoration: BoxDecoration(
                                          border: Border(
                                              top: BorderSide(
                                                  color: Colors.grey))),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Final Amount',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline6
                                                .apply(fontSizeFactor: 1.1),
                                          ),
                                          Text(
                                            '${salary.amount < 0 ? '- ' : ''}₹${salary.amount.abs()}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline6
                                                .apply(fontSizeFactor: 1.1),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                          margin: EdgeInsets.only(top: 16),
                          width: width - 16,
                          child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              child: Text(
                                'Save',
                                style: Theme.of(context)
                                    .textTheme
                                    .button
                                    .copyWith(color: Colors.white),
                              ),
                              onPressed: () {
                                employeeProvider.addSalary(salary);
                              })),
                    ],
                  ),
                ],
              );
          },
        ),
      ),
    );
  }
}
