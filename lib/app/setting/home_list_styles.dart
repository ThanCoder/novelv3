enum HomeListStyles {
  homeGridStyle,
  allNovelListStyle,
  allNovelGridStyle;

  static HomeListStyles getStyle(String name) {
    if (name == HomeListStyles.allNovelListStyle.name) {
      return HomeListStyles.allNovelListStyle;
    }
    if (name == HomeListStyles.allNovelGridStyle.name) {
      return HomeListStyles.allNovelGridStyle;
    }
    return HomeListStyles.homeGridStyle;
  }
}
