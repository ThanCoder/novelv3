enum FetcherTypes {
  telegra,
  mmxianxia;

  static FetcherTypes? getFromName(String name) {
    if (name == telegra.name) {
      return telegra;
    }
    if (name == mmxianxia.name) {
      return mmxianxia;
    }
    return null;
  }
}
