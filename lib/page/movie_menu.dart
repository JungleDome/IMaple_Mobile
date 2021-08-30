import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:imaplemobile/page/movie_details.dart';
import 'package:imaplemobile/utils/future_helper.dart';
import 'package:imaplemobile/utils/imaple_manager.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class MovieMenu extends StatefulWidget {
  final MovieType movieType;

  MovieMenu({Key? key, required this.movieType}) : super(key: key);

  @override
  MovieMenuState createState() => MovieMenuState(movieType: movieType);
}

class MovieMenuState extends State<MovieMenu> {
  MovieType? movieType;

  MovieMenuState({required this.movieType}) {
    movieType = movieType;
  }

  final PagingController<int, Movie> _pagingController = PagingController(firstPageKey: 1);
  final _imapleManager = IMapleManager();
  String selectedMovieCategoryLink = '';
  var showFilterMenu = false;
  var enableFilterMenu = false;
  final filterYear = ['2021', '2020', '2019', '2018', '2017'];
  final filterLang_movie = ['國語', '英語', '粵語', '閩南語', '韓語', '日語', '法語', '德語', '其它'];
  final filterLang_drama = ['國語', '英語', '粵語', '閩南語', '韓語', '日語', '其它'];
  final filterLocation = ['大陸', '香港', '台灣', '美國', '英國', '法國', '日本', '韓國'];

  late Future<dynamic> fetchMenuCategoryItem;

  Future<void> _fetchPage(int pageKey) async {
    if (selectedMovieCategoryLink == '') return;

    try {
      //print('PageKey: ${pageKey}');
      SearchResult newItems = await FutureHelper.retry(
          3, _imapleManager.getMovieList(pageLink: selectedMovieCategoryLink, pageNumber: pageKey),
          delay: Duration(seconds: 5));
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
    if (categoryUrl == 'custom_filter') {
      setState(() {
        showFilterMenu = !showFilterMenu;
      });
    } else {
      selectedMovieCategoryLink = categoryUrl;
      _pagingController.refresh();
    }
  }

  List<Widget> buildFilterButton(String item, Iterable list) {
    return list.map((e) {
      return ConstrainedBox(
        constraints: BoxConstraints.loose(Size.fromWidth(100)),
        child: TextButton(
          style: TextButton.styleFrom(
            primary: Colors.black,
            textStyle: TextStyle(fontWeight: FontWeight.normal),
          ),
          onPressed: () {
            //print('pressed ${e}');
            //_addFilter
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white70,
              ),
            ),
            padding: const EdgeInsets.all(10),
            //color: Colors.black26,
            child: Center(
              child: Text(
                '${e}',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  @override
  void initState() {
    fetchMenuCategoryItem =
        FutureHelper.retry(3, _imapleManager.getMovieMenuItem(movieType!), delay: Duration(seconds: 5));
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

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/background.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: FutureBuilder(
            future: fetchMenuCategoryItem,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // By default, show a loading spinner.
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              var movieMenuItem = <MenuItem>[];
              if (snapshot.hasData) {
                movieMenuItem = snapshot.data as List<MenuItem>;
                if (movieMenuItem.length > 0) {
                  if (enableFilterMenu) {
                    if (movieMenuItem.indexWhere((element) => element.urlLink == 'custom_filter') == -1) {
                      movieMenuItem.insert(0, MenuItem('筛选', 'custom_filter'));
                      _changeMovieMenuItem(movieMenuItem[1].urlLink); //trigger load item
                    }
                  } else {
                    _changeMovieMenuItem(movieMenuItem[0].urlLink); //trigger load item
                  }
                }
              }
              final showError = snapshot.hasError || movieMenuItem.length == 0;
              return isHorizontal
                  ? Flex(
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
                                  primary: Colors.white,
                                  textStyle: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                onPressed: () {
                                  //print('pressed ${movieMenuItem[index].genreName}');
                                  _changeMovieMenuItem(movieMenuItem[index].urlLink);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white,),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                                  //color: Colors.black26,
                                  child: Center(
                                    child: Text(
                                      '${movieMenuItem[index].genreName}',
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
                        snapshot.hasError
                            ? Center(
                                child: Column(
                                  children: [
                                    Text("${snapshot.error}"),
                                  ],
                                ),
                              )
                            : Container(),
                        movieMenuItem.length == 0
                            ? Center(
                                child: Column(
                                  children: [
                                    Text("No category list for this item. \n Please select another category.")
                                  ],
                                ),
                              )
                            : Container(),
                        showError
                            ? Container()
                            : Expanded(
                                flex: 10,
                                child: Stack(
                                  children: [
                                    Container(
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
                                                        primary: Colors.white,
                                                        textStyle: TextStyle(fontWeight: FontWeight.normal,fontSize: 14, color: Colors.white,),),
                                                    onPressed: () {
                                                      //print('pressed ${item.name}');
                                                      if (item.detailUrl != '') {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) => MovieDetail(
                                                              movieUrl: item.detailUrl,
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    },
                                                    child: Column(
                                                      children: [
                                                        Container(
                                                          width: 300,
                                                          child: CachedNetworkImage(
                                                              fit: BoxFit.none,
                                                              placeholder: (context, _) => Image(
                                                                  image:
                                                                      AssetImage('assets/images/load.png')),
                                                              errorWidget: (context, url, err) => Image(
                                                                  image:
                                                                      AssetImage('assets/images/load.png')),
                                                              imageUrl: item.thumbnailUrl),
                                                        ),
                                                        Container(
                                                          padding: const EdgeInsets.only(top: 10, bottom: 2),
                                                          decoration: BoxDecoration(
                                                            border: Border(
                                                              bottom: BorderSide(
                                                                color: Colors.white,
                                                                width: 1.0, // Underline thickness
                                                              ),
                                                            ),
                                                          ),
                                                          child: Text(item.name,
                                                              style: Theme.of(context).textTheme.headline6?.copyWith(
                                                                fontSize: 25, color: Colors.white,
                                                              ),),
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
                                    !showFilterMenu
                                        ? Container()
                                        : Container(
                                            padding: EdgeInsets.only(left: 10, right: 10),
                                            decoration: new BoxDecoration(
                                                border: new Border.all(
                                                    width: 1,
                                                    color: Colors
                                                        .transparent), //color is transparent so that it does not blend with the actual color specified
                                                color: new Color.fromRGBO(70, 70, 70,
                                                    0.85) // Specifies the background color and the opacity
                                                ),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisSize: MainAxisSize.max,
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.only(top: 10),
                                                      child: Text(
                                                        '地区',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                    Container(padding: const EdgeInsets.all(5)),
                                                    Expanded(
                                                      flex: 1,
                                                      child: Wrap(
                                                        children: [
                                                          ...buildFilterButton('area', filterLocation)
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.only(top: 10),
                                                      child: Text(
                                                        '语言',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                    Container(padding: const EdgeInsets.all(5)),
                                                    Expanded(
                                                      flex: 1,
                                                      child: Wrap(
                                                        children: [
                                                          ...buildFilterButton('lang', filterLang_movie)
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.only(top: 10),
                                                      child: Text(
                                                        '年份',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                    Container(padding: const EdgeInsets.all(5)),
                                                    Expanded(
                                                      flex: 1,
                                                      child: Wrap(
                                                        children: [...buildFilterButton('year', filterYear)],
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                  ],
                                ),
                              ),
                      ],
                    )
                  : Column(
                      verticalDirection: VerticalDirection.down,
                      //direction: Axis.vertical,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          padding: EdgeInsets.only(top: 5, bottom: 5),
                          //width: media.size.width,
                          height: 61,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.white,
                                width: 1.0, // Underline thickness
                              ),
                            ),
                          ),
                          child: ListView.separated(
                            padding: EdgeInsets.only(left: 5, right: 5),
                            scrollDirection: Axis.horizontal,
                            itemCount: movieMenuItem.length,
                            itemBuilder: (BuildContext context, int index) {
                              return TextButton(
                                style: TextButton.styleFrom(
                                  primary: Colors.white,
                                  textStyle: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                onPressed: () {
                                  //print('pressed ${movieMenuItem[index].genreName}');
                                  _changeMovieMenuItem(movieMenuItem[index].urlLink);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white,),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                  //color: Colors.black26,
                                  child: Center(
                                    child: Text(
                                      '${movieMenuItem[index].genreName}',
                                    ),
                                  ),
                                ),
                              );
                            },
                            separatorBuilder: (BuildContext context, int index) =>
                                Container(padding: const EdgeInsets.only(left: 5)),
                          ),
                        ),
                        snapshot.hasError
                            ? Center(
                                child: Column(
                                  children: [
                                    Text("${snapshot.error}"),
                                  ],
                                ),
                              )
                            : Container(),
                        movieMenuItem.length == 0
                            ? Center(
                                child: Column(
                                  children: [
                                    Text("No category list for this item. \n Please select another category.")
                                  ],
                                ),
                              )
                            : Container(),
                        showError
                            ? Container()
                            : Expanded(
                                //flex: 10,
                                child: Container(
                                  child: PagedGridView<int, Movie>(
                                    padding: EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 5),
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
                                                    textStyle: TextStyle(fontWeight: FontWeight.normal)),
                                                onPressed: () {
                                                  //print('pressed ${item.name}');
                                                  if (item.detailUrl != '') {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => MovieDetail(
                                                          movieUrl: item.detailUrl,
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                },
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      width: 300,
                                                      child: CachedNetworkImage(
                                                          fit: BoxFit.none,
                                                          placeholder: (context, _) => Image(
                                                              image: AssetImage('assets/images/load.png')),
                                                          errorWidget: (context, url, err) => Image(
                                                              image: AssetImage('assets/images/load.png')),
                                                          imageUrl: item.thumbnailUrl),
                                                    ),
                                                    Container(
                                                      padding: const EdgeInsets.only(top: 10, bottom: 2),
                                                      decoration: BoxDecoration(
                                                          border: Border(
                                                              bottom: BorderSide(
                                                        color: Colors.black38,
                                                        width: 1.0, // Underline thickness
                                                      ))),
                                                      child: Text(item.name,
                                                          style: Theme.of(context).textTheme.headline6?.copyWith(
                                                            fontSize: 25, color: Colors.white,
                                                          ),),
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
            },
          ),
        ),
      ),
    );
  }
}
