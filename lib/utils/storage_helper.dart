
import 'package:localstorage/localstorage.dart';

class StorageHelper {
  static final LocalStorage storage = new LocalStorage('data1.json');
  static Future<bool> ready = storage.ready;
}