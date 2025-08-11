import 'app_helper.dart';

class AppHelperServices {
  static Future<List<AppHelper>> getList() async {
    List<AppHelper> list = [];
    list.add(_getHowToDownloadedDataFileAndInstall);
    return list;
  }

  static AppHelper get _getHowToDownloadedDataFileAndInstall => AppHelper(
        title: 'Downloaded ပြုလုပ်ထားတဲ့ Data File ကိုဘယ်လို သွင်းရမလဲ?',
        desc: '',
        images: [
          _getAssetsPath('how_to_install_data_1.jpg'),
          _getAssetsPath('how_to_install_data_2.jpg'),
        ],
      );

  static String _getAssetsPath(String name) => 'assets/app_helper/$name';
  // static String  _getAssetsPath(String name) => 'assets/file.png';
}
