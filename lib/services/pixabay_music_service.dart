import 'dart:convert';

import 'package:http/http.dart' as http;

class PixabayTrack {
  const PixabayTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.duration,
    required this.previewUrl,
    required this.coverUrl,
    required this.usageCount,
    required this.genre,
  });

  final String id;
  final String title;
  final String artist;
  final Duration duration;
  final String previewUrl;
  final String coverUrl;
  final int usageCount;
  final String genre;

  factory PixabayTrack.fromJson(Map<String, dynamic> json) {
    final audioData = json['audio'];
    final previewFromMap =
        audioData is Map<String, dynamic> ? (audioData['url'] ?? '') : '';
    final titleFromTags =
        (json['tags']?.toString().split(',').first ?? '').trim();
    final durationSeconds = (json['duration'] as num?)?.toInt() ?? 0;

    return PixabayTrack(
      id: (json['id'] ?? '').toString(),
      title:
          (json['title'] ?? titleFromTags).toString().trim().isEmpty
              ? 'Untitled Track'
              : (json['title'] ?? titleFromTags).toString(),
      artist: (json['user'] ?? json['artist'] ?? 'Unknown Artist').toString(),
      duration: Duration(seconds: durationSeconds),
      previewUrl: (json['previewURL'] ?? previewFromMap ?? '').toString(),
      coverUrl:
          (json['picture'] ??
                  json['image'] ??
                  json['webformatURL'] ??
                  json['largeImageURL'] ??
                  '')
              .toString(),
      usageCount: (json['downloads'] as num?)?.toInt() ?? 0,
      genre: (json['category'] ?? 'General').toString(),
    );
  }
}

class PixabayMusicService {
  PixabayMusicService(this.apiKey);

  final String apiKey;

  static const List<PixabayTrack> fallbackTracks = [
    PixabayTrack(
      id: 'fallback-1',
      title: 'Breeze of Dawn',
      artist: 'Rohan Iyer',
      duration: Duration(minutes: 3, seconds: 10),
      previewUrl: '',
      coverUrl: '',
      usageCount: 220,
      genre: 'Romantic',
    ),
    PixabayTrack(
      id: 'fallback-2',
      title: 'Midnight Wanderlust',
      artist: 'Naomi White',
      duration: Duration(minutes: 4, seconds: 7),
      previewUrl: '',
      coverUrl: '',
      usageCount: 118,
      genre: 'Upbeat',
    ),
    PixabayTrack(
      id: 'fallback-3',
      title: 'Sugar Star',
      artist: 'Priya Malhotra',
      duration: Duration(minutes: 2, seconds: 56),
      previewUrl: '',
      coverUrl: '',
      usageCount: 200,
      genre: 'Dance',
    ),
    PixabayTrack(
      id: 'fallback-4',
      title: 'Golden Mirage',
      artist: 'Aisha Adisa',
      duration: Duration(minutes: 3, seconds: 37),
      previewUrl: '',
      coverUrl: '',
      usageCount: 570,
      genre: 'Techno',
    ),
    PixabayTrack(
      id: 'fallback-5',
      title: 'Rhapsody Lane',
      artist: 'Luca Rossi',
      duration: Duration(minutes: 3, seconds: 5),
      previewUrl: '',
      coverUrl: '',
      usageCount: 390,
      genre: 'Mystic',
    ),
  ];

  Future<List<PixabayTrack>> searchTracks({
    String query = '',
    String category = '',
    int page = 1,
    int perPage = 20,
  }) async {
    if (apiKey.trim().isEmpty) {
      return _filterFallback(query, category);
    }

    final params = <String, String>{
      'key': apiKey,
      'q': query,
      'per_page': '$perPage',
      'page': '$page',
    };
    if (category.isNotEmpty) {
      params['category'] = category.toLowerCase();
    }

    final uri = Uri.https('pixabay.com', '/api/audio/', params);
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      return _filterFallback(query, category);
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final hits =
        (body['hits'] as List<dynamic>? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(PixabayTrack.fromJson)
            .toList();

    if (hits.isEmpty) {
      return _filterFallback(query, category);
    }
    return hits;
  }

  List<PixabayTrack> _filterFallback(String query, String category) {
    final normalizedQuery = query.toLowerCase().trim();
    final normalizedCategory = category.toLowerCase().trim();
    return fallbackTracks.where((track) {
      final queryMatch =
          normalizedQuery.isEmpty ||
          track.title.toLowerCase().contains(normalizedQuery) ||
          track.artist.toLowerCase().contains(normalizedQuery);
      final categoryMatch =
          normalizedCategory.isEmpty ||
          track.genre.toLowerCase() == normalizedCategory;
      return queryMatch && categoryMatch;
    }).toList();
  }
}
