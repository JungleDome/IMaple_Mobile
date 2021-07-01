import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:imaplemobile/page/movie_details.dart';
import 'package:imaplemobile/utils/futureHelper.dart';
import 'package:imaplemobile/utils/imapleManager.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class SearchPage extends StatefulWidget {
  final String searchText;

  SearchPage({Key? key, required this.searchText}) : super(key: key);

  @override
  SearchPageState createState() => SearchPageState(searchText: searchText);
}

class SearchPageState extends State<SearchPage> {
  String searchText;

  SearchPageState({required this.searchText}) {
    searchText = searchText;
  }

  static const _pageSize = 48;

  final PagingController<int, Movie> _pagingController =
      PagingController(firstPageKey: 1);
  final _imapleManager = IMapleManager();
  String selectedMovieCategoryLink = '';

  Future<void> _fetchPage(int pageKey) async {
    if (selectedMovieCategoryLink == '') return;

    try {
      print('PageKey: ${pageKey}');
      SearchResult newItems = await FutureHelper.retry(
          3, _imapleManager.searchMovie(searchText, pageNumber: pageKey),
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

    return Scaffold(
      body: SafeArea(
        child: isHorizontal
            ? Flex(
                verticalDirection: VerticalDirection.down,
                direction: Axis.horizontal,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    flex: 10,
                    child: Container(
                      child: PagedGridView<int, Movie>(
                        padding:
                            EdgeInsets.only(top: 10, bottom: 10, right: 10),
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
                                        textStyle: TextStyle(
                                            fontWeight: FontWeight.normal)),
                                    onPressed: () {
                                      print('pressed ${item.name}');
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
                                              fit: BoxFit.cover,
                                              placeholder: (context, _) => Image(
                                                  image: AssetImage(
                                                      'assets/images/load.png')),
                                              errorWidget:
                                                  (context, url, err) => Image(
                                                      image: AssetImage(
                                                          'assets/images/load.png')),
                                              imageUrl: item.thumbnailUrl),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.only(
                                              top: 10, bottom: 2),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: Colors.black38,
                                                width:
                                                    1.0, // Underline thickness
                                              ),
                                            ),
                                          ),
                                          child: Text(item.name,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline6),
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
              )
            : Column(
                verticalDirection: VerticalDirection.down,
                //direction: Axis.vertical,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    //flex: 10,
                    child: Container(
                      child: PagedGridView<int, Movie>(
                        padding: EdgeInsets.only(
                            top: 10, bottom: 10, right: 5, left: 5),
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
                                        textStyle: TextStyle(
                                            fontWeight: FontWeight.normal)),
                                    onPressed: () {
                                      print('pressed ${item.name}');
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
                                              fit: BoxFit.cover,
                                              placeholder: (context, _) => Image(
                                                  image: AssetImage(
                                                      'assets/images/load.png')),
                                              errorWidget:
                                                  (context, url, err) => Image(
                                                      image: AssetImage(
                                                          'assets/images/load.png')),
                                              imageUrl: item.thumbnailUrl),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.only(
                                              top: 10, bottom: 2),
                                          decoration: BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                            color: Colors.black38,
                                            width: 1.0, // Underline thickness
                                          ))),
                                          child: Text(item.name,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline6),
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
              ),
      ),
    );
  }
}
