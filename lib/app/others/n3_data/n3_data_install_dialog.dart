import 'package:flutter/material.dart';
import 'package:novel_v3/app/routes.dart';
import 'n3_data.dart';
import 'package:t_widgets/t_widgets.dart';

import 'n3_data_worker.dart';

class N3DataInstallDialog extends StatefulWidget {
  N3Data n3data;
  bool isInstallConfigFiles;
  bool isInstallFileOverride;
  void Function()? onSuccess;
  N3DataInstallDialog({
    super.key,
    required this.n3data,
    this.onSuccess,
    this.isInstallConfigFiles = false,
    this.isInstallFileOverride = false,
  });

  @override
  State<N3DataInstallDialog> createState() => _N3DataInstallDialogState();
}

class _N3DataInstallDialogState extends State<N3DataInstallDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  void init() async {
    await N3DataWorker.install(
      n3Data: widget.n3data,
      isInstallFileOverride: widget.isInstallFileOverride,
      isInstallConfigFiles: widget.isInstallConfigFiles,
    );

    // await Future.delayed(Duration(seconds: 2));
    if (!mounted) return;
    closeContext(context);
    widget.onSuccess?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      scrollable: true,
      content: Column(
        spacing: 8,
        children: [
          Text('N3Data သွင်းနေပါတယ်...။\nပြီးသွားရင် အလိုအလျောက် ပိတ်ပါမယ်။'),
          Center(child: TLoaderRandom()),
        ],
      ),
    );
  }
}
