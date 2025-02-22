import 'package:flutter/material.dart';

class MyScaffold extends StatelessWidget {
  Widget body;
  Widget? floatingActionButton;
  AppBar? appBar;
  double contentPadding;
  Widget? drawer;
  Widget? endDrawer;
  Widget? bottomSheet;
  MyScaffold({
    super.key,
    required this.body,
    this.floatingActionButton,
    this.appBar,
    this.drawer,
    this.endDrawer,
    this.contentPadding = 8,
    this.bottomSheet,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      drawer: drawer,
      endDrawer: endDrawer,
      body: Padding(
        padding: EdgeInsets.all(contentPadding),
        child: body,
      ),
      floatingActionButton: floatingActionButton,
      bottomSheet: bottomSheet,
    );
  }
}
