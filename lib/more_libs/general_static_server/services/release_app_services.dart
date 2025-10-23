import '../core/databases/release_json_database.dart';
import '../general_server.dart';

class ReleaseAppServices {
  static ReleaseJsonDatabase getLocalDB(String appId) {
    return ReleaseJsonDatabase(
      root:
          '${GeneralServer.instance.getApiServerUrl()}/db_files/$appId.app.release.db.json',
    );
  }
}
