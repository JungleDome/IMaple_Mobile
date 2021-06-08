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

class IMapleManager {
  static const String baseUrl = 'https://imaple.co';

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
              ?.querySelector('.myui-container-bg .myui-content__detail .title')
              ?.text ??
          "";
      var movieAltName = doc.body
              ?.querySelector('.myui-container-bg .myui-content__detail')
              ?.children
              ?.elementAt(2)
              .text ??
          "";
      var movieLastUpdate = doc.body
              ?.querySelector('.myui-container-bg .myui-content__detail')
              ?.children
              ?.elementAt(7)
              .text ??
          "";
      var movieDescription = doc.body
              ?.querySelector('.myui-container-bg .myui-content__detail')
              ?.children
              ?.elementAt(6)
              .text ??
          "";
      var movieAuthor = doc.body
              ?.querySelector('.myui-container-bg .myui-content__detail')
              ?.children
              ?.elementAt(5)
              .text ??
          "";
      var movieActor = doc.body
              ?.querySelector('.myui-container-bg .myui-content__detail')
              ?.children
              ?.elementAt(4)
              .text ??
          "";
      var moviePublishLocation = doc.body
              ?.querySelector('.myui-container-bg .myui-content__detail')
              ?.children
              ?.elementAt(3)
              .text ??
          "";
      var moviePublishYear = doc.body
              ?.querySelector('.myui-container-bg .myui-content__detail')
              ?.children
              ?.elementAt(3)
              .text ??
          "";
      var movieRating = doc.body
              ?.querySelector('.myui-container-bg .myui-content__detail')
              ?.children
              ?.elementAt(3)
              .text ??
          "";

      var sourcelist = doc.body
          ?.querySelector('.myui-container-bg')
          ?.nextElementSibling
          ?.querySelector('.myui-panel_hd')
          ?.querySelectorAll('ul li');
      var playlist = doc.body
          ?.querySelector('.myui-container-bg')
          ?.nextElementSibling
          ?.querySelector('.myui-panel_bd');

      if (sourcelist != null && playlist != null) {
        var parsedPlaylist = sourcelist.map<Playlist>((sourceElement) {
          var sourceDetails = sourceElement
              .getElementsByTagName('a')
              .firstWhere((el) => el.attributes.containsKey('href'));
          var sourcePlaylistHtmlId =
              sourceDetails.attributes['href'].toString();
          var sourcePlaylistName = sourceDetails.text;

          var episodeList =
              playlist.querySelectorAll(sourcePlaylistHtmlId + ' ul li');
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

  Future<Movie> getMovieList() async {
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
          ?.querySelector('.myui-container-bg .myui-content__detail .title')
          ?.text ??
          "";
      var movieAltName = doc.body
          ?.querySelector('.myui-container-bg .myui-content__detail')
          ?.children
          ?.elementAt(2)
          .text ??
          "";
      var movieLastUpdate = doc.body
          ?.querySelector('.myui-container-bg .myui-content__detail')
          ?.children
          ?.elementAt(7)
          .text ??
          "";
      var movieDescription = doc.body
          ?.querySelector('.myui-container-bg .myui-content__detail')
          ?.children
          ?.elementAt(6)
          .text ??
          "";
      var movieAuthor = doc.body
          ?.querySelector('.myui-container-bg .myui-content__detail')
          ?.children
          ?.elementAt(5)
          .text ??
          "";
      var movieActor = doc.body
          ?.querySelector('.myui-container-bg .myui-content__detail')
          ?.children
          ?.elementAt(4)
          .text ??
          "";
      var moviePublishLocation = doc.body
          ?.querySelector('.myui-container-bg .myui-content__detail')
          ?.children
          ?.elementAt(3)
          .text ??
          "";
      var moviePublishYear = doc.body
          ?.querySelector('.myui-container-bg .myui-content__detail')
          ?.children
          ?.elementAt(3)
          .text ??
          "";
      var movieRating = doc.body
          ?.querySelector('.myui-container-bg .myui-content__detail')
          ?.children
          ?.elementAt(3)
          .text ??
          "";

      var sourcelist = doc.body
          ?.querySelector('.myui-container-bg')
          ?.nextElementSibling
          ?.querySelector('.myui-panel_hd')
          ?.querySelectorAll('ul li');
      var playlist = doc.body
          ?.querySelector('.myui-container-bg')
          ?.nextElementSibling
          ?.querySelector('.myui-panel_bd');

      if (sourcelist != null && playlist != null) {
        var parsedPlaylist = sourcelist.map<Playlist>((sourceElement) {
          var sourceDetails = sourceElement
              .getElementsByTagName('a')
              .firstWhere((el) => el.attributes.containsKey('href'));
          var sourcePlaylistHtmlId =
          sourceDetails.attributes['href'].toString();
          var sourcePlaylistName = sourceDetails.text;

          var episodeList =
          playlist.querySelectorAll(sourcePlaylistHtmlId + ' ul li');
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

  Future<Movie> searchMovie(String pinyinString) async {
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
          ?.querySelector('.myui-container-bg .myui-content__detail .title')
          ?.text ??
          "";
      var movieAltName = doc.body
          ?.querySelector('.myui-container-bg .myui-content__detail')
          ?.children
          ?.elementAt(2)
          .text ??
          "";
      var movieLastUpdate = doc.body
          ?.querySelector('.myui-container-bg .myui-content__detail')
          ?.children
          ?.elementAt(7)
          .text ??
          "";
      var movieDescription = doc.body
          ?.querySelector('.myui-container-bg .myui-content__detail')
          ?.children
          ?.elementAt(6)
          .text ??
          "";
      var movieAuthor = doc.body
          ?.querySelector('.myui-container-bg .myui-content__detail')
          ?.children
          ?.elementAt(5)
          .text ??
          "";
      var movieActor = doc.body
          ?.querySelector('.myui-container-bg .myui-content__detail')
          ?.children
          ?.elementAt(4)
          .text ??
          "";
      var moviePublishLocation = doc.body
          ?.querySelector('.myui-container-bg .myui-content__detail')
          ?.children
          ?.elementAt(3)
          .text ??
          "";
      var moviePublishYear = doc.body
          ?.querySelector('.myui-container-bg .myui-content__detail')
          ?.children
          ?.elementAt(3)
          .text ??
          "";
      var movieRating = doc.body
          ?.querySelector('.myui-container-bg .myui-content__detail')
          ?.children
          ?.elementAt(3)
          .text ??
          "";

      var sourcelist = doc.body
          ?.querySelector('.myui-container-bg')
          ?.nextElementSibling
          ?.querySelector('.myui-panel_hd')
          ?.querySelectorAll('ul li');
      var playlist = doc.body
          ?.querySelector('.myui-container-bg')
          ?.nextElementSibling
          ?.querySelector('.myui-panel_bd');

      if (sourcelist != null && playlist != null) {
        var parsedPlaylist = sourcelist.map<Playlist>((sourceElement) {
          var sourceDetails = sourceElement
              .getElementsByTagName('a')
              .firstWhere((el) => el.attributes.containsKey('href'));
          var sourcePlaylistHtmlId =
          sourceDetails.attributes['href'].toString();
          var sourcePlaylistName = sourceDetails.text;

          var episodeList =
          playlist.querySelectorAll(sourcePlaylistHtmlId + ' ul li');
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

  Future<String> getMoviePlayLink(String episodeLink) async {
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
          ?.querySelector("script")?.innerHtml ?? "";
      var regex = RegExp(r'.*{(.*)}.*');
      var match = regex.firstMatch(moviePlayData);

      var moviePlayDataJsonString = match?.group(1) ?? "";
      Map<String, dynamic> moviePlayDataJson = jsonDecode('{'+ moviePlayDataJsonString +'}');
      return moviePlayDataJson['url'] ?? '';
    } else {
      throw Exception("Failed to fetch movie play url.");
    }
  }
}
