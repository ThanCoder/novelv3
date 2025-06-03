import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:t_widgets/t_widgets.dart';

import '../index.dart';
import 'package:flutter/material.dart';

class RawPage extends StatelessWidget {
  String rawName;
  ReleaseAppModel releaseApp;
  RawPage({
    super.key,
    required this.rawName,
    required this.releaseApp,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: GeneralServices.instance.getRawLog(
        rawName: rawName,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return TLoader();
        }
        if (snapshot.hasError) {
          return Text('error: ${snapshot.error}');
        }
        if (snapshot.hasData) {
          return Markdown(data: snapshot.data ?? '');
        }

        return const SizedBox.shrink();
      },
    );
  }
}
