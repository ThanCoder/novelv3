import 'package:novel_v3/more_libs/general_static_server/general_server.dart';

class GeneralServerPathServices {
  final String root;
  GeneralServerPathServices({required this.root});

  static void init() {
    _cache['local'] = GeneralServerPathServices(
      root: GeneralServer.instance.getLocalServerPath(),
    );
    _cache['api'] = GeneralServerPathServices(
      root: GeneralServer.instance.getApiServerUrl(),
    );
  }

  static final Map<String, GeneralServerPathServices> _cache = {};

  static GeneralServerPathServices get getLocal {
    if (_cache['local'] == null) {
      throw Exception('[Usage]: `GeneralServerPathServices.init()`');
    }

    return _cache['local']!;
  }

  static GeneralServerPathServices get getApi {
    if (_cache['api'] == null) {
      throw Exception('[Usage]: `GeneralServerPathServices.init()`');
    }
    return _cache['api']!;
  }

  String getRoot({String? name}) {
    final name0 = name != null && name.isNotEmpty ? '/$name' : '';
    return '$root$name0';
  }

  String getDBFiles({String? name}) {
    final name0 = name != null && name.isNotEmpty ? '/$name' : '';
    return '$root/db_files$name0';
  }

  String getFiles({String? name}) {
    final name0 = name != null && name.isNotEmpty ? '/$name' : '';
    return '$root/files$name0';
  }

  String tutorialFiles({String? name}) {
    final name0 = name != null && name.isNotEmpty ? '/$name' : '';
    return '$root/tutorial_files$name0';
  }
}
