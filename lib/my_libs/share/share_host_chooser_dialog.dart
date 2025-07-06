import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novel_v3/app/components/core/app_components.dart';
import 'package:novel_v3/app/constants.dart';
import 'package:novel_v3/app/setting/app_notifier.dart';
import 'package:novel_v3/app/services/index.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

class ShareHostChooserDialog extends StatefulWidget {
  void Function(String url) onApply;
  ShareHostChooserDialog({super.key, required this.onApply});

  @override
  State<ShareHostChooserDialog> createState() => _ShareHostChooserDialogState();
}

class _ShareHostChooserDialogState extends State<ShareHostChooserDialog> {
  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    hostController.dispose();
    portController.dispose();
    super.dispose();
  }

  List<String> wifiList = [];
  final hostController = TextEditingController();
  final portController = TextEditingController();

  void init() async {
    try {
      portController.text = '$serverPort';

      wifiList = await ThanPkg.platform.getWifiAddressList();
      if (wifiList.isNotEmpty) {
        hostController.text = wifiList.first;
      }
      // recent
      final recent = appWififHostAddressNotifier.value;
      if (recent.isNotEmpty) {
        // hostController.text = recent;
        _checkUrlAndGo(recent);
      }
      setState(() {});
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _checkUrlAndGo(String url) async {
    try {
      await DioServices.instance.getDio.get(url);

      appWififHostAddressNotifier.value = url;

      if (!mounted) return;
      Navigator.pop(context);
      widget.onApply(url);
    } catch (e) {
      if (!mounted) return;
      debugPrint(e.toString());
      showDialogMessage(context,
          'ချိတ်ဆက်လို့ မရနိုင်ပါ!။\nhost && port ကို ပြန်စစ်ဆေးပေးပါ။');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      content: Column(
        spacing: 5,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TTextField(
            controller: hostController,
            label: const Text('Connnect Host Address'),
            onSubmitted: (value) => _checkUrlAndGo(
                'http://${hostController.text}:${portController.text}'),
          ),
          TTextField(
            controller: portController,
            label: const Text('PORT'),
            textInputType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLines: 1,
          ),
          const Divider(),
          const Text('ရနိုင်သော Wifi List'),
          ...List.generate(
            wifiList.length,
            (index) {
              final url = wifiList[index];
              return ListTile(
                title: Text(url),
                onTap: () {
                  hostController.text = url;
                },
              );
            },
          )
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Close'),
        ),
        TextButton(
          onPressed: () {
            if (hostController.text.isEmpty) return;
            _checkUrlAndGo(
                'http://${hostController.text}:${portController.text}');
          },
          child: const Text('Check'),
        ),
      ],
    );
  }
}
