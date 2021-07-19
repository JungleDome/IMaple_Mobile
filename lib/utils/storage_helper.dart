
import 'package:localstorage/localstorage.dart';

class StorageHelper {
  static final LocalStorage storage = new LocalStorage('data1.json');
  static Future<bool> ready = storage.ready;

  static void saveLastMovie(String name, String detailUrl) {
    StorageHelper.storage.setItem('lastPlayName', name);
    StorageHelper.storage.setItem('lastPlayDetailUrl', detailUrl);
  }
}