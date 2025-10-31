import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:than_pkg/than_pkg.dart';

class GetstartScreen extends StatefulWidget {
  final Widget child;
  const GetstartScreen({super.key, required this.child});

  @override
  State<GetstartScreen> createState() => _GetstartScreenState();
}

class _GetstartScreenState extends State<GetstartScreen>
    with WidgetsBindingObserver {
  bool isStoragePermissionGranted = false;
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      init();
      // ➜ onResume လိုသုံးနိုင်တယ်
    }
  }

  void init() async {
    try {
      isStoragePermissionGranted = await ThanPkg.platform
          .isStoragePermissionGranted();
      setState(() {});
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final readGetstart = TRecentDB.getInstance.getBool('read-getstart');
    if (readGetstart) {
      return widget.child;
    }
    return Scaffold(
      appBar: AppBar(title: Text('Get Start')),
      body: ListView(
        children: [_getStoragePermission(), Divider(), _getChangeLog()],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 18, 62, 100),
              ),
              onPressed: () {
                TRecentDB.getInstance.putBool('read-getstart', true);
                setState(() {});
              },
              child: Text('Next'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getStoragePermission() {
    return SwitchListTile.adaptive(
      title: Text('Storage Permission'),
      // subtitle: Text('သင်က'),
      value: isStoragePermissionGranted,
      onChanged: (value) {
        ThanPkg.android.permission.requestStoragePermission();
      },
    );
  }

  Widget _getChangeLog() {
    return ExpansionTile(
      title: Text('Change Log'),
      subtitle: Text('ပြောင်းလဲမှုများ'),
      children: [
        FutureBuilder(
          future: rootBundle.loadString('CHANGELOG.md'),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Text('Loading....');
            return Markdown(data: snapshot.data ?? '', shrinkWrap: true);
          },
        ),
      ],
    );
  }
}
