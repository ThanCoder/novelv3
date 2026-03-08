import 'package:flutter/material.dart';

class RestartWidget extends StatefulWidget {
  final Widget child;

  const RestartWidget({super.key, required this.child});

  // ဒီ static method ကနေတဆင့် App ထဲက ကြိုက်တဲ့နေရာကနေ Restart လှမ်းချလို့ရမယ်
  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()?.restartApp();
  }

  @override
  State<RestartWidget> createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      // Key အသစ်ပြောင်းလိုက်တာနဲ့ Flutter က အောက်က Widget တွေအကုန်လုံးကို
      // အသစ်အဖြစ်သတ်မှတ်ပြီး အစကနေ ပြန် build ပါတော့တယ်
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(key: key, child: widget.child);
  }
}
