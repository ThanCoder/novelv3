import 'package:go_router/go_router.dart';
import 'package:novel_v3/bloc_app/ui/content/content_screen.dart';
import 'package:novel_v3/bloc_app/ui/main/home_screen.dart';

final routerConfig = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => HomeScreen()),
    GoRoute(
      path: '/content/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return ContentScreen(id: id ?? '');
      },
    ),
  ],
);
