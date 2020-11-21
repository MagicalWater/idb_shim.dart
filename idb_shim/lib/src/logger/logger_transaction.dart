import 'dart:async';

import 'package:idb_shim/idb.dart';
import 'package:idb_shim/src/common/common_transaction.dart';
import 'package:idb_shim/src/logger/logger_database.dart';
import 'package:idb_shim/src/logger/logger_object_store.dart';
import 'package:idb_shim/src/utils/core_imports.dart';

class TransactionLogger extends IdbTransactionBase {
  Transaction idbTransaction;
  static int _id = 0;
  final id;

  DatabaseLogger get idbDatabaseLogger => database as DatabaseLogger;

  TransactionLogger(DatabaseLogger database, this.idbTransaction)
      : id = ++_id,
        super(database);

  @override
  ObjectStore objectStore(String name) =>
      ObjectStoreLogger(this, idbTransaction.objectStore(name));
/*
  @override
  Future<Database> get completed async {
    try {
      return await idbTransaction.completed;
    } catch (e) {
      err('completed sync error $e');
      rethrow;
    }
  }
  */
  @override
  Future<Database> get completed {
    try {
      return idbTransaction.completed.catchError((Object e) {
        err('completed error $e');
        throw e;
      }).whenComplete(() {
        log('completed');
      });
    } catch (e) {
      err('completed sync error $e');
      rethrow;
    }
  }

  @override
  void abort() {
    log('abort');
    idbTransaction.abort();
  }

  void log(String message) {
    idbDatabaseLogger.log('t$id $message');
  }

  void err(String message) {
    idbDatabaseLogger.err('t$id $message');
  }
}
