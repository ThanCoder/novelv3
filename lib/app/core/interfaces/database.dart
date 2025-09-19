// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/widgets.dart';

import 'storage.dart';

abstract class Database<T> {
  final String root;
  final Storage storage;
  Database({required this.root, required this.storage});

  Future<List<T>> getAll({Map<String, dynamic> query = const {}});
  Future<void> add(T value);
  Future<void> update(String id, T value);
  Future<void> delete(String id);
  // listener
  final List<DatabaseListener> _listener = [];
  void addListener(DatabaseListener listener) {
    _listener.add(listener);
  }

  void removeListener(DatabaseListener listener) {
    _listener.remove(listener);
  }

  void clearListener() {
    _listener.clear();
  }

  void notify(DatabaseListenerEvent event, {String? id}) {
    try {
      for (var ev in _listener) {
        ev.onDatabaseChanged(event, id: id);
      }
    } catch (e) {
      debugPrint('[Database:notify]: ${e.toString()}');
    }
  }
}

mixin DatabaseListener {
  void onDatabaseChanged(DatabaseListenerEvent event, {String? id});
}

enum DatabaseListenerEvent { saved, add, update, delete }
