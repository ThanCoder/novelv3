import 'package:flutter/material.dart';
import 'package:novel_v3/app/share/share_host_chooser_dialog.dart';
import 'package:novel_v3/app/share/share_receive_screen.dart';
import 'package:novel_v3/app/share/share_send_screen.dart';
import 'package:novel_v3/app/widgets/index.dart';

class ShareHomeScreen extends StatefulWidget {
  const ShareHomeScreen({super.key});

  @override
  State<ShareHomeScreen> createState() => _ShareHomeScreenState();
}

class _ShareHomeScreenState extends State<ShareHomeScreen> {
  void _goReceive() async {
    showDialog(
      context: context,
      builder: (context) => ShareHostChooserDialog(
        onApply: (url) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ShareReceiveScreen(url: url),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      appBar: AppBar(
        title: const Text('Share Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    IconButton(
                      iconSize: 70,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ShareSendScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.send_rounded),
                    ),
                    const Text('Send'),
                  ],
                ),
              ),
            ),
            //receive
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    IconButton(
                      iconSize: 70,
                      onPressed: () {
                        _goReceive();
                      },
                      icon: const Icon(Icons.download_rounded),
                    ),
                    const Text('Receive'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
