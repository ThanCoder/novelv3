import 'index.dart';
import '../widgets/index.dart';
import 'package:flutter/material.dart';

class GeneralServerNotiButton extends StatefulWidget {
  const GeneralServerNotiButton({super.key});

  @override
  State<GeneralServerNotiButton> createState() =>
      _GeneralServerNotiButtonState();
}

class _GeneralServerNotiButtonState extends State<GeneralServerNotiButton> {
  bool isLoading = false;
  bool isCurrentAppLatest = true;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    setState(() {
      isLoading = true;
    });

    isCurrentAppLatest = await GeneralServices.instance.isCurrentAppLatest();
    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
  }

  void goPage() async {
    setState(() {
      isLoading = true;
    });
    final releaseAppList = await GeneralServices.instance.getReleaseAppList();
    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
    if (releaseAppList.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(
          releaseApp: releaseAppList.first,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        width: 25,
        height: 25,
        child: TLoader(size: 25),
      );
    }
    return Badge(
      isLabelVisible: !isCurrentAppLatest,
      child: IconButton(
        onPressed: goPage,
        icon: Icon(Icons.notifications),
      ),
    );
  }
}
