import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salarymanager/components/common/HomeDrawer.dart';
import 'package:salarymanager/components/home/AddEmployeeBottomSheet.dart';
import 'package:salarymanager/contants/colors.dart';
import 'package:salarymanager/models/Employee.dart';
import 'package:salarymanager/providers/EmployeeProvider.dart';
import 'package:salarymanager/providers/LoginProvider.dart';
import 'package:salarymanager/providers/UserDataProvider.dart';
import 'package:salarymanager/providers/WorkProvider.dart';

import 'EmployeeInfoPage.dart';
import 'WorkPage.dart';

class EmployeesPage extends StatefulWidget {
  final String searchText;

  EmployeesPage({@required this.searchText});

  @override
  _EmployeesPageState createState() => _EmployeesPageState();
}

class _EmployeesPageState extends State<EmployeesPage> {
  List categories;
  List<Employee> employees, tempEmployees;
  String _currentCategory;
  bool isSearch = false;
  EmployeeProvider employeeProvider;
  WorkProvider workProvider;
  UserDataProvider userDataProvider;
  LoginProvider loginProvider;
  TextEditingController categoryTEC;

  void initState() {
    employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
    employeeProvider.getEmployees();
    workProvider = Provider.of<WorkProvider>(context, listen: false);
    userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    userDataProvider.getUserData();
    categories = userDataProvider.employeeCategories;
    _currentCategory = categories[0];
    loginProvider = Provider.of<LoginProvider>(context, listen: false);
    loginProvider.getUser();
    categories = userDataProvider.employeeCategories;
    tempEmployees = employees;
    categoryTEC = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Consumer<EmployeeProvider>(
      builder: (BuildContext context, value, Widget child) {
        employees = value.employees;
        if (tempEmployees == null) tempEmployees = employees;
        if (employees == null) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          searchList();
          return Consumer<UserDataProvider>(
            builder:
                (BuildContext context, UserDataProvider udProv, Widget child) {
              categories = udProv.employeeCategories;
              if (categories == null) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return Container(
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          height: 40,
                          child: DropdownButton(
                            value: _currentCategory,
                            items: [
                              ...categories
                                  .map((category) => DropdownMenuItem(
                                      value: category,
                                      child: Text(
                                        '$category',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2,
                                      )))
                                  .toList(),
                              DropdownMenuItem(
                                  child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                  showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                            title: Text('New Category'),
                                            content: TextField(
                                              controller: categoryTEC,
                                              decoration: InputDecoration(
                                                  labelText: 'Category',
                                                  border: OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.grey),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8))),
                                            ),
                                            actions: [
                                              OutlineButton(
                                                  child: Text(
                                                    'Cancel',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .button
                                                        .copyWith(
                                                            color: Colors
                                                                .deepPurple),
                                                  ),
                                                  borderSide: BorderSide(
                                                      color: Colors.deepPurple),
                                                  onPressed: () {
                                                    categoryTEC.clear();
                                                    Navigator.of(context).pop();
                                                  }),
                                              RaisedButton(
                                                  child: Text('Save'),
                                                  onPressed: () {
                                                    if (categoryTEC
                                                        .text.isNotEmpty) {
                                                      userDataProvider
                                                          .addEmployeeCategory(
                                                              categoryTEC.text);
                                                      categoryTEC.clear();
                                                      Navigator.of(context)
                                                          .pop();
                                                    }
                                                  })
                                            ],
                                          ));
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border(
                                          top: BorderSide(color: Colors.grey))),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Add',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2,
                                      ),
                                      Icon(Icons.add)
                                    ],
                                  ),
                                ),
                              ))
                            ],
                            onChanged: (value) {
                              if (categories.contains(value)) filterList(value);
                            },
                            underline: Container(),
                          ),
                        ),
                      ),
                      Flexible(
                        child: ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            itemCount: tempEmployees.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Card(
                                child: ListTile(
                                  leading: CircleAvatar(
                                    child: tempEmployees[index].image == null
                                        ? Text(
                                            '${tempEmployees[index].name[0]}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText1
                                                .copyWith(
                                                    color: Colors.white,
                                                    fontSize: 16),
                                          )
                                        : null,
                                    backgroundImage:
                                        tempEmployees[index].image != null
                                            ? NetworkImage(
                                                '${tempEmployees[index].image}')
                                            : null,
                                    backgroundColor: portraitColors[
                                        (((tempEmployees[index]
                                                            .name
                                                            .codeUnitAt(0) -
                                                        65) /
                                                    26) *
                                                (portraitColors.length - 1))
                                            .round()],
                                  ),
                                  title: Text(
                                    '${tempEmployees[index].name}',
                                    style:
                                        Theme.of(context).textTheme.headline6,
                                  ),
                                  subtitle: Text(
                                    'Advance: ₹${tempEmployees[index].totalAdvance}',
                                  ),
                                  trailing: IconButton(
                                      icon: Icon(Icons.info_outline),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    EmployeeInfoPage()));
                                      }),
                                  onTap: () {
                                    workProvider.currentEmployee =
                                        employees[index];
                                    employeeProvider.currentEmployee =
                                        employees[index];
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) => WorkPage()));
                                  },
                                  onLongPress: () {
                                    showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (context) => AlertDialog(
                                              title: Text('Delete Employee'),
                                              content: Text('Are you sure?'),
                                              actions: [
                                                RaisedButton(
                                                  child: Text('No'),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                                OutlineButton(
                                                  child: Text(
                                                    'Yes',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .button
                                                        .copyWith(
                                                            color: Colors
                                                                .deepPurple),
                                                  ),
                                                  borderSide: BorderSide(
                                                      color: Colors.deepPurple),
                                                  onPressed: () {
                                                    value.deleteEmployee(
                                                        tempEmployees[index]
                                                            .id);
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            ));
                                  },
                                ),
                              );
                            }),
                      )
                    ],
                  ),
                );
              }
            },
          );
        }
      },
    );
  }

  filterList(value) {
    setState(() {
      tempEmployees = employees.toList();
      tempEmployees.retainWhere((element) => element.category.contains(value));
      _currentCategory = value;
    });
  }

  searchList() {
    tempEmployees = employees.toList();
    tempEmployees
        .retainWhere((element) => element.category.contains(_currentCategory));
    tempEmployees.retainWhere((element) =>
        element.name.toLowerCase().contains(widget.searchText.toLowerCase()));
  }
}
