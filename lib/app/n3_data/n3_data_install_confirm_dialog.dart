import 'package:flutter/material.dart';
import 'package:novel_v3/app/n3_data/n3_data.dart';

class N3DataInstallConfirmDialog extends StatefulWidget {
  N3Data n3data;
  void Function(bool isInstallConfigFiles, bool isInstallFileOverride)
  onInstall;
  N3DataInstallConfirmDialog({
    super.key,
    required this.n3data,
    required this.onInstall,
  });

  @override
  State<N3DataInstallConfirmDialog> createState() =>
      _N3DataInstallConfirmDialogState();
}

class _N3DataInstallConfirmDialogState
    extends State<N3DataInstallConfirmDialog> {
  bool isInstallConfigFiles = false;
  bool isInstallFileOverride = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      title: Text('Install N3Data'),
      scrollable: true,
      content: Column(
        children: [
          SwitchListTile.adaptive(
            title: Text('Install Config Files'),
            subtitle: Text(
              'အရင် user မှတ်သားထားသော config file များ',
              style: TextStyle(fontSize: 13),
            ),
            value: isInstallConfigFiles,
            onChanged: (value) {
              setState(() {
                isInstallConfigFiles = value;
              });
            },
          ),
          SwitchListTile.adaptive(
            title: Text('Install Files Override'),
            subtitle: Text(
              'Novel ထဲမှာတူညီတဲ့ files တွေနေပြီးသားဆိုရင် မသွင်းပဲကျော်သွားမယ်',
              style: TextStyle(fontSize: 13),
            ),
            value: isInstallFileOverride,
            onChanged: (value) {
              setState(() {
                isInstallFileOverride = value;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('မလုပ်တော့ပါ'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            widget.onInstall(isInstallConfigFiles, isInstallFileOverride);
          },
          child: Text('သွင်းမယ်'),
        ),
      ],
    );
  }
}
