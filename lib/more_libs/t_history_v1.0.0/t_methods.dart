enum TMethods {
  get,
  add,
  delete,
  export,
  update;

  static TMethods getType(String name) {
    if (TMethods.add.name == name) {
      return TMethods.add;
    }
    if (TMethods.delete.name == name) {
      return TMethods.delete;
    }
    if (TMethods.get.name == name) {
      return TMethods.get;
    }
    if (TMethods.update.name == name) {
      return TMethods.update;
    }
    if (TMethods.export.name == name) {
      return TMethods.export;
    }
    return TMethods.add;
  }
}
