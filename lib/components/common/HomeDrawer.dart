import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salarymanager/pages/HomePage.dart';
import 'package:salarymanager/pages/ItemsPage.dart';
import 'package:salarymanager/providers/LoginProvider.dart';

class HomeDrawer extends StatelessWidget {
  String currentPage;

  HomeDrawer({this.currentPage});

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
                          loginProvider.signOut();
                        })
                  ],
                ),
                ListTile(
                  onTap: () {
                    Navigator.of(context).pop();
                    if (currentPage != 'Employees') {
                      currentPage = 'Employees';
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (BuildContext context) => HomePage()));
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
                      currentPage = 'Items';
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (BuildContext context) => ItemsPage()));
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
    );
  }
}
