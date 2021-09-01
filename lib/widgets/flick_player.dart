import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:imaplemobile/page/video_player.dart';
import 'package:imaplemobile/utils/video_player_helper.dart';
import 'package:imaplemobile/widgets/flick_custom_control.dart';
import 'package:imaplemobile/widgets/flick_player_manager.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class FlickPlayer extends StatefulWidget {
  final String streamUrl;
  final int? playAtMillisecondDuration;
  final String? nextEpisodePlayLink;
  final bool hasNextEpisode;
  final ChangeNextEpisodeCallback playNextEpisodeCallback;

  FlickPlayer(
      {Key? key,
      required this.streamUrl,
      this.playAtMillisecondDuration,
      this.nextEpisodePlayLink,
      this.hasNextEpisode = false,
      required this.playNextEpisodeCallback})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _FlickPlayerState(
        streamUrl: this.streamUrl,
        playAtMillisecondDuration: this.playAtMillisecondDuration,
        nextEpisodePlayLink: this.nextEpisodePlayLink,
        hasNextEpisode: this.hasNextEpisode,
        playNextEpisodeCallback: this.playNextEpisodeCallback);
  }
}

class _FlickPlayerState extends State<FlickPlayer> {
  late FlickManager _flickManager;
  String streamUrl = '';
  int? playAtMillisecondDuration;
  String? nextEpisodePlayLink;
  bool hasNextEpisode;
  ChangeNextEpisodeCallback playNextEpisodeCallback;

  VideoPlayerHelper _videoPlayerHelper = VideoPlayerHelper();
  late FlickPlayerManager _flickPlayerManager;
  bool resumed = false;

  _FlickPlayerState(
      {required this.streamUrl,
      this.playAtMillisecondDuration,
      this.nextEpisodePlayLink,
      this.hasNextEpisode = false,
      required this.playNextEpisodeCallback}) {
    streamUrl = streamUrl;
    playAtMillisecondDuration = playAtMillisecondDuration;
    nextEpisodePlayLink = nextEpisodePlayLink;
    hasNextEpisode = hasNextEpisode;
    playNextEpisodeCallback = playNextEpisodeCallback;
  }

  @override
  void initState() {
    super.initState();

    _flickManager = FlickManager(
      videoPlayerController: VideoPlayerController.network(streamUrl),
    );
    _flickPlayerManager = FlickPlayerManager(
        flickManager: _flickManager,
        streamUrl: streamUrl,
        playNextEpisodeCallback: playNextEpisodeCallback,
        playAtMillisecondDuration: playAtMillisecondDuration,
        hasNextEpisode: hasNextEpisode,
        nextEpisodePlayLink: nextEpisodePlayLink);
    _flickPlayerManager.playVideo();
    // Register progress event listener
    //_flickManager.flickVideoManager?.videoPlayerController?.addListener(checkVideo);
    // _flickManager.onVideoEnd = () {
    //   if (this.hasNextEpisode) //Quick fix resume video trigger this call
    //     this.playNextEpisodeCallback(_flickManager, () {
    //       //print('is null?' + (_flickManager.flickVideoManager?.videoPlayerController == null).toString());
    //       _flickManager.flickVideoManager?.videoPlayerController?.addListener(checkVideo);
    //     });
    //   else
    //     _videoPlayerHelper.clearProgress();
    // };
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
    return ChangeNotifierProvider.value(
      value: _flickPlayerManager,
      child: FlickVideoPlayer(
        flickManager: _flickManager,
        flickVideoWithControls: FlickVideoWithControls(
          aspectRatioWhenLoading: 16 / 9,
          videoFit: BoxFit.contain,
          controls: IMapleFlickLandscapeControls(),
        ),
        flickVideoWithControlsFullscreen: FlickVideoWithControls(
          controls: IMapleFlickLandscapeControls(),
        ),
        preferredDeviceOrientation: [
          DeviceOrientation.landscapeRight,
          DeviceOrientation.landscapeLeft,
        ],
        systemUIOverlay: [],
        wakelockEnabled: true,
      ),
    );
  }

  void checkVideo() {
    // Implement your calls inside these conditions' bodies :
    if (_flickManager.flickVideoManager?.videoPlayerController != null) {
      VideoPlayerController videoPlayerController = _flickManager.flickVideoManager!.videoPlayerController!;

      if (videoPlayerController.value.position == videoPlayerController.value.duration &&
          videoPlayerController.value.position.inMilliseconds == 0) {
        // if ( && this.hasNextEpisode) {
        //   this.playNextEpisodeCallback(_flickManager);
        // } else {
        //   _videoPlayerHelper.clearProgress(clearDetailUrl: true);
        // }
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
