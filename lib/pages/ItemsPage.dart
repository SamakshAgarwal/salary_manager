import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salarymanager/components/common/HomeDrawer.dart';
import 'package:salarymanager/contants/colors.dart';
import 'package:salarymanager/models/Item.dart';
import 'package:salarymanager/providers/EmployeeProvider.dart';
import 'package:salarymanager/providers/UserDataProvider.dart';

class ItemsPage extends StatefulWidget {
  final String searchText;

  ItemsPage({@required this.searchText});

  @override
  _ItemsPageState createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  List categories = ['All'];
  List<Item> items, tempItems;
  String _currentCategory = 'All';
  bool isSearch = false;
  TextEditingController categoryTEC;

  @override
  void initState() {
    categoryTEC = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Consumer<UserDataProvider>(
      builder: (BuildContext context, value, Widget child) {
        items = value.items;
        categories = value.itemCategories;
        if (tempItems == null) tempItems = items;
        if (items == null) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          searchList();
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
                                  style: Theme.of(context).textTheme.bodyText2,
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
                                                    BorderRadius.circular(8))),
                                      ),
                                      actions: [
                                        OutlineButton(
                                            child: Text(
                                              'Cancel',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .button
                                                  .copyWith(
                                                      color: Colors.deepPurple),
                                            ),
                                            borderSide: BorderSide(
                                                color: Colors.deepPurple),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            }),
                                        RaisedButton(
                                            child: Text('Save'),
                                            onPressed: () {
                                              if (categoryTEC.text.isNotEmpty) {
//                                                userDataProvider.addCategory(
//                                                    categoryTEC.text);
//                                                Navigator.of(context).pop();
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Add',
                                  style: Theme.of(context).textTheme.bodyText2,
                                ),
                                Icon(Icons.add)
                              ],
                            ),
                          ),
                        ))
                      ],
                      onChanged: (value) {
//                        if (categories.contains(value)) filterList(value);
                      },
                      underline: Container(),
                    ),
                  ),
                ),
                Flexible(
                  child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      itemCount: tempItems.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              child: tempItems[index].image == null
                                  ? Text(
                                      '${tempItems[index].name[0]}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1
                                          .copyWith(
                                              color: Colors.white,
                                              fontSize: 16),
                                    )
                                  : null,
                              backgroundImage: tempItems[index].image != null
                                  ? NetworkImage('${tempItems[index].image}')
                                  : null,
                              backgroundColor: portraitColors[
                                  (((tempItems[index].name.codeUnitAt(0) - 65) /
                                              26) *
                                          portraitColors.length)
                                      .round()],
                            ),
                            title: Text(
                              '${tempItems[index].name}',
                              style: Theme.of(context).textTheme.headline6,
                            ),
                            trailing: IconButton(
                                icon: Icon(Icons.info_outline),
                                onPressed: () {}),
                            onTap: () {},
                            onLongPress: () {
                              showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        title: Text('Delete Item'),
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
                                                      color: Colors.deepPurple),
                                            ),
                                            borderSide: BorderSide(
                                                color: Colors.deepPurple),
                                            onPressed: () {
                                              value.deleteItem(
                                                  tempItems[index].id);
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

  searchList() {
    tempItems = items.toList();
//    tempItems
//        .retainWhere((element) => element.category.contains(_currentCategory));
    tempItems.retainWhere((element) =>
        element.name.toLowerCase().contains(widget.searchText.toLowerCase()));
  }
}
