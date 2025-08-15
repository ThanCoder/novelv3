import 'package:flutter/material.dart';
import 'package:than_pkg/than_pkg.dart';
import '../setting.dart';

class AppInternetCheckerWidget extends StatefulWidget {
  Widget? offlineWidet;
  Widget? onlineWidet;
  bool isSliverWidget;
  AppInternetCheckerWidget({
    super.key,
    this.offlineWidet,
    this.onlineWidet,
    this.isSliverWidget = false,
  });

  @override
  State<AppInternetCheckerWidget> createState() =>
      _AppInternetCheckerWidgetState();
}

class _AppInternetCheckerWidgetState extends State<AppInternetCheckerWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  bool isInternetConnected = false;
  bool isLoading = false;
  void init() async {
    try {
      setState(() {
        isLoading = true;
      });
      isInternetConnected = await ThanPkg.platform.isInternetConnected();
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      Setting.showDebugLog(e.toString(), tag: 'AppInternetCheckerWidget:init');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return widget.isSliverWidget ? SliverToBoxAdapter() : SizedBox.shrink();
    }
    if (isInternetConnected) {
      // online
      return widget.isSliverWidget
          ? SliverToBoxAdapter(child: _getOnlineWidget())
          : _getOnlineWidget();
    } else {
      // offline ဆိုရင် text ပေးမယ်
      return widget.isSliverWidget
          ? SliverFillRemaining(child: _getOfflineWidget())
          : _getOfflineWidget();
    }
  }

  Widget _getOnlineWidget() {
    if (widget.onlineWidet != null) {
      return widget.onlineWidet!;
    }
    return SizedBox.shrink();
  }

  Widget _getOfflineWidget() {
    if (widget.offlineWidet != null) {
      return widget.offlineWidet!;
    }
    return Center(
      child: Text(
        'Please Turn On Internet!.\nYou Are Offline State.',
        style: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }
}
