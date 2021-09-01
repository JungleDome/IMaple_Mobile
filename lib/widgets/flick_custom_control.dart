import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:imaplemobile/widgets/flick_player_manager.dart';
import 'package:provider/provider.dart';

/// Returns a text widget with current position of the video.
class IMapleFlickCurrentPosition extends StatelessWidget {
  const IMapleFlickCurrentPosition({
    Key? key,
    this.fontSize,
    this.color,
  }) : super(key: key);

  final double? fontSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    FlickVideoManager videoManager = Provider.of<FlickVideoManager>(context);

    Duration? position = videoManager.videoPlayerValue?.position;

    String textPosition = position != null
        ? '${position.inHours == 0 ? '' : '${addLeadingZero(position.inHours)}:'}${addLeadingZero(position.inMinutes.remainder(60))}:${addLeadingZero(position.inSeconds.remainder(60))}'
        : '--:--';

    return Text(
      textPosition,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
      ),
    );
  }

  String addLeadingZero(int number) {
    return number.toString().padLeft(2, '0');
  }
}

/// Returns a text widget with total duration of the video.
class IMapleFlickTotalDuration extends StatelessWidget {
  const IMapleFlickTotalDuration({
    Key? key,
    this.fontSize,
    this.color,
  }) : super(key: key);

  final double? fontSize;
  final Color? color;

  String addLeadingZero(int number) {
    return number.toString().padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {
    FlickVideoManager videoManager = Provider.of<FlickVideoManager>(context);

    Duration? duration = videoManager.videoPlayerValue?.duration;

    String textDuration = duration != null
        ? '${duration.inHours == 0 ? '' : '${addLeadingZero(duration.inHours)}:'}${addLeadingZero(duration.inMinutes.remainder(60))}:${addLeadingZero(duration.inSeconds.remainder(60))}'
        : '--:--';

    return Text(
      textDuration,
      style: TextStyle(
        fontSize: fontSize,
        color: color,
      ),
    );
  }
}

class IMapleFlickVideoTitle extends StatelessWidget {
  const IMapleFlickVideoTitle({
    Key? key,
    this.textStyle,
    this.padding,
  }) : super(key: key);

  final TextStyle? textStyle;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    FlickPlayerManager flickPlayerManager = Provider.of<FlickPlayerManager>(context);

    return Container(
      padding: padding,
      child: Text(
        flickPlayerManager.getVideoTitle() ?? '',
        style: textStyle,
      ),
    );
  }
}

class IMapleSetPlaybackSpeed extends StatelessWidget {
  IMapleSetPlaybackSpeed({
    Key? key,
    this.size,
    this.color,
  });

  final double? size;
  final Color? color;

  late FlickVideoManager _videoManager;

  final List<double> speedList = [1.0, 1.25, 1.5, 1.75, 2.0, 2.5, 3.0];

  void changePlaybackSpeed() {
    var playbackSpeed = _videoManager.videoPlayerValue?.playbackSpeed;
    if (playbackSpeed != null) {
      var currentSpeed = speedList.indexOf(playbackSpeed);
      var nextSpeed = speedList[0];
      if (currentSpeed < speedList.length - 1) nextSpeed = speedList[currentSpeed + 1];
      _videoManager.videoPlayerController!.setPlaybackSpeed(nextSpeed);
    }
  }

  @override
  Widget build(BuildContext context) {
    FlickVideoManager videoManager = Provider.of<FlickVideoManager>(context);
    _videoManager = videoManager;
    var playbackSpeed = videoManager.videoPlayerValue?.playbackSpeed;

    var child = Container(
        child: Column(
      children: [
        Icon(
          Icons.play_circle_outline_sharp,
          color: color,
        ),
        Text(playbackSpeed.toString() ?? ''),
      ],
    ));

    return FlickSetPlayBack(
      playBackChild: child,
      setPlayBack: changePlaybackSpeed,
      size: size,
    );
  }
}

class IMapleSkipNextVideo extends StatelessWidget {
  const IMapleSkipNextVideo({
    Key? key,
    this.size,
    this.color,
    this.padding,
  }) : super(key: key);

  final double? size;
  final Color? color;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    FlickControlManager controlManager = Provider.of<FlickControlManager>(context);
    FlickVideoManager videoManager = Provider.of<FlickVideoManager>(context);
    FlickPlayerManager flickPlayerManager = Provider.of<FlickPlayerManager>(context);

    return GestureDetector(
        key: key,
        onTap: () {
          flickPlayerManager.skipToNextVideo();
        },
        child: Container(
          padding: padding,
          child: Icon(
            Icons.skip_next_sharp,
            size: size,
            color: flickPlayerManager.canPlayNextVideo() ? color : Color.fromARGB(255, 130, 130, 130),
          ),
        ));
  }
}

class IMapleFlickLandscapeControls extends StatelessWidget {
  const IMapleFlickLandscapeControls({
    Key? key,
    this.iconSize = 30,
    this.fontSize = 14,
    this.progressBarSettings,
    this.playbackSpeedCallback,
  }) : super(key: key);

  /// Icon size.
  ///
  /// This size is used for all the player icons.
  final double iconSize;

  /// Font size.
  ///
  /// This size is used for all the text.
  final double fontSize;

  /// [FlickProgressBarSettings] settings.
  final FlickProgressBarSettings? progressBarSettings;
  final Function? playbackSpeedCallback;

  @override
  Widget build(BuildContext context) {
    FlickVideoManager videoManager = Provider.of<FlickVideoManager>(context);

    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: FlickAutoHideChild(
            child: Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black,
                      Colors.black26,
                      Colors.transparent,
                      Colors.transparent,
                    ],
                  )
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IMapleFlickVideoTitle(
                        textStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: FlickShowControlsAction(
            child: FlickSeekVideoAction(
              child: Center(
                child: FlickVideoBuffer(
                  child: FlickAutoHideChild(
                    showIfVideoNotInitialized: false,
                    child: FlickPlayToggle(
                      size: 30,
                      color: Colors.black,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white70,
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: FlickAutoHideChild(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  FlickVideoProgressBar(
                    flickProgressBarSettings: progressBarSettings,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      FlickPlayToggle(
                        size: iconSize,
                      ),
                      IMapleSkipNextVideo(
                        size: iconSize,
                        padding: EdgeInsets.fromLTRB(20, 0, 5, 0),
                      ),
                      SizedBox(
                        width: iconSize / 2,
                      ),
                      Row(
                        children: <Widget>[
                          IMapleFlickCurrentPosition(
                            fontSize: fontSize,
                          ),
                          FlickAutoHideChild(
                            child: Text(
                              ' / ',
                              style: TextStyle(color: Colors.white, fontSize: fontSize),
                            ),
                          ),
                          IMapleFlickTotalDuration(
                            fontSize: fontSize,
                          ),
                        ],
                      ),
                      Expanded(
                        child: Container(),
                      ),
                      IMapleSetPlaybackSpeed(
                        size: iconSize,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
