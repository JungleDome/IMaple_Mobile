import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:imaplemobile/page/video_player.dart';
import 'package:imaplemobile/utils/video_player_helper.dart';
import 'package:video_player/video_player.dart';

class FlickPlayerManager extends ChangeNotifier{
  FlickPlayerManager({
    required this.flickManager,
    required this.streamUrl,
    this.playAtMillisecondDuration,
    this.nextEpisodePlayLink,
    this.hasNextEpisode = false,
    this.playNextEpisodeCallback
  });

  final FlickManager flickManager;
  final String streamUrl;
  final int? playAtMillisecondDuration;
  final String? nextEpisodePlayLink;
  final bool hasNextEpisode;
  final ChangeNextEpisodeCallback? playNextEpisodeCallback;

  final VideoPlayerHelper _videoPlayerHelper = new VideoPlayerHelper();

  /// Boolean flags
  bool _resumed = false;

  bool canPlayNextVideo() {
    return this.hasNextEpisode && this.playNextEpisodeCallback != null;
  }

  bool resumeable() {
    return this.playAtMillisecondDuration != null && !this._resumed;
  }

  /// Event function
  void registerVideoProgressListener() {
    if (flickManager.flickVideoManager?.videoPlayerController != null) {
      flickManager.flickVideoManager?.videoPlayerController?.removeListener(videoProgressCallback);
      flickManager.flickVideoManager?.videoPlayerController?.addListener(videoProgressCallback);
      flickManager.onVideoEnd = this.handleVideoEnd;
    }
  }

  void videoProgressCallback() {
    if (this.resumeable())
      this.resumeVideo();
    else
      this.saveVideoProgress();
  }

  void handleVideoEnd() {
    if (this.canPlayNextVideo())
      this.skipToNextVideo();
    else
      this.clearVideoProgress();
  }

  /// Data store function
  void saveVideoProgress() {
    if (flickManager.flickVideoManager?.videoPlayerController != null)
      _videoPlayerHelper.saveProgress(streamUrl, flickManager.flickVideoManager!.videoPlayerController!.value!.position!);
  }

  void clearVideoProgress() {
    _videoPlayerHelper.clearProgress();
  }

  /// Core function
  void playVideo() { // Main entry function
    if (flickManager.flickVideoManager?.videoPlayerController?.dataSource != streamUrl) {
      var videoPlayerController = VideoPlayerController.network(streamUrl);
      flickManager.handleChangeVideo(videoPlayerController);
    }
    this.registerVideoProgressListener();
  }

  void skipToNextVideo() {
    if (this.canPlayNextVideo())
      this.playNextEpisodeCallback!(flickManager, () {
        //print('is null?' + (_flickManager.flickVideoManager?.videoPlayerController == null).toString());
        this.registerVideoProgressListener();
      });
  }

  void resumeVideo() {
    if (flickManager.flickVideoManager?.videoPlayerController != null) {
      this._resumed = true;
      flickManager.flickVideoManager?.videoPlayerController?.seekTo(Duration(milliseconds: this.playAtMillisecondDuration!));
    }
  }

  String? getVideoTitle() {
    //notifyListeners();
    return _videoPlayerHelper.getCurrentPlayingTitle();
  }
}