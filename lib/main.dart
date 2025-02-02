import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/my_app.dart';
import 'package:novel_v3/app/utils/config_util.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //url
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );

  if (Platform.isLinux) {
    await WindowManager.instance.ensureInitialized();
  }
  //init config
  await initConfig();

  runApp(const MyApp());
}
