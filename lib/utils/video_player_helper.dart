import 'package:easy_debounce/easy_debounce.dart';
import 'package:imaplemobile/utils/storage_helper.dart';

class VideoPlayerHelper {
  void saveProgress(String streamUrl, Duration duration) {
    EasyDebounce.debounce('videoProgress', Duration(milliseconds: 1000), () async {
        await StorageHelper.storage.setItem('lastPlayStreamUrl', streamUrl);
        await StorageHelper.storage.setItem('lastPlayDuration', duration.inMilliseconds);
        //print('Saved last play');
    });
  }

  void clearProgress() {
    EasyDebounce.debounce('videoEnd', Duration(milliseconds: 1000), () async {
      await StorageHelper.storage.deleteItem('lastPlayStreamUrl');
      await StorageHelper.storage.deleteItem('lastPlayDuration');
      await StorageHelper.storage.deleteItem('lastPlayName');
      await StorageHelper.storage.deleteItem('lastPlayDetailUrl');
    });
  }
}