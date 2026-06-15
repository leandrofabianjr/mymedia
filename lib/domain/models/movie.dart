import 'dart:convert';

class Movie {
  final int id;
  final String title;
  final String fileName;
  final String filePath;
  final String? posterUrl;
  final int? year;
  final String extension;
  final DateTime createdAt;
  final DateTime addedAt;
  final MovieTmdbData? tmdbData;

  Movie({
    required this.id,
    required this.title,
    required this.fileName,
    required this.filePath,
    this.posterUrl,
    this.year,
    required this.extension,
    required this.createdAt,
    required this.addedAt,
    this.tmdbData,
  });
}

class MovieTmdbData {
  final bool? adult;
  final String? backdropPath;
  final List<int>? genreIds;
  final int? id;
  final String? title;
  final String? originalLanguage;
  final String? originalTitle;
  final String? overview;
  final double? popularity;
  final String? posterPath;
  final DateTime? releaseDate;
  final bool? softcore;
  final bool? video;
  final double? voteAverage;
  final int? voteCount;
  final String originalJsonString;

  MovieTmdbData({
    this.adult,
    this.backdropPath,
    this.genreIds,
    this.id,
    this.title,
    this.originalLanguage,
    this.originalTitle,
    this.overview,
    this.popularity,
    this.posterPath,
    this.releaseDate,
    this.softcore,
    this.video,
    this.voteAverage,
    this.voteCount,
    required this.originalJsonString,
  });

  factory MovieTmdbData.fromJson(Map<String, dynamic> json) {
    return MovieTmdbData(
      adult: json['adult'],
      backdropPath: json['backdrop_path'],
      genreIds: json['genre_ids'] != null
          ? List<int>.from(json['genre_ids'])
          : [],
      id: json['id'],
      title: json['title'],
      originalLanguage: json['original_language'],
      originalTitle: json['original_title'],
      overview: json['overview'],
      popularity: (json['popularity'] as num?)?.toDouble() ?? 0.0,
      posterPath: json['poster_path'],
      releaseDate:
          json['release_date'] != null &&
              json['release_date'].toString().isNotEmpty
          ? DateTime.tryParse(json['release_date'])
          : null,
      softcore: json['softcore'],
      video: json['video'],
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      voteCount: json['vote_count'] ?? 0,
      originalJsonString: jsonEncode(json),
    );
  }
}
