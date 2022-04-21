import 'package:flutter_app/models/artist.dart';

class Track {
  final String name;
  final String albumCover;
  final List<Artist> artists;

  const Track({
    required this.name,
    required this.albumCover,
    required this.artists,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      name: json['name'] as String,
      albumCover: json['album']['images'][1]['url'],
      artists: json['artists'].cast<Map<String, dynamic>>().map<Artist>((json) => Artist.fromJson(json)).toList()
          as List<Artist>,
    );
  }
}
