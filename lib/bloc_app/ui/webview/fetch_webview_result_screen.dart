import 'package:flutter/material.dart';

class FetchWebviewResultScreen extends StatelessWidget {
  final String result;
  const FetchWebviewResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Webview Resutl')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SelectableText(result),
        ),
      ),
    );
  }
}
