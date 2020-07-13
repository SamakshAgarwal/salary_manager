import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:salarymanager/models/Employee.dart';
import 'package:salarymanager/providers/EmployeeProvider.dart';
import 'package:salarymanager/providers/StorageProvider.dart';
import 'package:salarymanager/providers/UserDataProvider.dart';

class AddEmployeeBottomSheet extends StatefulWidget {
  @override
  _AddEmployeeBottomSheetState createState() => _AddEmployeeBottomSheetState();
}

class _AddEmployeeBottomSheetState extends State<AddEmployeeBottomSheet> {
  List categories;
  Employee _employee;
  ImagePicker imagePicker;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  File _image;

  @override
  void initState() {
    _employee =
        Employee(name: '', category: ['All'], image: null, totalAdvance: 0);
    imagePicker = ImagePicker();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Form(
      key: _formKey,
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: GestureDetector(
                onTap: () {
                  pickImage();
                },
                child: CircleAvatar(
                  radius: 48,
                  child: Icon(Icons.camera_alt),
                  backgroundImage: _image == null ? null : FileImage(_image),
                ),
              ),
            ),
            TextFormField(
              autofocus: true,
              onChanged: (text) {
                _employee.name = text;
              },
              validator: (text) {
                return text.isEmpty ? 'Enter name' : null;
              },
              decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8))),
            ),
            SizedBox(
              width: width,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Consumer(
                  builder: (BuildContext context, UserDataProvider value,
                      Widget child) {
                    categories = value.employeeCategories;
                    return Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ...categories
                            .sublist(1)
                            .map((category) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: FilterChip(
                                    selected:
                                        _employee.category.contains(category),
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    selectedColor: Colors.deepPurple,
                                    checkmarkColor: Colors.white,
                                    label: Text(
                                      '$category',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2
                                          .copyWith(color: Colors.white),
                                    ),
                                    onSelected: (bool value) {
                                      setState(() {
                                        _employee.category.contains(category)
                                            ? _employee.category
                                                .remove(category)
                                            : _employee.category.add(category);
                                      });
                                    },
                                  ),
                                ))
                            .toList()
                      ],
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: TextFormField(
                controller: TextEditingController(text: '0'),
                autofocus: true,
                keyboardType: TextInputType.number,
                onChanged: (text) {
                  _employee.totalAdvance = int.parse(text);
                },
                inputFormatters: [
                  WhitelistingTextInputFormatter(RegExp('[\\d]'))
                ],
                decoration: InputDecoration(
                    labelText: 'Advance',
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8))),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Consumer<EmployeeProvider>(
                builder: (BuildContext context, EmployeeProvider value,
                        Widget child) =>
                    RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    'Save',
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .copyWith(color: Colors.white),
                  ),
                  onPressed: () {
                    FormState formState = _formKey.currentState;
                    if (_image != null) StorageProvider().uploadImage(_image);
                    if (formState.validate()) {
                      value.addEmployee(_employee, _image);
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).viewInsets.bottom,
            )
          ],
        ),
      ),
    );
  }

  Future pickImage() async {
    await imagePicker
        .getImage(source: ImageSource.gallery)
        .then((pickedImagePath) {
      print(pickedImagePath.path);
      setState(() {
        _image = File(pickedImagePath.path);
      });
    });
  }
}
