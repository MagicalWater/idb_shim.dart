library idb_shim.utils.idb_utils;

import 'dart:async';

import 'package:idb_shim/src/utils/core_imports.dart';

import '../idb_client.dart';
import '../src/common/common_meta.dart';

class _SchemaMeta {
  List<IdbObjectStoreMeta> stores = [];
}

///
/// Copy a database to another
/// return the opened database
///
Future<Database> copySchema(
    Database srcDatabase, IdbFactory dstFactory, String dstDbName) async {
  // Delete the existing
  if (dstDbName != null) {
    await dstFactory.deleteDatabase(dstDbName);
  }

  final version = srcDatabase.version;

  final schemaMeta = _SchemaMeta();
  // Get schema
  final storeNames = List<String>.from(srcDatabase.objectStoreNames);
  if (storeNames.isNotEmpty) {
    final txn = srcDatabase.transactionList(storeNames, idbModeReadOnly);
    for (final storeName in storeNames) {
      final store = txn.objectStore(storeName);
      final storeMeta = IdbObjectStoreMeta.fromObjectStore(store);
      for (final indexName in store.indexNames) {
        final index = store.index(indexName);
        final indexMeta = IdbIndexMeta.fromIndex(index);
        storeMeta.putIndex(indexMeta);
      }
      schemaMeta.stores.add(storeMeta);
    }
    await txn.completed;
  }

  void _onUpgradeNeeded(VersionChangeEvent event) {
    final db = event.database;
    for (final storeMeta in schemaMeta.stores) {
      final store = db.createObjectStore(storeMeta.name,
          keyPath: storeMeta.keyPath, autoIncrement: storeMeta.autoIncrement);
      for (final indexMeta in storeMeta.indecies) {
        store.createIndex(indexMeta.name, indexMeta.keyPath,
            unique: indexMeta.unique, multiEntry: indexMeta.multiEntry);
      }
    }
  }

  // devPrint('Open $dstDbName version $version');
  // Open and copy scheme
  final dstDatabase = await dstFactory.open(dstDbName,
      version: version, onUpgradeNeeded: _onUpgradeNeeded);
  return dstDatabase;
}

class _Record {
  var value;
  var key;
}

/// Copy a store from a database to another existing one.
Future copyStore(Database srcDatabase, String srcStoreName,
    Database dstDatabase, String dstStoreName) async {
  // Copy all in Memory first
  final records = <_Record>[];

  final srcTransaction = srcDatabase.transaction(srcStoreName, idbModeReadOnly);
  var store = srcTransaction.objectStore(srcStoreName);
  store.openCursor(autoAdvance: true).listen((CursorWithValue cwv) {
    records.add(_Record()
      ..key = cwv.key
      ..value = cwv.value);
  });
  await srcTransaction.completed;

  final dstTransaction =
      dstDatabase.transaction(dstStoreName, idbModeReadWrite);
  store = dstTransaction.objectStore(dstStoreName);
  // clear the existing records
  await store.clear();
  for (final record in records) {
    // ignore: unawaited_futures
    store.put(record.value, record.key);
  }
  await dstTransaction.completed;
}

/// Copy a database content to a new database.
Future<Database> copyDatabase(
    Database srcDatabase, IdbFactory dstFactory, String dstDbName) async {
  final dstDatabase = await copySchema(srcDatabase, dstFactory, dstDbName);
  for (final storeName in srcDatabase.objectStoreNames) {
    await copyStore(srcDatabase, storeName, dstDatabase, storeName);
  }
  return dstDatabase;
}

/// Cursor row.
class CursorRow extends KeyCursorRow {
  /// Cursor row value.
  final dynamic value;

  /// Create a cursor row with a [key], [primaryKey] and [value].
  CursorRow(dynamic key, dynamic primaryKey, this.value)
      : super(key, primaryKey);

  @override
  String toString() {
    return '$value';
  }
}

/// Key cursor row.
class KeyCursorRow {
  /// Cursor row key.
  ///
  /// This is the index key if the cursor is open on an index. Otherwise, it is
  /// the primary key.
  final dynamic key;

  /// Cursory row primary key.
  final dynamic primaryKey;

  @override
  String toString() {
    return '$key $primaryKey';
  }

  /// Create a cursor row with a [key], and [primaryKey].
  KeyCursorRow(this.key, this.primaryKey);
}

/// Convert an openCursor stream to a list
Future<List<CursorRow>> cursorToList(Stream<CursorWithValue> stream) {
  var completer = Completer<List<CursorRow>>.sync();
  final list = <CursorRow>[];
  stream.listen((CursorWithValue cwv) {
    list.add(CursorRow(cwv.key, cwv.primaryKey, cwv.value));
  }).onDone(() {
    completer.complete(list);
  });
  return completer.future;
}

/// Convert an openKeyCursor stream to a list
Future<List<KeyCursorRow>> keyCursorToList(Stream<Cursor> stream) {
  var completer = Completer<List<KeyCursorRow>>.sync();
  final list = <KeyCursorRow>[];
  stream.listen((Cursor cursor) {
    list.add(KeyCursorRow(cursor.key, cursor.primaryKey));
  }).onDone(() {
    completer.complete(list);
  });
  return completer.future;
}
