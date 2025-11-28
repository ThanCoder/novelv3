import 'package:flutter/material.dart';
import 'package:novel_v3/app/others/n3_data/n3_data_scanner_screen.dart';
import 'package:novel_v3/app/routes.dart';

class OtherAppListTile extends StatelessWidget {
  const OtherAppListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            Text('Other Apps', style: TextStyle(fontSize: 17)),

            ListTile(
              title: Text('N3 Data Scanner'),
              onTap: () {
                goRoute(context, builder: (context) => N3DataScannerScreen());
              },
            ),
          ],
        ),
      ),
    );
  }
}
