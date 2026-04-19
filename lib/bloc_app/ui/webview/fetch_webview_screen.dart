// import 'package:flutter/material.dart';
// import 'package:t_widgets/t_widgets.dart';
// import 'package:webview_all/webview_all.dart';

// class FetchWebviewScreen extends StatefulWidget {
//   const FetchWebviewScreen({super.key});

//   @override
//   State<FetchWebviewScreen> createState() => _FetchWebviewScreenState();
// }

// class _FetchWebviewScreenState extends State<FetchWebviewScreen> {
//   final controller = WebViewController();

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) => init());
//   }

//   bool isLoading = false;
//   double? progress;
//   String url = 'https://flutter.dev';

//   Future<void> init() async {
//     controller.setJavaScriptMode(JavaScriptMode.unrestricted);
//     controller.enableZoom(true);
//     controller.setVerticalScrollBarEnabled(true);
//     controller.setNavigationDelegate(
//       NavigationDelegate(
//         onProgress: (progress) {
//           // print('progress: $progress');
//           this.progress = (progress / 100);
//           if (!mounted) return;
//           setState(() {});
//         },
//         onPageStarted: (url) {
//           if (!mounted) return;
//           setState(() {
//             isLoading = true;
//           });
//         },
//         onPageFinished: (url) {
//           // print('onPageFinished: $url');
//           if (!mounted) return;
//           setState(() {
//             isLoading = false;
//           });
//         },
//       ),
//     );
//     _load();
//   }

//   void _load() async {
//     //https://hostednovel.com/novel/im-really-not-the-demon-gods-lackey/chapter-20
//     //https://flutter.dev

//     try {
//       await controller.loadRequest(Uri.parse(url));
//     } catch (e) {
//       if (!mounted) return;
//       showTMessageDialogError(context, e.toString());
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Fetch Webview'),
//         actions: [
//           if (!isLoading)
//             IconButton(
//               onPressed: () {
//                 controller.reload();
//               },
//               icon: Icon(Icons.refresh),
//             ),
//           IconButton(onPressed: _showSettingMenu, icon: Icon(Icons.settings)),
//         ],
//         flexibleSpace: !isLoading
//             ? null
//             : LinearProgressIndicator(value: progress),
//       ),
//       body: WebViewWidget(controller: controller),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _fetch,
//         child: Icon(Icons.file_download_outlined),
//       ),
//     );
//   }

//   void _fetch() async {
//     // print(controller.runJavaScriptReturningResult('console.log("hello")'));
//   }

//   void _showSettingMenu() {
//     showTReanmeDialog(
//       context,
//       title: Text('Load Url'),
//       text: url,
//       submitText: 'Load',
//       onSubmit: (text) {
//         setState(() {
//           url = text;
//         });

//         _load();
//       },
//     );
//   }
// }
