import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:imaplemobile/model/movie_storage.dart';
import 'package:imaplemobile/page/video_player.dart';
import 'package:imaplemobile/utils/imaple_manager.dart';

class MovieDetail extends StatefulWidget {
  final String movieUrl;

  MovieDetail({Key? key, required this.movieUrl}) : super(key: key);

  @override
  MovieDetailState createState() => MovieDetailState(movieUrl: movieUrl);
}

class MovieDetailState extends State<MovieDetail> with TickerProviderStateMixin {
  String movieUrl = '';

  MovieDetailState({required this.movieUrl}) {
    movieUrl = movieUrl;
  }

  var selectedSource = '';

  late List<Widget> tabBarItem = List.empty();
  late List<Widget> tabBarViewItem = List.empty();

  var _scrollViewController;
  var _tabController;
  var _imapleManager = IMapleManager();
  late Future<Movie> fetchMovieDetail = _imapleManager.getMovie(movieUrl);

  @override
  void initState() {
    super.initState();
    _scrollViewController = ScrollController();
    _tabController = TabController(vsync: this, length: 0);
  }

  @override
  void dispose() {
    _scrollViewController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData media = MediaQuery.of(context);
    var isHorizontal = media.orientation == Orientation.landscape;

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: fetchMovieDetail,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var movie = snapshot.data as Movie;
              if (tabBarItem.isEmpty) {
                tabBarItem = movie.playlist
                    .map<Widget>(
                      (playlist) => Tab(
                        child: Container(
                          padding: EdgeInsets.only(left: 20, right: 20),
                          child: Text('${playlist.source}'),
                        ),
                      ),
                    )
                    .toList();
                _tabController = TabController(vsync: this, length: tabBarItem.length);
              }

              if (tabBarViewItem.isEmpty) {
                tabBarViewItem = movie.playlist.map<Widget>((item) {
                  List<Widget> episodeButtons = [];

                  item.episodeLink.forEach((key, value) {
                    episodeButtons.add(
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          primary: Colors.black,
                          textStyle: TextStyle(fontWeight: FontWeight.normal),
                        ).copyWith(
                          overlayColor: MaterialStateProperty.all(Colors.red.shade100),
                        ),
                        onPressed: () {
                          //print('play Episode: ${key}, Link: ${value}');
                          //StorageHelper.saveLastMovie('${movie.name} (${key})', movieUrl);
                          MovieStorage.instance.lastPlayDetailUrl = movie.detailUrl;
                          MovieStorage.save();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VideoPlayer(
                                streamUrl: value,
                              ),
                            ),
                          );
                        },
                        child: FittedBox(
                          child: Container(
                            // decoration: BoxDecoration(
                            //   border: Border.all(),
                            //   borderRadius: BorderRadius.circular(15),
                            // ),
                            // padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                            //color: Colors.black26,
                            child: Center(
                              child: Text('${key}'),
                            ),
                          ),
                        ),
                      ),
                    );
                  });

                  var tabView = Wrap(
                    spacing: 20,
                    runSpacing: 10,
                    children: episodeButtons,
                  );
                  return tabView;
                }).toList();
              }

              return NestedScrollView(
                controller: _scrollViewController,
                headerSliverBuilder: (context, _) => [
                  SliverAppBar(
                    pinned: false,
                    automaticallyImplyLeading: false,
                    backgroundColor: Colors.white,
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.pin,
                      background: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            padding: EdgeInsets.only(left: 10, top: 10, right: 10),
                            width: MediaQuery.of(context).size.width,
                            child: Flex(
                              direction: Axis.horizontal,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: isHorizontal ? 3 : 5,
                                  child: CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      placeholder: (context, _) =>
                                          Image(image: AssetImage('assets/images/load.png')),
                                      errorWidget: (context, url, err) =>
                                          Image(image: AssetImage('assets/images/load.png')),
                                      imageUrl: movie.thumbnailUrl),
                                ),
                                Expanded(
                                  flex: isHorizontal ? 9 : 5,
                                  child: Container(
                                    padding: EdgeInsets.only(left: 10),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                            padding: EdgeInsets.only(bottom: 10),
                                            child: Text(movie.name,
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context).textTheme.headline6)),
                                        Padding(
                                            padding: EdgeInsets.only(bottom: 10),
                                            child: Text(movie.author,
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context).textTheme.bodyText1)),
                                        Padding(
                                            padding: EdgeInsets.only(bottom: 10),
                                            child: Text(movie.actor,
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context).textTheme.bodyText1)),
                                        Padding(
                                            padding: EdgeInsets.only(bottom: 10),
                                            child: Text(movie.publishYear,
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context).textTheme.bodyText1)),
                                        Padding(
                                            padding: EdgeInsets.only(bottom: 10),
                                            child: Text(movie.description,
                                                overflow: TextOverflow.clip,
                                                style: Theme.of(context).textTheme.bodyText1)),
                                        Padding(
                                            padding: EdgeInsets.only(bottom: 10),
                                            child: Text(movie.lastUpdate,
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context).textTheme.bodyText1)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    expandedHeight: 400.0,
                    bottom: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      unselectedLabelColor: Colors.redAccent,
                      indicatorSize: TabBarIndicatorSize.label,
                      indicator:
                          BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.redAccent),
                      tabs: tabBarItem,
                    ),
                  ),
                ],
                body: Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: TabBarView(
                    controller: _tabController,
                    children: tabBarViewItem,
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }

            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
