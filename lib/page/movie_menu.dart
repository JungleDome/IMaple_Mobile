import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:imaplemobile/page/movie_details.dart';
import 'package:imaplemobile/util/imapleManager.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MovieMenu extends StatefulWidget {
  @override
  MovieMenuState createState() => MovieMenuState();
}

class MovieMenuState extends State<MovieMenu> {
  static const _pageSize = 48;

  final PagingController<int, Movie> _pagingController = PagingController(firstPageKey: 1);
  final _imapleManager = IMapleManager();

  final List<String> entries = <String>['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J'];

  var movieType = MovieType.Movie;

  //var menuItems = _imapleManager.getMovieMenuItem(MovieType.Movie);
  String selectedMovieCategoryLink = '/show/1.html';

  Future<void> _fetchPage(int pageKey) async {
    try {
      print('PageKey: ${pageKey}');
      final newItems =
          await _imapleManager.getMovieList(pageLink: selectedMovieCategoryLink, pageNumber: pageKey);
      final isLastPage = newItems.currentPage == newItems.maxPage;
      final itemsList = newItems.items.map((item) => item.movie).toList();
      if (isLastPage) {
        _pagingController.appendLastPage(itemsList);
      } else {
        _pagingController.appendPage(itemsList, pageKey + 1);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  void _changeMovieMenuItem(String categoryUrl) {
    selectedMovieCategoryLink = categoryUrl;
    _pagingController.refresh();
  }

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData media = MediaQuery.of(context);
    var isHorizontal = media.orientation == Orientation.landscape;

    return isHorizontal
        ? Scaffold(
            body: SafeArea(
              child: FutureBuilder(
                future: _imapleManager.getMovieMenuItem(movieType),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final movieMenuItem = snapshot.data as List<MenuItem>;
                    if (movieMenuItem.length == 0)
                      return Text("No category list for this item. \n Please select another category.");
                    return Flex(
                      verticalDirection: VerticalDirection.down,
                      direction: Axis.horizontal,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          flex: 2,
                          child: ListView.separated(
                            padding: EdgeInsets.only(left: 5, top: 10, bottom: 10, right: 1),
                            scrollDirection: Axis.vertical,
                            itemCount: movieMenuItem.length,
                            itemBuilder: (BuildContext context, int index) {
                              return TextButton(
                                style: TextButton.styleFrom(
                                  primary: Colors.black,
                                  textStyle: TextStyle(fontWeight: FontWeight.normal),
                                ),
                                onPressed: () {
                                  print('pressed ${movieMenuItem[index].genreName}'
                                  );
                                  _changeMovieMenuItem(movieMenuItem[index].urlLink
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                                  //color: Colors.black26,
                                  child: Center(
                                    child: Text('${movieMenuItem[index].genreName}'
                                    ),
                                  ),
                                ),
                              );
                            },
                            separatorBuilder: (BuildContext context, int index) =>
                                Container(padding: const EdgeInsets.all(10)),
                          ),
                        ),
                        VerticalDivider(color: Colors.grey),
                        Expanded(
                          flex: 10,
                          child: Container(
                            child: PagedGridView<int, Movie>(
                              padding: EdgeInsets.only(top: 10, bottom: 10, right: 10),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: (media.size.width / 220).round(),
                                  crossAxisSpacing: 15,
                                  mainAxisSpacing: 20,
                                  childAspectRatio: 0.6),
                              pagingController: _pagingController,
                              builderDelegate: PagedChildBuilderDelegate<Movie>(
                                itemBuilder: (context, item, index) {
                                  return Container(
                                    child: FittedBox(
                                      fit: BoxFit.fill,
                                      alignment: Alignment.center,
                                      child: Center(
                                        child: TextButton(
                                          style: TextButton.styleFrom(
                                              primary: Colors.black,
                                              textStyle: TextStyle(fontWeight: FontWeight.normal
                                              )
                                          ),
                                          onPressed: () {
                                            print('pressed ${item.name}'
                                            );
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    MovieDetail(
                                                      movieUrl: item.detailUrl,
                                                    ),
                                              ),
                                            );
                                          },
                                          child: Column(
                                            children: [
                                              Container(
                                                width: 300,
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
                                                    imageUrl: item.thumbnailUrl
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.only(top: 10, bottom: 2
                                                ),
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                    bottom: BorderSide(
                                                      color: Colors.black38,
                                                      width: 1.0, // Underline thickness
                                                    ),
                                                  ),
                                                ),
                                                child: Text(item.name
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }
                  // By default, show a loading spinner.
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
          )
        : Scaffold(
            body: SafeArea(
              child: FutureBuilder(
                future: _imapleManager.getMovieMenuItem(movieType
                ),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final movieMenuItem = snapshot.data as List<MenuItem>;
                    if (movieMenuItem.length == 0)
                      return Text("No category list for this item. \n Please select another category."
                      );
                    return Column(
                      verticalDirection: VerticalDirection.down,
                      //direction: Axis.vertical,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          padding: EdgeInsets.only(top: 5, bottom: 5
                          ),
                          //width: media.size.width,
                          height: 61,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.black38,
                                width: 1.0, // Underline thickness
                              ),
                            ),
                          ),
                          child: ListView.separated(
                            padding: EdgeInsets.only(left: 5, right: 5
                            ),
                            scrollDirection: Axis.horizontal,
                            itemCount: entries.length,
                            itemBuilder: (BuildContext context, int index) {
                              return TextButton(
                                style: TextButton.styleFrom(
                                  primary: Colors.black,
                                  textStyle: TextStyle(fontWeight: FontWeight.normal
                                  ),
                                ),
                                onPressed: () {
                                  print('pressed ${movieMenuItem[index].genreName}'
                                  );
                                  _changeMovieMenuItem(movieMenuItem[index].urlLink
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(),
                                    borderRadius: BorderRadius.circular(15
                                    ),
                                  ),
                                  padding: const EdgeInsets.fromLTRB(10, 5, 10, 5
                                  ),
                                  //color: Colors.black26,
                                  child: Center(
                                    child: Text('${movieMenuItem[index].genreName}'
                                    ),
                                  ),
                                ),
                              );
                            },
                            separatorBuilder: (BuildContext context, int index) =>
                                Container(padding: const EdgeInsets.only(left: 5
                                )
                                ),
                          ),
                        ),
                        Expanded(
                          //flex: 10,
                          child: Container(
                            child: PagedGridView<int, Movie>(
                              padding: EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 5
                              ),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: (media.size.width / 220).round(),
                                  crossAxisSpacing: 15,
                                  mainAxisSpacing: 20,
                                  childAspectRatio: 0.6
                              ),
                              pagingController: _pagingController,
                              builderDelegate: PagedChildBuilderDelegate<Movie>(
                                itemBuilder: (context, item, index) {
                                  return Container(
                                    child: FittedBox(
                                      fit: BoxFit.fill,
                                      alignment: Alignment.center,
                                      child: Center(
                                        child: TextButton(
                                          style: TextButton.styleFrom(
                                              primary: Colors.black,
                                              textStyle: TextStyle(fontWeight: FontWeight.normal
                                              )
                                          ),
                                          onPressed: () {
                                            print('pressed ${item.name}'
                                            );
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    MovieDetail(
                                                      movieUrl: item.detailUrl,
                                                    ),
                                              ),
                                            );
                                          },
                                          child: Column(
                                            children: [
                                              Container(
                                                width: 300,
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
                                                    imageUrl: item.thumbnailUrl
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.only(top: 10, bottom: 2
                                                ),
                                                decoration: BoxDecoration(
                                                    border: Border(
                                                        bottom: BorderSide(
                                                          color: Colors.black38,
                                                          width: 1.0, // Underline thickness
                                                        )
                                                    )
                                                ),
                                                child: Text(item.name
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  else if (snapshot.hasError) {
                    return Text("${snapshot.error}"
                    );
                  }
                  // By default, show a loading spinner.
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
          );
  }
}
