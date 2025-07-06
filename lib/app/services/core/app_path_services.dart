import '../../setting/app_notifier.dart';

//external path ကိုဆိုလိုတာ
String getAppExternalRootPath() {
  return appExternalPathNotifier.value;
}
