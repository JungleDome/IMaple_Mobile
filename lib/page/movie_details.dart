import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:imaplemobile/util/imapleManager.dart';
import 'package:collection/collection.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../player.dart';

class MovieDetail extends StatefulWidget {
  final String movieUrl;

  MovieDetail({Key? key, required this.movieUrl}) : super(key: key
  );

  @override
  MovieDetailState createState() =>
      MovieDetailState(movieUrl: movieUrl
      );
}

class MovieDetailState extends State<MovieDetail> with TickerProviderStateMixin {
  String movieUrl = '';

  MovieDetailState({required this.movieUrl}) {
    movieUrl = movieUrl;
  }

  final Movie movieMock = Movie(
      detailUrl: '/vod/50283.html',
      name: '名字:1号',
      author: '导演:周星驰',
      actor: '演员:李彦余',
      thumbnailUrl: 'https://via.placeholder.com/200x300.png?text=placeholder+image',
      description: 'desc',
      publishYear: '年份:2021',
      playlist: [
        Playlist('youku', {'episode 1': 'link1', 'episode 2': 'link2'}),
        Playlist('mango', {'episode 1': 'link1.1'})
      ]);

  var selectedSource = '';

  late var tabBarItem;
  late var tabBarViewItem;

  var _scrollViewController;
  var _tabController;
  var _imapleManager = IMapleManager();

  @override
  void initState() {
    super.initState();
    _scrollViewController = ScrollController();
    _tabController = TabController(vsync: this, length: 0
    );
  }

  @override
  void dispose() {
    _scrollViewController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData media = MediaQuery.of(context
    );
    var isHorizontal = media.orientation == Orientation.landscape;

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: _imapleManager.getMovie(movieUrl
          ),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var movie = snapshot.data as Movie;
              tabBarItem = movie.playlist
                  .map<Widget>(
                    (playlist) =>
                    Tab(
                      child: Container(
                        padding: EdgeInsets.only(left: 20, right: 20
                        ),
                        child: Text('${playlist.source}'
                        ),
                      ),
                    ),
              )
                  .toList();
              _tabController = TabController(vsync: this, length: tabBarItem.length
              );
              tabBarViewItem = movie.playlist.map<Widget>((item) {
                List<Widget> episodeButtons = [];

                item.episodeLink.forEach((key, value) {
                  episodeButtons.add(
                    TextButton(
                      style: TextButton.styleFrom(
                        primary: Colors.black,
                        textStyle: TextStyle(fontWeight: FontWeight.normal
                        ),
                      ),
                      onPressed: () {
                        print('play Episode: ${key}, Link: ${value}'
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                VideoApp(
                                  streamUrl: value,
                                ),
                          ),
                        );
                      },
                      child: FittedBox(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius: BorderRadius.circular(15
                            ),
                          ),
                          padding: const EdgeInsets.fromLTRB(15, 10, 15, 10
                          ),
                          //color: Colors.black26,
                          child: Center(
                            child: Text('${key}'
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }
                );

                var tabView = Wrap(
                  runSpacing: 20,
                  children: episodeButtons,
                );
                return tabView;
              }
              ).toList();

              return NestedScrollView(
                controller: _scrollViewController,
                headerSliverBuilder: (context, _) =>
                [
                  SliverAppBar(
                    pinned: false,
                    backgroundColor: Colors.white,
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.pin,
                      background: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            padding: EdgeInsets.only(left: 10, top: 10, right: 10
                            ),
                            width: MediaQuery
                                .of(context
                            )
                                .size
                                .width,
                            child: Flex(
                              direction: Axis.horizontal,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: isHorizontal ? 3 : 5,
                                  child: CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      placeholder: (context, _) =>
                                          Image(image: AssetImage('assets/images/load.png'
                                          )
                                          ),
                                      errorWidget: (context, url, err) =>
                                          Image(image: AssetImage('assets/images/load.png'
                                          )
                                          ),
                                      imageUrl: movie.thumbnailUrl
                                  ),
                                ),
                                Expanded(
                                  flex: isHorizontal ? 9 : 5,
                                  child: Container(
                                    padding: EdgeInsets.only(left: 10
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                            padding: EdgeInsets.only(bottom: 10
                                            ),
                                            child: Text(movie.name,
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme
                                                    .of(context
                                                )
                                                    .textTheme
                                                    .headline6
                                            )
                                        ),
                                        Padding(
                                            padding: EdgeInsets.only(bottom: 10
                                            ),
                                            child: Text(movie.author,
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme
                                                    .of(context
                                                )
                                                    .textTheme
                                                    .bodyText1
                                            )
                                        ),
                                        Padding(
                                            padding: EdgeInsets.only(bottom: 10
                                            ),
                                            child: Text(movie.actor,
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme
                                                    .of(context
                                                )
                                                    .textTheme
                                                    .bodyText1
                                            )
                                        ),
                                        Padding(
                                            padding: EdgeInsets.only(bottom: 10
                                            ),
                                            child: Text(movie.publishYear,
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme
                                                    .of(context
                                                )
                                                    .textTheme
                                                    .bodyText1
                                            )
                                        ),
                                        Padding(
                                            padding: EdgeInsets.only(bottom: 10
                                            ),
                                            child: Text(movie.description,
                                                overflow: TextOverflow.clip,
                                                style: Theme
                                                    .of(context
                                                )
                                                    .textTheme
                                                    .bodyText1
                                            )
                                        ),
                                        Padding(
                                            padding: EdgeInsets.only(bottom: 10
                                            ),
                                            child: Text(movie.lastUpdate,
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme
                                                    .of(context
                                                )
                                                    .textTheme
                                                    .bodyText1
                                            )
                                        ),
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
                      BoxDecoration(borderRadius: BorderRadius.circular(20
                      ), color: Colors.redAccent
                      ),
                      tabs: tabBarItem,
                    ),
                  ),
                ],
                body: Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10
                  ),
                  child: TabBarView(
                    controller: _tabController,
                    children: tabBarViewItem,
                  ),
                ),
              );
            }
            else if (snapshot.hasError) {
              return Text("${snapshot.error}"
              );
            }

            return Center(child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
