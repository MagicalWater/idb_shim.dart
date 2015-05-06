library idb_shim.test_runner;

import 'package:test/test.dart';

import 'open_test.dart' as open_test;
import 'database_test.dart' as database_test;
import 'transaction_test.dart' as transaction_test;
import 'cursor_test.dart' as cursor_test;
import 'key_range_test.dart' as key_range_test;
import 'object_store_test.dart' as object_store_test;
import 'index_test.dart' as index_test;
import 'index_cursor_test.dart' as index_cursor_test;
import 'simple_provider_test.dart' as simple_provider_test;
import 'factory_test.dart' as factory_test;
import 'quick_standalone_test.dart' as quick_standalone_test;
import 'indexeddb_1_test.dart' as indexeddb_1_test;
import 'indexeddb_2_test.dart' as indexeddb_2_test;
import 'indexeddb_3_test.dart' as indexeddb_3_test;
import 'indexeddb_4_test.dart' as indexeddb_4_test;
import 'indexeddb_5_test.dart' as indexeddb_5_test;
import 'package:idb_shim/idb_client.dart';

defineTests(IdbFactory idbFactory) {

  transaction_test.defineTests(idbFactory);
  cursor_test.defineTests(idbFactory);
  open_test.defineTests(idbFactory);
  database_test.defineTests(idbFactory);
  object_store_test.defineTests(idbFactory);
  key_range_test.defineTests(idbFactory);
  factory_test.defineTests(idbFactory);
  index_test.defineTests(idbFactory);
  index_cursor_test.defineTests(idbFactory);
  simple_provider_test.defineTests(idbFactory);
  quick_standalone_test.defineTests(idbFactory);

  group('indexeddb_1', () {
    indexeddb_1_test.defineTests(idbFactory);
  });
  group('indexeddb_2', () {
    indexeddb_2_test.defineTests(idbFactory);
  });
  group('indexeddb_3', () {
    indexeddb_3_test.defineTests(idbFactory);
  });
  group('indexeddb_4', () {
    indexeddb_4_test.defineTests(idbFactory);
  });
  group('indexeddb_5', () {
    indexeddb_5_test.defineTests(idbFactory);
  });
}
