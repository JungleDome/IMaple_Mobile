import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:imaplemobile/model/movie_storage.dart';
import 'package:imaplemobile/utils/imaple_manager.dart';
import 'package:imaplemobile/widgets/better_video_player.dart';
import 'package:imaplemobile/widgets/flick_player.dart';
import 'package:video_player/video_player.dart';

typedef void ChangeNextEpisodeCallback(FlickManager videoManager, VoidCallback dataSourceChangedCallback);

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
  String? streamUrl; // ../play/xxx-x
  String? resumeStreamUrl; // ../xxx.m3u8
  int? playAtMillisecondDuration;
  String? nextEpisodePlayLink; // ../play/xxx-x
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

  FlickManager? flickManager;
  VoidCallback? dataSourceChangedCallback;
  void getNextEpisodePlayUrl(FlickManager videoManager, VoidCallback dataSourceChangedCallback) {
    if (nextEpisodePlayLink != null && setupDataSource) {
      print('change stream url future');
      flickManager = videoManager;
      this.dataSourceChangedCallback = dataSourceChangedCallback;
      setupDataSource = false;
      streamUrl = nextEpisodePlayLink;
      movieStreamUrlFuture = _imapleManager.getMoviePlayLink(nextEpisodePlayLink!);
      setState(() {});
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
        child: FutureBuilder<MoviePlayDetail>(
                future: movieStreamUrlFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (!setupDataSource) {
                      print('setup video player');
                      //betterVideoPlayer = BetterVideoPlayer(streamUrl: snapshot.data!);
                      //vlcVideoPlayer = VlcVideoPlayer(streamUrl: snapshot.data!,);
                      MovieStorage.instance.lastPlayName = '${snapshot.data!.movieName} ${snapshot.data!.episodeName.isEmpty ? '' : '(${snapshot.data!.episodeName})' }';
                      MovieStorage.instance.lastPlayPlayUrl = this.streamUrl!;
                      MovieStorage.save();
                      nextEpisodePlayLink = snapshot.data!.nextEpisodePlayLink;
                      flickVideoPlayer = FlickPlayer(
                        streamUrl: snapshot.data!.streamUrl,
                        playAtMillisecondDuration: this.playAtMillisecondDuration,
                        nextEpisodePlayLink: snapshot.data!.nextEpisodePlayLink,
                        hasNextEpisode: snapshot.data!.nextEpisodePlayLink != "",
                        playNextEpisodeCallback: getNextEpisodePlayUrl,
                      );
                      setupDataSource = true;
                      if (flickManager != null) {//not null when is playing next video
                        if (flickManager?.flickVideoManager?.videoPlayerController?.dataSource == snapshot.data!.streamUrl) {//compulsory check to ensure the data source is correct
                          setupDataSource = false;
                        } else {
                          print('change video to ' + snapshot.data!.streamUrl + ', episode :' + snapshot.data!.episodeName);
                          flickManager!.handleChangeVideo(VideoPlayerController.network(snapshot.data!.streamUrl));
                          this.dataSourceChangedCallback!();
                        }
                      }
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
