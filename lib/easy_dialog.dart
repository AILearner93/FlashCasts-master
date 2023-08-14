import 'package:flutter/material.dart';

class EasyDialog {
  simpleDialog(
      {required BuildContext context,
      required String title,
      required String description}) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: Text(description),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).primaryColor,
                  ),
                  child: Text('Close')),
            ],
          );
        });
  }
}
