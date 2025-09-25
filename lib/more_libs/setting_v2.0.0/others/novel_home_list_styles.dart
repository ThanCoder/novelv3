enum NovelHomeListStyles {
  list,
  grid;

  static NovelHomeListStyles getName(String name) {
    if (name == list.name) return list;
    if (name == grid.name) return grid;
    return grid;
  }
}
