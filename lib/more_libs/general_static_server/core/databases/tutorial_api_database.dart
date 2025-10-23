import 'package:novel_v3/more_libs/general_static_server/core/interfaces/api_database.dart';
import 'package:novel_v3/more_libs/general_static_server/core/models/tutorial.dart';
import 'package:novel_v3/more_libs/general_static_server/services/general_server_path_services.dart';

class TutorialApiDatabase extends ApiDatabase<Tutorial> {
  TutorialApiDatabase()
    : super(
        root: GeneralServerPathServices.getApi.getRoot(
          name: 'tutorial.db.json',
        ),
      );

  @override
  Tutorial from(Map<String, dynamic> map) {
    return Tutorial.fromMap(map);
  }

  @override
  String getId(Tutorial value) {
    return value.id;
  }
}
