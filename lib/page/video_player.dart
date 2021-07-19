import 'package:flutter/material.dart';
import 'package:imaplemobile/utils/imaple_manager.dart';
import 'package:imaplemobile/utils/storage_helper.dart';
import 'package:imaplemobile/widgets/better_video_player.dart';
import 'package:imaplemobile/widgets/flick_player.dart';

class VideoPlayer extends StatefulWidget {
  final String? streamUrl;
  final String? resumeStreamUrl;
  final int? playAtMillisecondDuration;

  VideoPlayer({Key? key, this.streamUrl, this.resumeStreamUrl, this.playAtMillisecondDuration})
      : super(key: key);

  @override
  _VideoPlayerState createState() => _VideoPlayerState(
      streamUrl: this.streamUrl,
      resumeStreamUrl: this.resumeStreamUrl,
      playAtMillisecondDuration: playAtMillisecondDuration);
}

class _VideoPlayerState extends State<VideoPlayer> {
  late BetterVideoPlayer betterVideoPlayer;
  //late VlcVideoPlayer vlcVideoPlayer;
  late FlickPlayer flickVideoPlayer;
  var setupDataSource = false;
  String? streamUrl;
  String? resumeStreamUrl;
  int? playAtMillisecondDuration;
  var _imapleManager = IMapleManager();
  late Future<MoviePlayDetail> movieStreamUrlFuture =
      streamUrl == null ? Future.value(MoviePlayDetail(streamUrl: '')) : _imapleManager.getMoviePlayLink(streamUrl!);

  _VideoPlayerState({this.streamUrl, this.resumeStreamUrl, this.playAtMillisecondDuration}) {
    streamUrl = streamUrl;
    resumeStreamUrl = resumeStreamUrl;
    playAtMillisecondDuration = playAtMillisecondDuration;
    if (streamUrl == null && resumeStreamUrl == null) {
      throw Exception('Stream url and resume stream url cannot be null.');
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: this.resumeStreamUrl != null
            ? () {
                if (!setupDataSource) {
                  flickVideoPlayer = FlickPlayer(
                    streamUrl: this.resumeStreamUrl!,
                    playAtMillisecondDuration: this.playAtMillisecondDuration,
                  );
                  setupDataSource = true;
                }

                return flickVideoPlayer;
              }()
            : FutureBuilder<MoviePlayDetail>(
                future: movieStreamUrlFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (!setupDataSource) {
                      //betterVideoPlayer = BetterVideoPlayer(streamUrl: snapshot.data!);
                      //vlcVideoPlayer = VlcVideoPlayer(streamUrl: snapshot.data!,);
                      StorageHelper.saveLastMovie('${snapshot.data!.movieName} (${snapshot.data!.episodeName})', this.streamUrl!);
                      flickVideoPlayer = FlickPlayer(
                        streamUrl: snapshot.data!.streamUrl,
                        playAtMillisecondDuration: this.playAtMillisecondDuration,
                      );
                      setupDataSource = true;
                    }

                    //return betterVideoPlayer;
                    //return vlcVideoPlayer;
                    return flickVideoPlayer;
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
}
