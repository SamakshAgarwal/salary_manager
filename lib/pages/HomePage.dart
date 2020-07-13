import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salarymanager/components/home/AddEmployeeBottomSheet.dart';
import 'package:salarymanager/components/itemsPage/AddItemBottomSheet.dart';
import 'package:salarymanager/main.dart';
import 'package:salarymanager/pages/EmployeesPage.dart';
import 'package:salarymanager/pages/ItemsPage.dart';
import 'package:salarymanager/providers/LoginProvider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isSearch = false;
  String currentPage = 'Employees';
  String searchText = '';

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    print('HomePage build');
    return Scaffold(
      appBar: AppBar(
        title: appBarWidget(),
        actions: [
          IconButton(
              icon: Icon(isSearch ? Icons.clear : Icons.search),
              onPressed: () {
                setState(() {
                  isSearch = !isSearch;
                });
              })
        ],
      ),
      drawer: Drawer(
        child: Consumer<LoginProvider>(
          builder: (BuildContext context, loginProvider, Widget child) {
            if (loginProvider.user == null) {
              loginProvider.getUser();
              return Center(
                child: CircularProgressIndicator(),
              );
            } else
              return ListView(
                children: [
                  UserAccountsDrawerHeader(
                    currentAccountPicture: CircleAvatar(
                      backgroundImage:
                          NetworkImage('${loginProvider.user.photoUrl}'),
                    ),
                    accountName: Text('${loginProvider.user.displayName}'),
                    accountEmail: Text('${loginProvider.user.email}'),
                    otherAccountsPictures: [
                      IconButton(
                          icon: Icon(
                            Icons.power_settings_new,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            loginProvider.signOut().then(
                                (value) => RestartWidget.restartApp(context));
                          })
                    ],
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.of(context).pop();
                      if (currentPage != 'Employees') {
                        setState(() {
                          currentPage = 'Employees';
                        });
                      }
                    },
                    title: Text(
                      'Employees',
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          .copyWith(color: Colors.deepPurple),
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.of(context).pop();
                      if (currentPage != 'Items') {
                        setState(() {
                          currentPage = 'Items';
                        });
                      }
                    },
                    title: Text(
                      'Items',
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          .copyWith(color: Colors.deepPurple),
                    ),
                  ),
                ],
              );
          },
        ),
      ),
      body: currentPage == 'Employees'
          ? EmployeesPage(
              searchText: searchText,
            )
          : ItemsPage(
              searchText: searchText,
            ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                )),
                builder: (context) => currentPage == 'Employees'
                    ? AddEmployeeBottomSheet()
                    : AddItemBottomSheet());
          }),
    );
  }

  appBarWidget() {
    return isSearch
        ? Container(
            height: 45,
            child: Center(
              child: TextField(
                autofocus: true,
                onChanged: searchList,
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    )),
              ),
            ),
          )
        : Text('$currentPage');
  }

  searchList(String text) {
    setState(() {
      searchText = text;
    });
  }
}
