import 'package:t_server/core/index.dart';
import 'package:t_server/core/interfaces/t_router_interface.dart';
import 'package:t_server/core/routers/t_router.dart';

class ServerServices {
  static ServerServices? _instance;
  static ServerServices get getInstance {
    _instance ??= ServerServices();
    return _instance!;
  }

  late final TServer server;
  late final TRouterInterface router;

  ServerServices() {
    router = TRouter();
    server = TServer();
    server.setRouter(router);
  }
}
