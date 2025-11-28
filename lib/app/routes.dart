import 'package:flutter/material.dart';

void goRoute(
  BuildContext context, {
  required Widget Function(BuildContext context) builder,
}) {
  Navigator.push(context, MaterialPageRoute(builder: builder));
}

void closeContext(BuildContext context) {
  Navigator.pop(context);
}
