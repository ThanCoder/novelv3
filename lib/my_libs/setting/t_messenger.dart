import 'package:flutter/material.dart';

class TMessenger {
  static final TMessenger instance = TMessenger._();
  TMessenger._();
  factory TMessenger() => instance;

  void showMessage(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
    // CherryToast.success(
    //   title: Text(msg),
    //   inheritThemeColors: true,
    // ).show(context);
  }
  void showMessageWidget(BuildContext context, Widget text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: text,
      ),
    );
    // CherryToast.success(
    //   title: Text(msg),
    //   inheritThemeColors: true,
    // ).show(context);
  }

  void showDialogMessage(BuildContext context, String msg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        content: SelectableText(msg),
      ),
    );
  }

  void showDialogMessageWidget(BuildContext context, Widget child) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        content: child,
      ),
    );
  }
}
