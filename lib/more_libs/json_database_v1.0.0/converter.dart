// abstract class Converter<T> {
//   T from(dynamic value);
//   dynamic to(T value);
// }

abstract class MapConverter<T> {
  T from(Map<String, dynamic> map);
  Map<String, dynamic> to(T value);
}
