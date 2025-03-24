import 'package:than_pkg/enums/screen_orientation_types.dart';

extension ScreenOrientationTypesExtension on ScreenOrientationTypes {
  static ScreenOrientationTypes fromType(String type) {
    if (type == ScreenOrientationTypes.Landscape.name) {
      return ScreenOrientationTypes.Landscape;
    }
    return ScreenOrientationTypes.Portrait;
  }
}
