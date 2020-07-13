import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salarymanager/components/work/AddWorkBottomSheet.dart';
import 'package:salarymanager/contants/colors.dart';
import 'package:salarymanager/models/DayWork.dart';
import 'package:intl/intl.dart';
import 'package:date_range_picker/date_range_picker.dart' as dateRangePicker;
import 'package:salarymanager/pages/SalaryPage.dart';
import 'package:salarymanager/providers/UserDataProvider.dart';
import 'package:salarymanager/providers/WorkProvider.dart';
import 'package:salarymanager/extensions/DateExtensions.dart';

class WorkPage extends StatefulWidget {
  @override
  _WorkPageState createState() => _WorkPageState();
}

class _WorkPageState extends State<WorkPage> {
  DateTime _currentDate;
  TextEditingController advanceToDeductTEC;
  bool isAbsent = false;
  WorkProvider workProvider;
  UserDataProvider userDataProvider;
  DayWork dayWork;

  @override
  void initState() {
    workProvider = Provider.of<WorkProvider>(context, listen: false);
    userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    _currentDate = DateTime.now();
    advanceToDeductTEC = TextEditingController();
    getTodaysWork();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${workProvider.employee.name}'),
        actions: [
          InkWell(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Center(
                child: Text(
                  '+ ₹',
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2
                      .copyWith(color: Colors.white, fontSize: 22),
                ),
              ),
            ),
            onTap: () {
              dateRangePicker
                  .showDatePicker(
                      context: context,
                      initialFirstDate: DateTime.utc(
                          DateTime.now().year, DateTime.now().month, 1),
                      initialLastDate: DateTime.utc(
                              DateTime.now().year, DateTime.now().month + 1, 1)
                          .subtract(Duration(days: 1)),
                      firstDate: DateTime.utc(2019),
                      lastDate: DateTime.utc(2030))
                  .then((dateTimeList) => dateTimeList != null
                      ? showDialog(
                          context: context,
                          builder: (context) =>
                              _advnanceAlertDialog(dateTimeList))
                      : null);
            },
          )
        ],
      ),
      body: Consumer<WorkProvider>(
        builder: (BuildContext context, value, Widget child) {
          if (dayWork == null)
            return Center(
              child: CircularProgressIndicator(),
            );
          else {
//            dayWork = workProvider.dayWork;
            return Stack(
              children: [
                if (dayWork.isAbsent)
                  Center(
                    child: Image.asset(
                      'assets/sleep2.webp',
                      height: MediaQuery.of(context).size.height / 2,
                      width: MediaQuery.of(context).size.width / 2,
                    ),
                  ),
                GestureDetector(
                  onPanEnd: (dragDetails) {
                    if (dragDetails.velocity.pixelsPerSecond.dx > 0)
                      setState(() {
                        _currentDate = _currentDate.subtract(Duration(days: 1));
                        getTodaysWork();
                      });
                    else
                      setState(() {
                        _currentDate = _currentDate.add(Duration(days: 1));
                        getTodaysWork();
                      });
                  },
                  child: ListView.builder(
                      padding: EdgeInsets.all(8),
                      itemCount:
                          dayWork.isAbsent ? 2 : dayWork.works.length + 3,
                      itemBuilder: (BuildContext context, int index) {
                        if (index == 0)
                          return _dateRow();
                        else if (index == 1) {
                          return _absentRow();
                        } else if (index == 2) {
                          return _advanceRow();
                        } else {
                          index = index - 3;
                          return _workRow(index);
                        }
                      }),
                ),
                _saveButton(),
              ],
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
              isScrollControlled: true,
              context: context,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              )),
              builder: (context) => AddWorkBottomSheet());
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _advnanceAlertDialog(List<DateTime> dateTimeList) => AlertDialog(
        title: Text('Advance to deduct'),
        content: TextField(
          autofocus: true,
          controller: advanceToDeductTEC,
          decoration: InputDecoration(
              labelText: 'Amount',
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8))),
        ),
        actions: [
          RaisedButton(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            child: Text(
              'Proceed',
              style: Theme.of(context)
                  .textTheme
                  .bodyText2
                  .copyWith(color: Colors.white),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              workProvider.calculateSalary(dateTimeList[0], dateTimeList[1],
                  int.parse(advanceToDeductTEC.text.trim()));
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SalaryPage(),
                ),
              );
            },
          ),
        ],
      );

  Widget _dateRow() => Padding(
        padding: const EdgeInsets.only(right: 8.0, top: 8),
        child: GestureDetector(
          onTap: () {
            showDatePicker(
                    context: context,
                    initialDate: _currentDate,
                    firstDate: DateTime.utc(2019),
                    lastDate: DateTime.utc(2030))
                .then((value) {
              setState(() {
                _currentDate = value ?? _currentDate;
                getTodaysWork();
              });
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '${DateFormat.yMMMd().format(_currentDate)}',
                style: Theme.of(context)
                    .textTheme
                    .bodyText2
                    .copyWith(fontSize: 16),
              ),
              SizedBox(
                width: 5,
              ),
              const Icon(
                Icons.calendar_today,
              ),
            ],
          ),
        ),
      );

  Widget _absentRow() => Card(
        color: Color(0xFFB00020),
        margin: EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: ListTile(
            title: Text(
              'Absent',
              style: Theme.of(context)
                  .textTheme
                  .headline6
                  .copyWith(color: Colors.white),
            ),
            trailing: Theme(
              data: Theme.of(context).copyWith(
                  unselectedWidgetColor: Colors.white,
                  toggleableActiveColor: Colors.white),
              child: Checkbox(
                  checkColor: Color(0xFFB00020),
                  value: dayWork.isAbsent,
                  onChanged: (value) {
                    setState(() {
                      dayWork.isAbsent = !dayWork.isAbsent;
                    });
                  }),
            )),
      );

  Widget _advanceRow() => Card(
        color: Colors.orange,
        child: ListTile(
            onTap: () {
              showModalBottomSheet(
                  isScrollControlled: true,
                  context: context,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  )),
                  builder: (context) => AddWorkBottomSheet(
                        sheetType: 'Advance',
                      ));
            },
            title: Text(
              'Advance',
              style: Theme.of(context)
                  .textTheme
                  .headline6
                  .copyWith(color: Colors.white),
            ),
            trailing: Text(
              '₹${dayWork.advance}',
              style: Theme.of(context)
                  .textTheme
                  .bodyText2
                  .copyWith(fontSize: 18, color: Colors.white),
            )),
      );

  Widget _workRow(int index) => Card(
        child: ListTile(
          leading: CircleAvatar(
            child: dayWork.works[index].item.image == null
                ? Text(
                    '${dayWork.works[index].item.name[0]}',
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1
                        .copyWith(color: Colors.white, fontSize: 16),
                  )
                : null,
            backgroundImage: dayWork.works[index].item.image != null
                ? NetworkImage(dayWork.works[index].item.image)
                : null,
            backgroundColor: portraitColors[
                (((dayWork.works[index].item.name.codeUnitAt(0) - 65) / 26) *
                        (portraitColors.length - 1))
                    .round()],
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dayWork.works[index].item.name,
                style: Theme.of(context).textTheme.headline6,
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 70,
                  child: Text(
                    '${dayWork.works[index].quantity}',
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .copyWith(fontSize: 18),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text('x'),
                ),
                SizedBox(
                  width: 70,
                  child: Text(
                    '₹${dayWork.works[index].rate}',
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .copyWith(fontSize: 18),
                  ),
                ),
                Text('='),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '₹${(dayWork.works[index].rate * dayWork.works[index].quantity).round()}',
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2
                          .copyWith(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
          onLongPress: () {
            showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) => AlertDialog(
                      title: Text('Delete Work'),
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
                                .copyWith(color: Colors.deepPurple),
                          ),
                          borderSide: BorderSide(color: Colors.deepPurple),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ));
          },
        ),
      );

  Widget _saveButton() => Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16),
          child: SizedBox(
              width: MediaQuery.of(context).size.width - 100,
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
                    workProvider.saveWorkData();
                  })),
        ),
      );

  getTodaysWork() {
    workProvider.getDayWork(_currentDate.formatDate()).then((value) {
      dayWork = workProvider.dayWork;
      dayWork.works.forEach((work) {
        work.item =
            userDataProvider.items.firstWhere((item) => item.id == work.itemId);
      });
    });
  }
}
