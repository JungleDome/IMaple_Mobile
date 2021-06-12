import 'package:flutter/material.dart';
import 'package:better_player/better_player.dart';
import 'util/imapleManager.dart';

void main() => runApp(VideoApp());

class VideoApp extends StatefulWidget {
  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  late BetterPlayerController _betterPlayerController;
  late Future<String> movieStreamUrlFuture;
  var setupDataSource = false;
  var errorMessage = "";

  @override
  void initState() {
    super.initState();
    var movieDetails = IMapleManager().getMovie();
    movieStreamUrlFuture = movieDetails.then((movie) {
      var episodeLink = movie.playlist.length >= 2
          ? movie.playlist.elementAt(1).episodeLink[
                  movie.playlist.elementAt(1).episodeLink.keys.toList()[0]] ??
              ''
          : '';
      var streamRealUrl = IMapleManager().getMoviePlayLink(episodeLink);
      return streamRealUrl;
    });
    BetterPlayerConfiguration betterPlayerConfiguration =
        BetterPlayerConfiguration(
            aspectRatio: 16 / 9,
            fit: BoxFit.contain,
            //fullScreenByDefault: true,
            autoDetectFullscreenDeviceOrientation: true,
            autoPlay: true,
            errorBuilder: (context, errorMessage) {
              return Text(errorMessage ??
                  'Sorry, there is an error playing the video.\n Please try another source.');
            },
            controlsConfiguration: BetterPlayerControlsConfiguration(
              //enableQualities: true,
              //showControlsOnInitialize: true,
            ));
    _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
    _betterPlayerController.addEventsListener((event) {
      if (event.betterPlayerEventType == BetterPlayerEventType.exception) {
        if (event.parameters != null &&
            event.parameters!.containsKey("exception") &&
            event.parameters!["exception"]
                .toString()
                .contains("Source error")) {
          setState(() {
            errorMessage = 'Sorry, this video source is invalid.\n Please try another source.';
          });
        }
      }
      print("Better player event: ${event.betterPlayerEventType}");
    });
    setState(() {});
//    super.initState();
//    _controller = VideoPlayerController.network('http://static.france24.com/live/F24_EN_LO_HLS/live_web.m3u8')
//      ..initialize().then((_) {
//        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
//        setState(() {});
//      });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Demo',
      home: Scaffold(
        body: Center(
          child: FutureBuilder<String>(
            future: movieStreamUrlFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                BetterPlayerDataSource dataSource = BetterPlayerDataSource(
                  BetterPlayerDataSourceType.network,
                  snapshot.data!,
                  useAsmsSubtitles: true,
                  //useAsmsTracks: true,
                  cacheConfiguration: BetterPlayerCacheConfiguration(
                    useCache: true,
                    preCacheSize: 10 * 1024 * 1024,
                    maxCacheSize: 10 * 1024 * 1024,
                    maxCacheFileSize: 10 * 1024 * 1024,

                    ///Android only option to use cached video between app sessions
                    key: "testCacheKey",
                  ),
                );
                _betterPlayerController.setupDataSource(dataSource);
                setupDataSource = true;
                return _betterPlayerController.isVideoInitialized()! &&
                        errorMessage == ""
                    ? AspectRatio(
                        aspectRatio: 16 / 9,
                        child:
                            BetterPlayer(controller: _betterPlayerController),
                      )
                    : Container(
                        alignment: Alignment.center,
                        child: Text(errorMessage,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .headline6!
                                .copyWith(color: Colors.red)));
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }

              // By default, show a loading spinner.
              return CircularProgressIndicator();
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: 'btn1',
          onPressed: () {
            setState(() {
              setupDataSource && _betterPlayerController.isPlaying()!
                  ? _betterPlayerController.pause()
                  : _betterPlayerController.play();
            });
          },
          child: Icon(
            setupDataSource && _betterPlayerController.isPlaying()!
                ? Icons.pause
                : Icons.play_arrow,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _betterPlayerController.dispose();
  }
}
