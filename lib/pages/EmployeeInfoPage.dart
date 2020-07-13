import 'package:flutter/material.dart';

class EmployeeInfoPage extends StatefulWidget {
  @override
  _EmployeeInfoPageState createState() => _EmployeeInfoPageState();
}

class _EmployeeInfoPageState extends State<EmployeeInfoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Info'),
      ),
      body: Column(
        children: [
          Align(
              alignment: Alignment.center,
              child: CircleAvatar(
                radius: 48,
                child: Text(
                  'K',
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1
                      .copyWith(color: Colors.white, fontSize: 40),
                ),
                backgroundColor: Colors.red,
              )),
          Text(
            'Kartik',
            style: Theme.of(context).textTheme.headline4,
          ),
        ],
      ),
    );
  }
}
