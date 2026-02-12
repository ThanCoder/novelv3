import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:novel_v3/bloc_app/routers.dart';
import 'package:novel_v3/bloc_app/ui/main/home_screen.dart';
import 'package:novel_v3/more_libs/setting/core/theme_listener.dart';

class BlocApp extends StatelessWidget {
  const BlocApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (context) => CounterCubit())],
      child: ThemeListener(
        builder: (context, themeMode) {
          return MaterialApp.router(
            routerConfig: routerConfig,
            debugShowCheckedModeBanner: false,
            themeMode: ThemeMode.light,
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            // home: HomeScreen(),
          );
        },
      ),
    );
  }
}
