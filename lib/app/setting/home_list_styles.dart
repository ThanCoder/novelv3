enum HomeListStyles {
  homeGridStyle,
  allNovelListStyle;

  static HomeListStyles getStyle(String name) {
    if (name == HomeListStyles.allNovelListStyle.name) {
      return HomeListStyles.allNovelListStyle;
    }
    return HomeListStyles.homeGridStyle;
  }
}
