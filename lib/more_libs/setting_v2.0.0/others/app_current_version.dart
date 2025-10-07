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
            child: ListTile(
              leading: Icon(Icons.new_releases),
              title: Text('Current Version: `${data.version}`'),
            ),
          );
        }
        return SizedBox.shrink();
      },
    );
  }
}
