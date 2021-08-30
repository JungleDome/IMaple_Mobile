import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
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

    String textPosition =
    position != null ? '${position.inHours == 0 ? '' : '${addLeadingZero(position.inHours)}:'}${addLeadingZero(position.inMinutes.remainder(60))}:${addLeadingZero(position.inSeconds.remainder(60))}' : '--:--';

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

    String textDuration =
    duration != null ? '${duration.inHours == 0 ? '' : '${addLeadingZero(duration.inHours)}:'}${addLeadingZero(duration.inMinutes.remainder(60))}:${addLeadingZero(duration.inSeconds.remainder(60))}' : '--:--';

    return Text(
      textDuration,
      style: TextStyle(
        fontSize: fontSize,
        color: color,
      ),
    );
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

  Widget buildPlaybackButton(FlickVideoManager videoManager) {
    var playbackSpeed = videoManager.videoPlayerValue?.playbackSpeed;

    if (playbackSpeed == null) {
      return Container();
    }

    return Container(
      child: Text(playbackSpeed.toStringAsFixed(1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    FlickVideoManager videoManager = Provider.of<FlickVideoManager>(context);

    return Stack(
      children: <Widget>[
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
                      FlickSetPlayBack(
                        playBackChild: buildPlaybackButton(videoManager),
                        setPlayBack: playbackSpeedCallback,
                        size: iconSize,
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