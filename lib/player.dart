import 'package:flutter/material.dart';
import 'package:better_player/better_player.dart';
import 'util/imapleManager.dart';
import 'package:flutter/services.dart';

class VideoApp extends StatefulWidget {
  final String streamUrl;

  VideoApp({Key? key, required this.streamUrl}) : super(key: key
  );

  @override
  _VideoAppState createState() =>
      _VideoAppState(streamUrl: this.streamUrl
      );
}

class _VideoAppState extends State<VideoApp> {
  late BetterPlayerController _betterPlayerController;
  late Future<String> movieStreamUrlFuture;
  var setupDataSource = false;
  var errorMessage = "";
  var streamUrl = '';
  var _imapleManager = IMapleManager();

  _VideoAppState({required this.streamUrl}) {
    streamUrl = streamUrl;
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
            errorMessage ?? 'Sorry, there is an error playing the video.\n Please try another source.'
        );
      },
      controlsConfiguration: BetterPlayerControlsConfiguration(
        enableFullscreen: false,
        enablePlaybackSpeed: true,
        forwardSkipTimeInMilliseconds: 10000,
        backwardSkipTimeInMilliseconds: 10000,

      ),
    );
    _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
    _betterPlayerController.addEventsListener((event) {
      if (event.betterPlayerEventType == BetterPlayerEventType.exception) {
        if (event.parameters != null &&
            event.parameters!.containsKey("exception") &&
            event.parameters!["exception"].toString().contains("Source error"
            )) {
          setState(() {
            errorMessage = 'Sorry, this video source is invalid.\n Please try another source.';
          });
        }
      }
      else if (event.betterPlayerEventType == BetterPlayerEventType.controlsHidden) {
        SystemChrome.setEnabledSystemUIOverlays([]
        );
      }
      print("Better player event: ${event.betterPlayerEventType}");
    });
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]
    );
    SystemChrome.setEnabledSystemUIOverlays([]
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: FutureBuilder<String>(
          future: _imapleManager.getMoviePlayLink(streamUrl
          ),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              BetterPlayerDataSource dataSource = BetterPlayerDataSource(
                BetterPlayerDataSourceType.network,
                snapshot.data!,
                cacheConfiguration: BetterPlayerCacheConfiguration(
                  useCache: true,
                  preCacheSize: 10 * 1024 * 1024,
                  maxCacheSize: 10 * 1024 * 1024,
                  maxCacheFileSize: 10 * 1024 * 1024,

                  ///Android only option to use cached video between app sessions
                  key: "testCacheKey",
                ),
              );
              _betterPlayerController.setupDataSource(dataSource
              );
              setupDataSource = true;
              return errorMessage == ""
                  ? Expanded(
                child: BetterPlayer(controller: _betterPlayerController
                ),
              )
                  : Container(
                  alignment: Alignment.center,
                  child: Text(errorMessage,
                      textAlign: TextAlign.center,
                      style: Theme
                          .of(context
                      )
                          .textTheme
                          .headline6!
                          .copyWith(color: Colors.red
                      )
                  )
              );
            }
            else if (snapshot.hasError) {
              return Text("${snapshot.error}"
              );
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
    ]
    );
    _betterPlayerController.dispose();
    super.dispose();
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top, SystemUiOverlay.bottom]
    );
  }
}
