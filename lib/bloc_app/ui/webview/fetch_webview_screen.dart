import 'package:flutter/material.dart';
import 'package:novel_v3/bloc_app/ui/webview/fetch_webview_result_screen.dart';
import 'package:novel_v3/core/extensions/build_context_extensions.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:webview_all/webview_all.dart';

class FetchWebviewScreen extends StatefulWidget {
  final String? url;
  final void Function()? onClosed;
  final void Function(String resultHtml)? onResult;
  const FetchWebviewScreen({super.key, this.url, this.onResult, this.onClosed});

  @override
  State<FetchWebviewScreen> createState() => _FetchWebviewScreenState();
}

class _FetchWebviewScreenState extends State<FetchWebviewScreen> {
  final controller = WebViewController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  @override
  void dispose() {
    widget.onClosed?.call();
    super.dispose();
  }

  bool isLoading = false;
  double? progress;
  String url = 'https://flutter.dev';

  Future<void> init() async {
    if (widget.url != null) {
      url = widget.url!;
    }
    controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    controller.setOnJavaScriptAlertDialog(
      (request) async =>
          JavaScriptAlertDialogRequest(message: 'message', url: url),
    );
    controller.enableZoom(true);
    controller.setVerticalScrollBarEnabled(true);
    controller.setNavigationDelegate(
      NavigationDelegate(
        onProgress: (progress) {
          // print('progress: $progress');
          this.progress = (progress / 100);
          if (!mounted) return;
          setState(() {});
        },
        onPageStarted: (url) {
          if (!mounted) return;
          setState(() {
            isLoading = true;
          });
        },
        onPageFinished: (url) {
          // print('onPageFinished: $url');
          if (!mounted) return;
          setState(() {
            isLoading = false;
          });
        },
      ),
    );
    controller.addJavaScriptChannel(
      'DomHandler',
      onMessageReceived: (msg) {
        context.closeNavigator();
        widget.onResult?.call(msg.message);
      },
    );
    controller.addJavaScriptChannel(
      'DomHandlerResult',
      onMessageReceived: (msg) {
        context.goRoute(
          builder: (context) => FetchWebviewResultScreen(result: msg.message),
        );
      },
    );
    _load();
  }

  void _load() async {
    //https://hostednovel.com/novel/im-really-not-the-demon-gods-lackey/chapter-20
    //https://flutter.dev

    try {
      await controller.loadRequest(Uri.parse(url));

      // controller.runJavaScript(javaScript)
    } catch (e) {
      if (!mounted) return;
      showTMessageDialogError(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fetch Webview'),
        actions: [
          if (!isLoading)
            IconButton(
              onPressed: () {
                controller.reload();
              },
              icon: Icon(Icons.refresh),
            ),

          IconButton(
            onPressed: _fetch,
            icon: Icon(Icons.file_download_outlined),
          ),
          TextButton(onPressed: _fetchResult, child: Text('Fetch Result')),
          IconButton(onPressed: _showSettingMenu, icon: Icon(Icons.settings)),
        ],
        flexibleSpace: !isLoading
            ? null
            : LinearProgressIndicator(value: progress),
      ),
      body: WebViewWidget(controller: controller),
    );
  }

  void _fetch() async {
    try {
      // controller.runJavaScript('console.log(`hello`)');
      // controller.runJavaScript('alert(`hello`)');
      controller.runJavaScript("""
DomHandler.postMessage(document.querySelector('body').innerHTML)    
""");

      // controller.
    } catch (e) {
      showTMessageDialogError(context, e.toString());
    }
  }

  void _fetchResult() async {
    try {
      // controller.runJavaScript('console.log(`hello`)');
      // controller.runJavaScript('alert(`hello`)');
      controller.runJavaScript("""
DomHandlerResult.postMessage(document.querySelector('body').innerHTML)    
""");

      // controller.
    } catch (e) {
      showTMessageDialogError(context, e.toString());
    }
  }

  void _showSettingMenu() {
    showTReanmeDialog(
      context,
      title: Text('Load Url'),
      text: url,
      submitText: 'Load',
      onSubmit: (text) {
        setState(() {
          url = text;
        });

        _load();
      },
    );
  }
}
