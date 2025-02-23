import 'package:cherry_toast/cherry_toast.dart';
import 'package:flutter/material.dart';

void showMessage(BuildContext context, String msg) {
  CherryToast.success(
    inheritThemeColors: true,
    title: Text(msg),
  ).show(context);
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
