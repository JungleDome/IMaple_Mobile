import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:imaplemobile/util/imapleManager.dart';
import 'package:collection/collection.dart';

class MovieDetail extends StatefulWidget {
  @override
  MovieDetailState createState() => MovieDetailState();
}

class MovieDetailState extends State<MovieDetail> with TickerProviderStateMixin {
  final Movie movie = Movie(
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

  @override
  void initState() {
    super.initState();
    _scrollViewController = ScrollController();
    _tabController = TabController(vsync: this, length: 2);
    // init item
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
    tabBarViewItem = movie.playlist.map<Widget>((item) {
      List<Widget> episodeButtons = [];

      item.episodeLink.forEach((key, value) {
        episodeButtons.add(
          TextButton(
            style: TextButton.styleFrom(
              primary: Colors.black,
              textStyle: TextStyle(fontWeight: FontWeight.normal),
            ),
            onPressed: () {
              print('play Episode: ${key}, Link: ${value}');
            },
            child: Text('${key}'),
          ),
        );
      });

      var tabView = Wrap(
        runSpacing: 20,
        children: episodeButtons,
      );
      return tabView;
    }).toList();
  }

  @override
  void dispose() {
    _scrollViewController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          controller: _scrollViewController,
          headerSliverBuilder: (context, _) => [
            SliverAppBar(
              pinned: false,
              backgroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: Column(
                  children: [
                    Container(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FadeInImage.assetNetwork(
                              fit: BoxFit.cover, placeholder: 'Loading...', image: movie.thumbnailUrl),
                          Container(
                            padding: EdgeInsets.only(left: 10, top: 5),
                            child: Column(
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
                                        style: Theme.of(context).textTheme.headline6)),
                                Padding(
                                    padding: EdgeInsets.only(bottom: 10),
                                    child: Text(movie.actor,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context).textTheme.headline6)),
                                Padding(
                                    padding: EdgeInsets.only(bottom: 10),
                                    child: Text(movie.publishYear,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context).textTheme.headline6)),
                                Padding(
                                    padding: EdgeInsets.only(bottom: 10),
                                    child: Text(movie.description,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context).textTheme.headline6)),
                                Padding(
                                    padding: EdgeInsets.only(bottom: 10),
                                    child: Text(movie.lastUpdate,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context).textTheme.headline6)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              expandedHeight: 380.0,
              bottom: TabBar(
                controller: _tabController,
                isScrollable: true,
                unselectedLabelColor: Colors.redAccent,
                indicatorSize: TabBarIndicatorSize.label,
                indicator: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.redAccent),
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
        ),
      ),
    );
  }
}
