import 'package:imaplemobile/utils/storage_helper.dart';

class MovieStorage {
  String? lastPlayName; // name (episode)
  String? lastPlayDetailUrl; //../vod/xxx
  String? lastPlayPlayUrl; // ../play/xxx-x
  String? lastPlayStreamUrl; // ../xxx.m3u8
  int? lastPlayDuration; // xxxms

  static MovieStorage? _instance = null;

  static MovieStorage get instance => MovieStorage._read();
  static void set instance(MovieStorage movieStorage) {
    _instance = movieStorage;
  }

  MovieStorage({this.lastPlayName, this.lastPlayDetailUrl, this.lastPlayPlayUrl, this.lastPlayStreamUrl, this.lastPlayDuration});

  static MovieStorage _read() {
    if (_instance != null)
      return _instance!;

    _instance = new MovieStorage();
    _instance!.lastPlayName = StorageHelper.storage.getItem("lastPlayName");
    _instance!.lastPlayDetailUrl = StorageHelper.storage.getItem("lastPlayDetailUrl");
    _instance!.lastPlayPlayUrl = StorageHelper.storage.getItem("lastPlayPlayUrl");
    _instance!.lastPlayStreamUrl = StorageHelper.storage.getItem("lastPlayStreamUrl");
    _instance!.lastPlayDuration = StorageHelper.storage.getItem("lastPlayDuration");
    return _instance!;
  }

  static void save() {
    StorageHelper.save("lastPlayName", instance.lastPlayName);
    StorageHelper.save("lastPlayDetailUrl", instance.lastPlayPlayUrl);
    StorageHelper.save("lastPlayPlayUrl", instance.lastPlayPlayUrl);
    StorageHelper.save("lastPlayStreamUrl", instance.lastPlayStreamUrl);
    StorageHelper.save("lastPlayDuration", instance.lastPlayDuration);
  }
}