abstract class DatabaseInterface<T> {
  final String root;
  final Storage storage;
  DatabaseInterface({required this.root, required this.storage});

  Future<List<T>> getAll({Map<String, dynamic> query = const {}});
  Future<T?> getOne({Map<String, dynamic> query = const {}});
  Future<T?> getById(String id);
  Future<void> add(T value);
  Future<void> update(String id, T value);
  Future<void> delete(String id);
  // event listener
  final List<DatabaseListener> _listener = [];
  void addListener(DatabaseListener eve) {
    _listener.add(eve);
  }

  void removeListener(DatabaseListener eve) {
    _listener.remove(eve);
  }

  void clearListener() {
    _listener.clear();
  }

  void notify(String? id, DatabaseListenerTypes type) {
    for (var eve in _listener) {
      eve.onDatabaseChanged(id, type);
    }
  }
}

mixin DatabaseListener {
  void onDatabaseChanged(String? id, DatabaseListenerTypes listenerType);
}

enum DatabaseListenerTypes { added, deleted, update, saved }

class Storage {
  final String root;
  Storage({required this.root});
}
