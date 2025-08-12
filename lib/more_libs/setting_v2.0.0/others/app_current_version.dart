import 'package:flutter/material.dart';
import 'package:than_pkg/than_pkg.dart';

class AppCurrentVersion extends StatelessWidget {
  const AppCurrentVersion({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ThanPkg.platform.getPackageInfo(),
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (snapshot.hasData && data != null) {
          return Card(
            child: ListTile(title: Text('Current Version: ${data.version}')),
          );
        }
        return SizedBox.shrink();
      },
    );
  }
}
