
import 'package:localstorage/localstorage.dart';

class StorageItem {
  final String key;
  final dynamic value;
  final bool isDelete;

  StorageItem(this.key, {this.value, this.isDelete = false});
}

class StorageHelper {
  static final LocalStorage storage = new LocalStorage('data1.json');
  static Future<bool> ready = storage.ready;
  static List<StorageItem> saveQueue = new List.empty(growable: true);
  static bool saving = false;

  static void save(String key, dynamic value) {
    saveQueue.add(new StorageItem(key, value: value, isDelete: value == null));
    if (!saving)
      commit();
  }

  static void delete(String key) {
    saveQueue.add(new StorageItem(key, isDelete: true));
    if (!saving)
      commit();
  }

  static Future<void> commit() async {
    saving = true;
    while (saveQueue.length > 0) {
      var item = saveQueue.removeAt(0);
      if (item.isDelete)
        await StorageHelper.storage.deleteItem(item.key);
      else
        await StorageHelper.storage.setItem(item.key, item.value);
    }
    saving = false;
  }
}