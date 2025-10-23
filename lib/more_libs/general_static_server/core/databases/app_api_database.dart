import 'package:novel_v3/more_libs/general_static_server/services/general_server_path_services.dart';

import '../interfaces/index.dart';
import '../models/app.dart';

class AppApiDatabase extends ApiDatabase<App> {
  AppApiDatabase()
    : super(
        root: GeneralServerPathServices.getApi.getRoot(name: 'app.db.json'),
      );

  @override
  App from(Map<String, dynamic> map) {
    final app = App.fromMap(map);
    // final coverUrl = '${storage.getPath(app.id)}.png';
    // return app.copyWith(coverSource: coverUrl);
    return app;
  }

  @override
  String getId(App value) {
    return value.id;
  }
}
