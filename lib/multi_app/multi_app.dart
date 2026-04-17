import 'package:flutter/material.dart';
import 'package:novel_v3/old_app/old_app.dart';
import 'package:novel_v3/bloc_app/bloc_app.dart';
import 'package:than_pkg/t_database/t_recent_db.dart';

enum MultiAppType {
  oldApp,
  blocApp;

  static MultiAppType getName(String name) {
    if (name == blocApp.name) return blocApp;
    return oldApp;
  }
}

class MultiApp extends StatefulWidget {
  static final multiAppKey = 'multi-app-type';

  static MultiAppType getConfigType() {
    return MultiAppType.getName(
      TRecentDB.getInstance.getString(MultiApp.multiAppKey),
    );
  }

  const MultiApp({super.key});

  @override
  State<MultiApp> createState() => _MultiAppState();
}

class _MultiAppState extends State<MultiApp> {
  @override
  Widget build(BuildContext context) {
    if (MultiApp.getConfigType() == MultiAppType.oldApp) {
      return OldApp();
    }
    return BlocApp();
  }
}
