import 'package:flutter/material.dart';
import 'package:novel_v3/multi_app/multi_app.dart';
import 'package:novel_v3/multi_app/restart_widget.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

class MultiAppChooser extends StatefulWidget {
  const MultiAppChooser({super.key});

  @override
  State<MultiAppChooser> createState() => _MultiAppChooserState();
}

class _MultiAppChooserState extends State<MultiAppChooser> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  MultiAppType appValue = MultiAppType.oldApp;

  void init() {
    appValue = MultiApp.getConfigType();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              spacing: 3,
              children: [
                Text('Multi Apps'),
                DropdownButton<MultiAppType>(
                  padding: EdgeInsets.all(3),
                  borderRadius: BorderRadius.circular(3),
                  value: appValue,
                  items: MultiAppType.values
                      .map(
                        (e) => DropdownMenuItem<MultiAppType>(
                          value: e,
                          child: Text(e.name.toCaptalize()),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    appValue = value!;
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        ),
        MultiApp.getConfigType() != appValue
            ? TextButton(onPressed: _apply, child: Text('သိမ်းဆည်းမယ်'))
            : SizedBox.shrink(),
      ],
    );
  }

  void _apply() async {
    try {
      await TRecentDB.getInstance.putString(
        MultiApp.multiAppKey,
        appValue.name,
      );

      if (!mounted) return;
      RestartWidget.restartApp(context);
    } catch (e) {
      if (!mounted) return;
      showTMessageDialogError(context, e.toString());
    }
  }
}
