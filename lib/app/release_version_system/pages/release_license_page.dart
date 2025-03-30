import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:t_release/services/t_release_services.dart';

import '../../widgets/core/index.dart';

class ReleaseLicensePage extends StatelessWidget {
  const ReleaseLicensePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: TReleaseServices.instance.getLicense(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return TLoader();
        }
        if (snapshot.hasData) {
          return Markdown(data: snapshot.data ?? '');
        }
        return SizedBox.shrink();
      },
    );
  }
}
