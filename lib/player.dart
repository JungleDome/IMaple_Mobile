import 'dart:math';

import 'package:better_player/better_player.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'utils/imaple_manager.dart';
import 'utils/storage_helper.dart';

class VideoPlayer extends StatefulWidget {
  final String streamUrl;
  final int? playAtMillisecondDuration;

  VideoPlayer({Key? key, required this.streamUrl, this.playAtMillisecondDuration}) : super(key: key);

  @override
  _VideoPlayerState createState() => _VideoPlayerState(streamUrl: this.streamUrl, playAtMillisecondDuration: playAtMillisecondDuration);
}

class _VideoPlayerState extends State<VideoPlayer> {
  late BetterPlayerController _betterPlayerController;
  var setupDataSource = false;
  var isControlVisible = true;
  var errorMessage = "";
  var streamUrl = '';
  int? playAtMillisecondDuration;
  var _imapleManager = IMapleManager();
  late Future<String> movieStreamUrlFuture = _imapleManager.getMoviePlayLink(streamUrl);

  _VideoPlayerState({required this.streamUrl, this.playAtMillisecondDuration}) {
    streamUrl = streamUrl;
    playAtMillisecondDuration = playAtMillisecondDuration;
  }

  @override
  void initState() {
    super.initState();
    BetterPlayerConfiguration betterPlayerConfiguration = BetterPlayerConfiguration(
      aspectRatio: 16 / 9,
      fit: BoxFit.contain,
      //fullScreenByDefault: true,
      //autoDetectFullscreenDeviceOrientation: true,
      autoPlay: true,
      errorBuilder: (context, errorMessage) {
        return Text(
            errorMessage ?? 'Sorry, there is an error playing the video.\n Please try another source.');
      },
      controlsConfiguration: BetterPlayerControlsConfiguration(
        enableFullscreen: false,
        enablePlaybackSpeed: true,
        forwardSkipTimeInMilliseconds: 10000,
        backwardSkipTimeInMilliseconds: 10000,
        enableSkips: false,
        enableRetry: true,
      ),
    );
    _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
    _betterPlayerController.addEventsListener((event) async {
      if (event.betterPlayerEventType == BetterPlayerEventType.exception) {
        if (event.parameters != null &&
            event.parameters!.containsKey("exception") &&
            event.parameters!["exception"].toString().contains("Source error")) {
          setState(() {
            errorMessage = '此资源无法播放哟! 请您选择另一个资源\n' +
                event.parameters!["exception"].toString();
          });
        }
      } else if (event.betterPlayerEventType == BetterPlayerEventType.controlsHidden) {
        SystemChrome.setEnabledSystemUIOverlays([]);
        isControlVisible = false;
      } else if (event.betterPlayerEventType == BetterPlayerEventType.controlsVisible) {
        isControlVisible = true;
      } else if (event.betterPlayerEventType == BetterPlayerEventType.progress) {
        //print("Progress: ${event.parameters.toString()}");
        EasyDebounce.debounce('videoProgress', Duration(milliseconds: 1000), () async {
          var duration = (event.parameters?.entries.firstWhere((e) => e.key == 'duration', orElse: () => {'duration': null}.entries.first).value as Duration?);
          if (duration != null) {
            await StorageHelper.storage.setItem('lastPlayStreamUrl', streamUrl);
            await StorageHelper.storage.setItem('lastPlayDuration',
                (event.parameters?.entries.firstWhere((e) => e.key == 'progress').value as Duration).inMilliseconds);
            //print('Saved last play');
          }
        });
      } else if (event.betterPlayerEventType == BetterPlayerEventType.finished) {
        //print("Finished video");
        await StorageHelper.storage.deleteItem('lastPlayStreamUrl');
        await StorageHelper.storage.deleteItem('lastPlayDuration');
        await StorageHelper.storage.deleteItem('lastPlayName');
      } else if (event.betterPlayerEventType == BetterPlayerEventType.initialized) {
        if (playAtMillisecondDuration != null) {
          _betterPlayerController.videoPlayerController!.seekTo(Duration(milliseconds: playAtMillisecondDuration!));
        }
      }
      //print("Better player event: ${event.betterPlayerEventType}");
    });
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    SystemChrome.setEnabledSystemUIOverlays([]);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: FutureBuilder<String>(
          future: movieStreamUrlFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (!_betterPlayerController.hasCurrentDataSourceStarted) {
                BetterPlayerDataSource dataSource = BetterPlayerDataSource(
                  BetterPlayerDataSourceType.network,
                  snapshot.data!,
                  cacheConfiguration: BetterPlayerCacheConfiguration(
                    useCache: true,
                    preCacheSize: 10 * 1024 * 1024,
                    //(10mb)
                    maxCacheSize: 10 * 1024 * 1024,
                    maxCacheFileSize: 10 * 1024 * 1024,

                    ///Android only option to use cached video between app sessions
                    key: "testCacheKey",
                  ),
                );
                _betterPlayerController.setupDataSource(dataSource);
                //_betterPlayerController.hasCurrentDataSourceStarted;
                //setupDataSource = true;
              }

              return errorMessage == ""
                  ? SizedBox(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: Stack(
                        children: [
                          Align(
                            child: BetterPlayer(controller: _betterPlayerController),
                          ),
                          Flex(
                            direction: Axis.horizontal,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: EdgeInsets.only(top: 50, bottom: 50),
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      _betterPlayerController.setControlsVisibility(!isControlVisible);
                                    },
                                    onDoubleTap: () {
                                      final videoPlayerController =
                                          _betterPlayerController.videoPlayerController!.value;
                                      final beginning = const Duration().inMilliseconds;
                                      final skip = (videoPlayerController.position -
                                              Duration(
                                                  milliseconds: _betterPlayerController
                                                      .betterPlayerConfiguration
                                                      .controlsConfiguration
                                                      .backwardSkipTimeInMilliseconds))
                                          .inMilliseconds;
                                      _betterPlayerController
                                          .seekTo(Duration(milliseconds: max(skip, beginning)));
                                    },
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: EdgeInsets.only(top: 50, bottom: 50),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: EdgeInsets.only(top: 50, bottom: 50),
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      _betterPlayerController.setControlsVisibility(!isControlVisible);
                                    },
                                    onDoubleTap: () {
                                      final videoPlayerController =
                                          _betterPlayerController.videoPlayerController!.value;
                                      final end = videoPlayerController.duration!.inMilliseconds;
                                      final skip = (videoPlayerController.position +
                                              Duration(
                                                  milliseconds: _betterPlayerController
                                                      .betterPlayerConfiguration
                                                      .controlsConfiguration
                                                      .forwardSkipTimeInMilliseconds))
                                          .inMilliseconds;
                                      _betterPlayerController.seekTo(Duration(milliseconds: min(skip, end)));
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )

//              Expanded(
//                      child: BetterPlayer(controller: _betterPlayerController),
//                    )
                  : Container(
                      alignment: Alignment.center,
                      child: Text(errorMessage,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headline6!.copyWith(color: Colors.red)));
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }

            // By default, show a loading spinner.
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _betterPlayerController.dispose();
    super.dispose();
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top, SystemUiOverlay.bottom]);
  }
}
