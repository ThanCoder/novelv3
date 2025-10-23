mixin DatabaseChangedListener {
  void onDatabaseChanged(DatabaseChangedListenerTypes event, String? id);
}

enum DatabaseChangedListenerTypes { save, delete, add, update }

enum DatabaseTypes { local, api }

abstract class Database<T> {
  final String root;
  Database({required this.root});

  Future<T> add(T value);
  Future<bool> update(String id, T value);
  Future<int> delete(String id);
  Future<List<T>> getAll({Map<String, dynamic>? query});
  Future<T?> getById(String id);

  // listener
  final List<DatabaseChangedListener> _listener = [];
  void addListener(DatabaseChangedListener listener) {
    _listener.add(listener);
  }

  void removeListener(DatabaseChangedListener listener) {
    _listener.remove(listener);
  }

  void clearListener() {
    _listener.clear();
  }

  void notify(DatabaseChangedListenerTypes event, String? id) {
    for (var ev in _listener) {
      ev.onDatabaseChanged(event, id);
    }
  }
}
