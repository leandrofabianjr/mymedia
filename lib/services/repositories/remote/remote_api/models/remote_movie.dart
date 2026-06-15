import 'package:mymedia/domain/models/movie.dart';

class RemoteMovie {
  static Movie jsonToMovie(Map<String, dynamic> json) {
    try {
      return Movie(
        id: json['id'],
        title: json['title'],
        fileName: json['file_name'],
        filePath: json['file_path'],
        posterUrl: json['poster_url'],
        year: json['year'],
        extension: json['extension'],
        createdAt: DateTime.parse(json['created_at']),
        addedAt: DateTime.parse(json['added_at']),
        tmdbData: json['tmdb_data'] != null
            ? MovieTmdbData.fromJson(json['tmdb_data'])
            : null,
      );
    } catch (e) {
      throw FormatException('Erro ao converter JSON para Movie: $e');
    }
  }
}
