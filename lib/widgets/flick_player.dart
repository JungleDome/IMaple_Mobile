import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:imaplemobile/utils/video_player_helper.dart';
import 'package:video_player/video_player.dart';

class FlickPlayer extends StatefulWidget {
  final String streamUrl;
  final int? playAtMillisecondDuration;
  final String? nextEpisodePlayLink;

  FlickPlayer({Key? key, required this.streamUrl, this.playAtMillisecondDuration, this.nextEpisodePlayLink}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _FlickPlayerState(streamUrl: this.streamUrl, playAtMillisecondDuration: this.playAtMillisecondDuration);
  }
}

class _FlickPlayerState extends State<FlickPlayer> {
  late FlickManager _flickManager;
  String streamUrl = '';
  int? playAtMillisecondDuration;
  VideoPlayerHelper _videoPlayerHelper = VideoPlayerHelper();
  bool resumed = false;

  _FlickPlayerState({required this.streamUrl, this.playAtMillisecondDuration}) {
    streamUrl = streamUrl;
    playAtMillisecondDuration = playAtMillisecondDuration;
  }

  @override
  void initState() {
    super.initState();

    _flickManager = FlickManager(
      videoPlayerController: VideoPlayerController.network(streamUrl),
      autoPlay: true,
    );
    // Register progress event listener
    _flickManager.flickVideoManager?.videoPlayerController?.addListener(checkVideo);
    _flickManager.onVideoEnd = _videoPlayerHelper.clearProgress;
  }

  @override
  void dispose() {
    super.dispose();
    _flickManager.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top, SystemUiOverlay.bottom]);
  }

  @override
  Widget build(BuildContext context) {
    return FlickVideoPlayer(
      flickManager: _flickManager,
      flickVideoWithControls: FlickVideoWithControls(
        aspectRatioWhenLoading: 16/9,
        videoFit: BoxFit.contain,
        controls: FlickLandscapeControls(),
      ),
      flickVideoWithControlsFullscreen: FlickVideoWithControls(
        controls: FlickLandscapeControls(),
      ),
      preferredDeviceOrientation: [
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ],
      systemUIOverlay: [],
      wakelockEnabled: true,
    );
  }

  void checkVideo(){
    // Implement your calls inside these conditions' bodies :
    if (_flickManager.flickVideoManager?.videoPlayerController != null) {
      VideoPlayerController videoPlayerController = _flickManager.flickVideoManager!.videoPlayerController!;

      if(videoPlayerController.value.position == videoPlayerController.value.duration) {
        _videoPlayerHelper.clearProgress();
      } else {
        if (this.playAtMillisecondDuration != null && !resumed) {
          videoPlayerController.seekTo(Duration(milliseconds: this.playAtMillisecondDuration!));
          resumed = !resumed;
        } else {
          _videoPlayerHelper.saveProgress(streamUrl, videoPlayerController.value.position);
        }
      }
    }
  }
}
