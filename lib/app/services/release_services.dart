import 'package:dio/dio.dart';
import 'package:novel_v3/app/constants.dart';

Future<void> getRelease() async {
  try {
    String releaseUrl = getParseReleaseUrl(githubUrl: githubUrl);
    // final res = await Dio().get(githubUrl);
    print(releaseUrl);
  } catch (e) {}
}

String getParseReleaseUrl({required String githubUrl}) {
  // https://github.com/ThanCoder/novelv3
  // https://raw.githubusercontent.com/ThanCoder/novelv3/refs/heads/main/assets/online.webp
  String res = '';
  res = '${getParseRawUrl(githubUrl: githubUrl)}/release.json';

  return res;
}

String getParseRawUrl({required String githubUrl}) {
  String hostUrl = githubUrl.replaceAll(
      "https://github.com", 'https://raw.githubusercontent.com');
  return '$hostUrl/refs/heads/main';
}
