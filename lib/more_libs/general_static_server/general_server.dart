import 'package:novel_v3/more_libs/general_static_server/services/general_server_path_services.dart';

typedef OnApiResponseCallback = Future<String> Function(String url);

class GeneralServer {
  static final GeneralServer instance = GeneralServer._();
  GeneralServer._();
  factory GeneralServer() => instance;

  late String Function() getApiServerUrl;
  late String Function() getLocalServerPath;
  late OnApiResponseCallback getContentFromUrl;
  String? packageName;

  Future<void> init({
    required String Function() getApiServerUrl,
    required String Function() getLocalServerPath,
    required OnApiResponseCallback getContentFromUrl,
    String? packageName,
  }) async {
    this.getLocalServerPath = getLocalServerPath;
    this.getApiServerUrl = getApiServerUrl;
    this.getContentFromUrl = getContentFromUrl;
    this.packageName = packageName;

    GeneralServerPathServices.init();
  }
}
