import 'package:easy_debounce/easy_debounce.dart';
import 'package:imaplemobile/model/movie_storage.dart';

class VideoPlayerHelper {
  void saveProgress(String streamUrl, Duration duration) {
    EasyDebounce.debounce('videoProgress', Duration(milliseconds: 1000), () {
      MovieStorage.instance.lastPlayStreamUrl = streamUrl;
      MovieStorage.instance.lastPlayDuration = duration.inMilliseconds;
      MovieStorage.save();
      //print('Saved last play');
    });
  }

  void clearProgress({bool clearDetailUrl = false}) {
    EasyDebounce.debounce('videoEnd', Duration(milliseconds: 1000), () {
      MovieStorage.instance.lastPlayName = null;
      MovieStorage.instance.lastPlayDuration = null;
      MovieStorage.instance.lastPlayStreamUrl = null;
      MovieStorage.instance.lastPlayPlayUrl = null;
      if (clearDetailUrl)
        MovieStorage.instance.lastPlayDetailUrl = null;
      MovieStorage.save();
    });
  }

  String? getCurrentPlayingTitle() {
    return MovieStorage.instance.lastPlayName;
  }
}