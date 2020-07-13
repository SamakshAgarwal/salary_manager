import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:salarymanager/models/Item.dart';
import 'package:salarymanager/providers/StorageProvider.dart';
import 'package:salarymanager/providers/UserDataProvider.dart';

class AddItemBottomSheet extends StatefulWidget {
  @override
  _AddItemBottomSheetState createState() => _AddItemBottomSheetState();
}

class _AddItemBottomSheetState extends State<AddItemBottomSheet> {
  List categories;
  Item _item;
  ImagePicker imagePicker;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  File _image;
  UserDataProvider userDataProvider;

  @override
  void initState() {
    _item = Item(id: '', name: '', image: '', category: ['All']);
    imagePicker = ImagePicker();
    userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
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
                _item.name = text;
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
                    categories = value.itemCategories;
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
                                    selected: _item.category.contains(category),
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
                                        _item.category.contains(category)
                                            ? _item.category.remove(category)
                                            : _item.category.add(category);
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
            SizedBox(
              width: double.infinity,
              child: Consumer<UserDataProvider>(
                builder: (BuildContext context, UserDataProvider value,
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
                      value.addItem(_item, _image);
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
