// ignore_for_file: public_member_api_docs, sort_constructors_first
class SelectorRules {
  final String selector;
  final String? attribute;
  SelectorRules(this.selector, {this.attribute});

  @override
  String toString() {
    return 'selector: $selector -> attr: $attribute';
  }
}
