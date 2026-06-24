import 'package:flutter/material.dart';
import 'package:novel_v3/modules/module_manager.dart';

class AnotherPageModule extends ModuleApp<void, String> {
  @override
  Future<String?> go(BuildContext context, void params) async {
    final res = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => AnotherPage()),
    );
    return res;
  }

  @override
  // TODO: implement moduleId
  String get id => throw UnimplementedError();
}

class AnotherPage extends StatelessWidget {
  const AnotherPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, 'i am another page result');
      },
      child: Scaffold(
        appBar: AppBar(title: Text('Another Title')),
        body: Center(child: Text('Another Page')),
      ),
    );
  }
}
