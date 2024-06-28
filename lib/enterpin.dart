import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:pinput/pinput.dart';
import 'package:uas_ambw_c14210048/notes.dart';

class EnterPin extends StatefulWidget {
  const EnterPin({super.key});

  @override
  State<EnterPin> createState() => _EnterPinState();
}

class _EnterPinState extends State<EnterPin> {
  final TextEditingController _enterPinController = TextEditingController();
  final TextEditingController _createPinController = TextEditingController();
  final TextEditingController _oldPinController = TextEditingController();
  final TextEditingController _newPinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();

  late Box pinBox;
  String? userPin;

  @override
  void initState() {
    super.initState();
    pinBox = Hive.box('pin');
    userPin = pinBox.get('pin');
    print('userpin: ${userPin}');

    if (userPin == null) {
      Future.microtask(() => _createPin());
    }
  }

  void _createPin() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            height: 250.0,
            width: MediaQuery.of(context).size.width * 0.8,
            padding: EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Create New PIN',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                SizedBox(height: 20.0),
                Pinput(
                  length: 4,
                  controller: _createPinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    String pin = _createPinController.text;
                    if (pin.length == 4) {
                      pinBox.put('pin', pin);
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Berhasil membuat PIN!')),
                      );
                      print('created pin: ${pin}');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('PIN harus terdiri dari 4 digit!')),
                      );
                    }
                  },
                  child: Text('Submit'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _checkPin() {
    String userPin = pinBox!.get('pin');
    if (_enterPinController.text == userPin) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => MyNotes(),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PIN salah')),
      );
    }
  }

  void _editPin() {
    _enterPinController.clear();
    _oldPinController.clear();
    _newPinController.clear();
    _confirmPinController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit PIN'),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Old PIN'),
                Pinput(
                  length: 4,
                  controller: _oldPinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),
                Text('New PIN'),
                Pinput(
                  length: 4,
                  controller: _newPinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),
                Text('Confirm New PIN'),
                Pinput(
                  length: 4,
                  controller: _confirmPinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          contentPadding: EdgeInsets.all(10),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String userPin = pinBox!.get('pin');
                if (_oldPinController.text.length == 4 &&
                    _newPinController.text.length == 4 &&
                    _confirmPinController.text.length == 4) {
                  if (_oldPinController.text == userPin) {
                    if (_newPinController.text == _confirmPinController.text) {
                      pinBox.put('pin', _newPinController.text);
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('PIN berhasil diperbarui!'),
                        ),
                      );
                      print('updated pin: ${_newPinController.text}');
                    } else {
                      FocusScope.of(context).unfocus();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('PIN baru yang diinput tidak sama!'),
                        ),
                      );
                    }
                  } else {
                    FocusScope.of(context).unfocus();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('PIN lama salah!'),
                      ),
                    );
                  }
                } else {
                  FocusScope.of(context).unfocus();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Semua PIN harus 4 digit!'),
                    ),
                  );
                }
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter PIN'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Pinput(
              length: 4,
              controller: _enterPinController,
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkPin,
              child: Text('Submit'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _editPin,
              child: Text('Edit PIN'),
            ),
          ],
        ),
      ),
    );
  }
}
