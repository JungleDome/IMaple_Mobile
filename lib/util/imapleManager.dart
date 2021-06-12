import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'dart:convert';

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

  Movie(
      {required this.name,
      required this.playlist,
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

class IMapleManager {
  static const String baseUrl = 'https://imaple.co';
  static const searchPageSize = 21;
  static const listingPageSize = 48;

  Future<Movie> getMovie() async {
    final response = await http.get(
      Uri.parse(IMapleManager.baseUrl + '/vod/103058.html'),
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
              ?.elementAt(2
          )
              .text ??
              "";
      var movieLastUpdate =
          doc.body
              ?.querySelector('.myui-container-bg .myui-content__detail'
          )
              ?.children
              ?.elementAt(7
          )
              .text ??
              "";
      var movieDescription =
          doc.body
              ?.querySelector('.myui-container-bg .myui-content__detail'
          )
              ?.children
              ?.elementAt(6
          )
              .text ??
              "";
      var movieAuthor =
          doc.body
              ?.querySelector('.myui-container-bg .myui-content__detail'
          )
              ?.children
              ?.elementAt(5
          )
              .text ??
              "";
      var movieActor =
          doc.body
              ?.querySelector('.myui-container-bg .myui-content__detail'
          )
              ?.children
              ?.elementAt(4
          )
              .text ??
              "";
      var moviePublishLocation =
          doc.body
              ?.querySelector('.myui-container-bg .myui-content__detail'
          )
              ?.children
              ?.elementAt(3
          )
              .text ??
              "";
      var moviePublishYear =
          doc.body
              ?.querySelector('.myui-container-bg .myui-content__detail'
          )
              ?.children
              ?.elementAt(3
          )
              .text ??
              "";
      var movieRating =
          doc.body
              ?.querySelector('.myui-container-bg .myui-content__detail'
          )
              ?.children
              ?.elementAt(3
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
        return Movie(
            name: movieName,
            playlist: parsedPlaylist.toList(),
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
      ]);
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
          ?.length ?? 0) == 0) return [];
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
      Uri.parse(IMapleManager.baseUrl + '${pageLink.replaceAll('.html', ''
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
            .querySelector('.myui-vodlist__thumb a'
        )
            ?.attributes['href'] ?? '';
        var movieThumbnail =
            movieItem
                .querySelector('.myui-vodlist__thumb a'
            )
                ?.attributes['data-original'] ?? '';
        var movieName = movieItem
            .querySelector('.myui-vodlist__detail .title a'
        )
            ?.text ?? "";
        var movieActor = movieItem
            .querySelector('.myui-vodlist__detail p'
        )
            ?.text ?? "";
        var movie = Movie(name: movieName, playlist: [], thumbnailUrl: movieThumbnail, actor: movieActor
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
        var movie = Movie(
            name: movieName,
            playlist: [],
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

  Future<String> getMoviePlayLink(String episodeLink) async {
    final response = await http.get(
      Uri.parse(IMapleManager.baseUrl + episodeLink),
      headers: <String, String>{
        'Content-Type': 'text/html; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      var doc = html_parser.parse(response.body);
      var moviePlayData =
          doc.body
              ?.querySelector('.myui-player__video'
          )
              ?.querySelector("script"
          )
              ?.innerHtml ?? "";
      var regex = RegExp(r'.*{(.*)}.*');
      var match = regex.firstMatch(moviePlayData);

      var moviePlayDataJsonString = match?.group(1) ?? "";
      Map<String, dynamic> moviePlayDataJson = jsonDecode('{' + moviePlayDataJsonString + '}'
      );
      return moviePlayDataJson['url'] ?? '';
    } else {
      throw Exception("Failed to fetch movie play url.");
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
