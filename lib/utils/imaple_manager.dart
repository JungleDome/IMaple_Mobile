import 'dart:convert';

import 'package:flutter_hls_parser/flutter_hls_parser.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

class Movie {
  final String name;
  final String altName;
  final String description;
  final String author;
  final String actor;
  final List<String> genre;
  final String publishLocation;
  final String publishYear;
  final String rating;
  final String lastUpdate;

  final List<Playlist> playlist;

  final String thumbnailUrl;
  final String detailUrl;

  Movie(
      {required this.name,
      required this.playlist,
        required this.detailUrl,
      this.altName = "",
      this.description = "",
      this.author = "",
      this.actor = "",
      List<String>? genre,
      this.publishLocation = "",
      this.publishYear = "",
      this.rating = "",
      this.lastUpdate = "",
      this.thumbnailUrl = ""})
      : genre = genre ?? [];
}

class Playlist {
  final String source;
  final Map<String, String> episodeLink;

  Playlist(this.source, this.episodeLink);
}

class SearchResultItem {
  final Movie movie;
  final String movieUrl;

  SearchResultItem(this.movie, this.movieUrl);
}

class SearchResult {
  final List<SearchResultItem> items;
  final int pageSize;
  final int maxPage;
  final int currentPage;

  SearchResult(this.items, this.pageSize, this.currentPage, this.maxPage);
}

enum MovieType { Movie, Drama, VarietyShow, Anime }

class MenuItem {
  final String genreName;
  final String urlLink;

  MenuItem(this.genreName, this.urlLink);
}

class MoviePlayDetail {
  final String streamUrl;
  final String? nextEpisodePlayLink;
  final String movieName;
  final String episodeName;

  MoviePlayDetail({required this.streamUrl, this.nextEpisodePlayLink, this.movieName = '', this.episodeName = ''});
}

class IMapleManager {
  static const String baseUrl = 'https://imaple.co';
  static const searchPageSize = 21;
  static const listingPageSize = 48;

  Future<Movie> getMovie(String detailUrl) async {
    final response = await http.get(
      Uri.parse(IMapleManager.baseUrl + detailUrl
      ),
      headers: <String, String>{
        'Content-Type': 'text/html; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      var doc = html_parser.parse(response.body);
      var movieThumbnail = doc.body
              ?.querySelector('.myui-container-bg .myui-content__thumb a img')
              ?.attributes["data-original"] ??
          "";
      var movieName = doc.body
          ?.querySelector('.myui-container-bg .myui-content__detail .title'
      )
          ?.text ?? "";
      var movieAltName =
          doc.body
              ?.querySelector('.myui-container-bg .myui-content__detail'
          )
              ?.children
              .elementAt(2
          )
              .text ??
              "";
      var movieLastUpdate =
          doc.body
              ?.querySelector('.myui-container-bg .myui-content__detail'
          )
              ?.children
              .elementAt(7
          )
              .text ??
              "";
      var movieDescription =
          doc.body
              ?.querySelector('.myui-container-bg .myui-content__detail'
          )
              ?.children
              .elementAt(6
          )
              .text ??
              "";
      var movieAuthor =
          doc.body
              ?.querySelector('.myui-container-bg .myui-content__detail'
          )
              ?.children
              .elementAt(5
          )
              .text ??
              "";
      var movieActor =
          doc.body
              ?.querySelector('.myui-container-bg .myui-content__detail'
          )
              ?.children
              .elementAt(4
          )
              .text ??
              "";
      var moviePublishLocation =
          doc.body
              ?.querySelector('.myui-container-bg .myui-content__detail'
          )
              ?.children
              .elementAt(3
          )
              .text ??
              "";
      var moviePublishYear =
          doc.body
              ?.querySelector('.myui-container-bg .myui-content__detail'
          )
              ?.children
              .elementAt(3
          )
              .text ??
              "";
      var movieRating =
          doc.body
              ?.querySelector('.myui-container-bg .myui-content__detail'
          )
              ?.children
              .elementAt(3
          )
              .text ??
              "";

      var sourcelist = doc.body
          ?.querySelector('.myui-container-bg')
          ?.nextElementSibling
          ?.querySelector('.myui-panel_hd')
          ?.querySelectorAll('ul li');
      var playlist =
      doc.body
          ?.querySelector('.myui-container-bg'
      )
          ?.nextElementSibling
          ?.querySelector('.myui-panel_bd'
      );

      if (sourcelist != null && playlist != null) {
        var parsedPlaylist = sourcelist.map<Playlist>((sourceElement) {
          var sourceDetails =
          sourceElement.getElementsByTagName('a'
          ).firstWhere((el) =>
              el.attributes.containsKey('href'
              )
          );
          var sourcePlaylistHtmlId = sourceDetails.attributes['href'].toString();
          var sourcePlaylistName = sourceDetails.text;

          var episodeList = playlist.querySelectorAll(sourcePlaylistHtmlId + ' ul li'
          );
          Map<String, String> parsedEpisodeLink = {};
          episodeList.forEach((episodeElement) {
            var episodeDetails = episodeElement
                .getElementsByTagName('a')
                .firstWhere((el) => el.attributes.containsKey('href'));

            var episodeLink = episodeDetails.attributes['href'] ?? "";
            var episodeName = episodeDetails.text;

            parsedEpisodeLink.putIfAbsent(episodeName, () => episodeLink);
          });

          return new Playlist(sourcePlaylistName, parsedEpisodeLink);
        });

        //Check can the link be played before display to ui
        // await Future.wait(parsedPlaylist.toList().asMap().entries.map((entry) {
        //   var index = entry.key;
        //   var e = entry.value;
        //   return e.episodeLink.values.map((e2) async {
        //     var isValid = await checkValidMoviePlayLink(e2.toString());
        //     if (!isValid) {
        //       var entryKey = parsedPlaylist.elementAt(index).episodeLink.entries.firstWhere((element) => element.value == e2.toString()).key;
        //       parsedPlaylist.elementAt(index).episodeLink.update(entryKey, (value) => '');
        //     }
        //   });
        // }).expand((e) => e));

        return Movie(
            name: movieName,
            playlist: parsedPlaylist
                .where((element) =>
                    element.episodeLink.values
                        .where((element2) => element2 != '')
                        .length >
                    0)
                .toList(),
            detailUrl: detailUrl,
            altName: movieAltName,
            actor: movieActor,
            author: movieAuthor,
            description: movieDescription,
            thumbnailUrl: movieThumbnail,
            publishLocation: moviePublishLocation,
            publishYear: moviePublishYear,
            rating: movieRating,
            lastUpdate: movieLastUpdate);
      }

      return Movie(name: "Mock", playlist: [
        Playlist("枫林网", {"ep1": "awd"})
      ], detailUrl: '/vod/50283.html'
      );
    } else {
      throw Exception("Failed to fetch movie details.");
    }
  }

  Future<List<MenuItem>> getMovieMenuItem(MovieType movieType) async {
    final response = await http.get(
      Uri.parse(
          IMapleManager.baseUrl + '/show/' + IMapleHelper.getMovieTypeInt(movieType
          ).toString() + '.html'
      ),
      headers: <String, String>{
        'Content-Type': 'text/html; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      var document = html_parser.parse(response.body
      );
      if ((document.body
          ?.querySelectorAll('.myui-screen__list'
      )
          .length ?? 0) == 0) return [];
      var menuItems =
          document.body
              ?.querySelectorAll('.myui-screen__list'
          )
              .elementAt(0
          )
              .children
              .toList() ?? [];
      menuItems.removeAt(0
      );

      var parsedMenuItems = menuItems.map<MenuItem>((element) {
        var itemName = element
            .querySelector('a'
        )
            ?.text ?? '';
        var itemLink = element
            .querySelector('a'
        )
            ?.attributes['href'] ?? '';

        return MenuItem(itemName, itemLink
        );
      }
      );

      return parsedMenuItems.toList();
    }
    else {
      throw Exception("Failed to fetch movie genre."
      );
    }
  }

  Future<SearchResult> getMovieList({String pageLink = '/show/1', int pageNumber = 1}) async {
    final response = await http.get(
      Uri.parse(
          IMapleManager.baseUrl + '${pageLink.replaceAll('.html', ''
          )}/page/${pageNumber}/by/hits.html'
      ),
      headers: <String, String>{
        'Content-Type': 'text/html; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      var document = html_parser.parse(response.body
      );

      var paginationElement = document.body?.querySelector('.myui-page'
      );
      int maxPage = 1;
      if (paginationElement != null) {
        var maxPageString = paginationElement
            .querySelector('.visible-xs'
        )
            ?.text ?? "";
        var maxPageStringSplit = maxPageString.split('/'
        );
        if (maxPageStringSplit.length == 2) maxPage = int.parse(maxPageStringSplit[1]
        );
      }

      var movieList = document.body?.querySelector('.myui-vodlist'
      );
      var searchResultList = movieList?.children.map<SearchResultItem>((movieItem) {
        var movieUrl = movieItem
            .querySelector('a.myui-vodlist__thumb'
        )
            ?.attributes['href'] ?? '';
        var movieThumbnail =
            movieItem
                .querySelector('a.myui-vodlist__thumb'
            )
                ?.attributes['data-original'] ?? '';
        var movieDetailUrl =
            movieItem
                .querySelector('a.myui-vodlist__thumb'
            )
                ?.attributes['href'] ?? '';
        var movieName = movieItem
            .querySelector('.myui-vodlist__detail .title a'
        )
            ?.text ?? "";
        var movieActor = movieItem
            .querySelector('.myui-vodlist__detail p'
        )
            ?.text ?? "";
        var movie = Movie(name: movieName,
            playlist: [],
            detailUrl: movieDetailUrl,
            thumbnailUrl: movieThumbnail,
            actor: movieActor
        );
        return SearchResultItem(movie, movieUrl
        );
      }
      );

      return SearchResult(searchResultList?.toList() ?? [], 48, pageNumber, maxPage
      );
    } else {
      throw Exception("Failed to fetch movie details.");
    }
  }

  Future<SearchResult> searchMovie(String pinyinString, {int pageNumber = 1}) async {
    final response = await http.get(
      Uri.parse(IMapleManager.baseUrl + '/search/page/${pageNumber}/wd/${pinyinString}.html'
      ),
      headers: <String, String>{
        'Content-Type': 'text/html; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      var document = html_parser.parse(response.body
      );

      var paginationElement = document.body?.querySelector('.myui-page'
      );
      int maxPage = 1;
      if (paginationElement != null) {
        var maxPageString = paginationElement
            .querySelector('.visible-xs'
        )
            ?.text ?? "";
        var maxPageStringSplit = maxPageString.split('/'
        );
        if (maxPageStringSplit.length == 2) maxPage = int.parse(maxPageStringSplit[1]
        );
      }

      var searchList =
      document.body?.querySelector('.myui-panel_bd'
      )?.querySelectorAll('.myui-vodlist__media li'
      );
      var searchResultMovie = searchList?.map<SearchResultItem>((searchItem) {
        var movieUrl = searchItem
            .querySelector('.detail'
        )
            ?.children
            .elementAt(5
        )
            .querySelectorAll('a'
        )[1]
            .attributes['href'] ??
            "";
        var movieThumbnail = searchItem
            .querySelector('.thumb a'
        )
            ?.attributes["data-original"] ?? "";
        var movieName = searchItem
            .querySelector('.detail'
        )
            ?.children
            .elementAt(0
        )
            .text ?? "";
        var movieDescription = searchItem
            .querySelector('.detail'
        )
            ?.children
            .elementAt(4
        )
            .text ?? "";
        var movieAuthor = searchItem
            .querySelector('.detail'
        )
            ?.children
            .elementAt(1
        )
            .text ?? "";
        var movieActor = searchItem
            .querySelector('.detail'
        )
            ?.children
            .elementAt(2
        )
            .text ?? "";
        var moviePublishLocation = searchItem
            .querySelector('.detail'
        )
            ?.children
            .elementAt(3
        )
            .text ?? "";
        var moviePublishYear = searchItem
            .querySelector('.detail'
        )
            ?.children
            .elementAt(3
        )
            .text ?? "";
        var movieRating = searchItem
            .querySelector('.detail'
        )
            ?.children
            .elementAt(3
        )
            .text ?? "";
        var movieDetailUrl = searchItem
            .querySelector('.detail'
        )
            ?.children
            .elementAt(5
        )
            .querySelectorAll('a'
        )
            .elementAt(1
        )
            .attributes['href'] ?? '';
        var movie = Movie(
            name: movieName,
            playlist: [],
            detailUrl: movieDetailUrl,
            actor: movieActor,
            author: movieAuthor,
            description: movieDescription,
            thumbnailUrl: movieThumbnail,
            publishLocation: moviePublishLocation,
            publishYear: moviePublishYear,
            rating: movieRating
        );

        return SearchResultItem(movie, movieUrl
        );
      }
      );
      return SearchResult(searchResultMovie?.toList() ?? [], 21, pageNumber, maxPage
      );
    } else {
      throw Exception("Failed to fetch search results."
      );
    }
  }

  Future<MoviePlayDetail> getMoviePlayLink(String episodeLink) async {
//    return episodeLink;

    final response = await http.get(
      Uri.parse(IMapleManager.baseUrl + episodeLink),
      headers: <String, String>{
        'Content-Type': 'text/html; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      var doc = html_parser.parse(response.body);
      var movieDetailData = doc.body?.querySelector('.myui-panel__head h3');
      var moviePlayData = doc.body
              ?.querySelector('.myui-player__video')
              ?.querySelector("script")
              ?.innerHtml ??
          "";
      var regex = RegExp(r'.*{(.*)}.*');
      var match = regex.firstMatch(moviePlayData);

      var moviePlayDataJsonString = match?.group(1) ?? 'a:1';
      Map<String, dynamic> moviePlayDataJson =
          jsonDecode('{' + moviePlayDataJsonString + '}');
      var streamUrl = moviePlayDataJson['url'] ?? '';
      var nextEpisodePlayLink = moviePlayDataJson['link_next'];
      var movieName = movieDetailData?.firstChild?.text ?? '';
      var episodeName = (movieDetailData?.children?.length ?? 0) > 1 ? movieDetailData?.children.elementAt(1).text ?? '' : '';
      return MoviePlayDetail(streamUrl: streamUrl, nextEpisodePlayLink: nextEpisodePlayLink, movieName: movieName, episodeName: episodeName);
    } else {
      throw Exception("Failed to fetch movie play url.");
    }
  }

  Future<bool> checkValidMoviePlayLink(String episodeLink) async {
    final response = await http.get(
      Uri.parse(IMapleManager.baseUrl + episodeLink),
      headers: <String, String>{
        'Content-Type': 'text/html; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      var doc = html_parser.parse(response.body);
      var moviePlayData = doc.body
              ?.querySelector('.myui-player__video')
              ?.querySelector("script")
              ?.innerHtml ??
          "";
      var regex = RegExp(r'.*{(.*)}.*');
      var match = regex.firstMatch(moviePlayData);

      var moviePlayDataJsonString = match?.group(1) ?? 'a:1';
      Map<String, dynamic> moviePlayDataJson =
          jsonDecode('{' + moviePlayDataJsonString + '}');
      var playlink = moviePlayDataJson['url'] ?? '';

      try {
        var response2 = await http.get(
          Uri.parse(playlink),
          headers: <String, String>{
            'Content-Type': 'text/html; charset=UTF-8',
          },
        );

        if (response2.statusCode == 200) {
          try {
            await HlsPlaylistParser.create()
                .parseString(Uri.parse(playlink), response.body);
            return true;
          } on Exception {
            return false;
          }
        } else {
          return false;
        }
      } catch (ex) {
        return false;
      }
    } else {
      throw Exception("Failed to check movie play url.");
    }
  }
}

class IMapleHelper {
  static int getMovieTypeInt(MovieType movieType) {
    switch (movieType) {
      case MovieType.Movie:
        return 1;
      case MovieType.Drama:
        return 2;
      case MovieType.VarietyShow:
        return 3;
      case MovieType.Anime:
        return 4;
      default:
        return 0;
    }
  }
}
