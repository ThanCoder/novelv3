import 'package:flutter/material.dart';

void showMessage(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg),
    ),
  );
}

void showDialogMessage(BuildContext context, String msg) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      content: SingleChildScrollView(child: Text(msg)),
    ),
  );
}

void showDialogMessageWidget(BuildContext context, Widget child) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      content: child,
    ),
  );
}
