import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:salarymanager/models/Item.dart';
import 'package:salarymanager/models/Work.dart';
import 'package:salarymanager/providers/EmployeeProvider.dart';
import 'package:salarymanager/providers/UserDataProvider.dart';
import 'package:salarymanager/providers/WorkProvider.dart';

class AddWorkBottomSheet extends StatefulWidget {
  final String sheetType;

  AddWorkBottomSheet({this.sheetType = 'Work'});

  @override
  _AddWorkBottomSheetState createState() => _AddWorkBottomSheetState();
}

class _AddWorkBottomSheetState extends State<AddWorkBottomSheet> {
  String _currentValue;
  WorkProvider workProvider;
  EmployeeProvider employeeProvider;
  UserDataProvider userDataProvider;
  Work _work;
  int advance;
  OverlayEntry _overlayEntry;
  FocusNode _focusNode;
  LayerLink _layerLink;
  TextEditingController _itemNameTEC;
  bool isPickedFromItemList = false;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<Item> items;

  @override
  void initState() {
    _currentValue = widget.sheetType;
    workProvider = Provider.of<WorkProvider>(context, listen: false);
    employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
    userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    userDataProvider.getUserData();
    _work = Work(itemId: '', rate: 0, quantity: 0);
    _focusNode = FocusNode()..addListener(focusListener);
    _layerLink = LayerLink();
    _itemNameTEC = TextEditingController();

    super.initState();
  }

  focusListener() {
    if (_focusNode.hasFocus) {
      this._overlayEntry =
          this.createOverlay(MediaQuery.of(context).viewInsets.bottom);
      Overlay.of(context).insert(this._overlayEntry);
    } else {
      this._overlayEntry?.remove();
    }
  }

  @override
  Widget build(BuildContext context) {
    print('items: ${userDataProvider.items}');
    return Form(
      key: _formKey,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          children: [
            _radioButtonRow(),
            _currentValue == 'Work'
                ? _workTextFieldColumn()
                : _advanceTextField(),
            _saveButton(),
            SizedBox(
              height: MediaQuery.of(context).viewInsets.bottom,
            )
          ],
        ),
      ),
    );
  }

  Widget _radioButtonRow() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: RadioListTile(
                title: Text('Work'),
                value: 'Work',
                groupValue: _currentValue,
                onChanged: (value) {
                  setState(() {
                    _currentValue = value;
                  });
                }),
          ),
          Flexible(
            child: RadioListTile(
                title: Text('Advance'),
                value: 'Advance',
                groupValue: _currentValue,
                onChanged: (value) {
                  setState(() {
                    _currentValue = value;
                  });
                }),
          ),
        ],
      );

  Widget _workTextFieldColumn() => Column(
        children: [
          CompositedTransformTarget(
            link: _layerLink,
            child: TextFormField(
              autofocus: true,
              focusNode: this._focusNode,
              controller: _itemNameTEC,
              validator: (text) {
                return text.isEmpty ? 'Please select an item' : null;
              },
              onChanged: (text) {
                isPickedFromItemList = false;
                userDataProvider.getItemSearch(text);
              },
              decoration: InputDecoration(
                  labelText: 'Item Name',
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8))),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              children: [
                Flexible(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    validator: (text) {
                      return text.isEmpty ? 'Please enter rate' : null;
                    },
                    inputFormatters: [
                      WhitelistingTextInputFormatter(RegExp('[\\d.]'))
                    ],
                    onChanged: (text) {
                      _work.rate = double.parse(text.trim());
                    },
                    decoration: InputDecoration(
                        labelText: 'Item Rate',
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8))),
                  ),
                ),
                Container(
                  width: 25,
                ),
                Flexible(
                  child: TextFormField(
                    keyboardType: TextInputType.numberWithOptions(
                        decimal: false, signed: false),
                    validator: (text) {
                      return text.isEmpty ? 'Please enter quantity' : null;
                    },
                    inputFormatters: [
                      WhitelistingTextInputFormatter(RegExp('[\\d]'))
                    ],
                    onChanged: (text) {
                      _work.quantity = int.parse(text);
                    },
                    decoration: InputDecoration(
                        labelText: 'Item Quantity',
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8))),
                  ),
                ),
              ],
            ),
          )
        ],
      );

  Widget _advanceTextField() => TextFormField(
        controller: TextEditingController(
            text: workProvider.dayWork.advance.toString()),
        autofocus: true,
        keyboardType:
            TextInputType.numberWithOptions(decimal: false, signed: false),
        inputFormatters: [WhitelistingTextInputFormatter(RegExp('[\\d]'))],
        onChanged: (text) {
          advance = text.isNotEmpty ? int.parse(text) : null;
        },
        decoration: InputDecoration(
            labelText: 'Advance',
            border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
                borderRadius: BorderRadius.circular(8))),
      );

  Widget _saveButton() => SizedBox(
        width: double.infinity,
        child: RaisedButton(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Text(
            'Save',
            style: Theme.of(context)
                .textTheme
                .bodyText2
                .copyWith(color: Colors.white),
          ),
          onPressed: () {
            FormState _formState = _formKey.currentState;
            if ((_formState.validate() && isPickedFromItemList) ||
                _currentValue == 'Advance') {
              int tempAdv = advance;
              if (tempAdv != null) {
                tempAdv = tempAdv - workProvider.dayWork.advance;
                employeeProvider.updateAdvance(tempAdv);
              }
              workProvider.addWorkToDayWork(_work, advance);
              Navigator.of(context).pop();
            } else if (!isPickedFromItemList) {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        content: Text('Please select an item from the list'),
                        actions: [
                          RaisedButton(
                              child: Text('Ok'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              })
                        ],
                      ));
            }
          },
        ),
      );

  createOverlay(double adjDelta) {
    RenderBox renderBox = context.findRenderObject();
    Size size = renderBox.size;
    return OverlayEntry(builder: (context) {
      return Consumer<UserDataProvider>(
        builder: (BuildContext context, value, Widget child) {
          items = value.items;
          return items.isEmpty || MediaQuery.of(context).viewInsets.bottom == 0
              ? SizedBox.shrink()
              : Positioned(
                  width: size.width - 32,
                  child: CompositedTransformFollower(
                    link: _layerLink,
                    showWhenUnlinked: false,
                    offset: Offset(0.0, -size.height + 32 + adjDelta),
                    child: Material(
                      child: Card(
                        color: Colors.white,
                        child: Container(
                          constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(context).size.height / 3.5),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: ListView(
                              shrinkWrap: true,
                              reverse: true,
                              children: [
                                ...items
                                    .map((item) => ListTile(
                                          leading: CircleAvatar(
                                            child: item.image == null
                                                ? Text(
                                                    '${item.name[0]}',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText1
                                                        .copyWith(
                                                            color: Colors.white,
                                                            fontSize: 16),
                                                  )
                                                : null,
                                            backgroundImage: item.image != null
                                                ? NetworkImage('${item.image}')
                                                : null,
                                          ),
                                          title: Text('${item.name}'),
                                          onTap: () {
                                            isPickedFromItemList = true;
                                            _overlayEntry.remove();
                                            _work.item = item;
                                            _work.itemId = item.id;
                                            _itemNameTEC.text = item.name;
                                          },
                                        ))
                                    .toList()
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ));
        },
      );
    });
  }
}
