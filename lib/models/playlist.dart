import 'dart:convert';

class Playlist {
  final String id;
  final String name;
  final List<int> songIds;
  final DateTime createdAt;

  const Playlist({
    required this.id,
    required this.name,
    required this.songIds,
    required this.createdAt,
  });

  factory Playlist.create(String name) {
    final ts = DateTime.now();
    return Playlist(
      id: '${ts.millisecondsSinceEpoch}_${ts.microsecond.toRadixString(16)}',
      name: name,
      songIds: const [],
      createdAt: ts,
    );
  }

  Playlist copyWith({String? name, List<int>? songIds}) => Playlist(
        id: id,
        name: name ?? this.name,
        songIds: songIds ?? this.songIds,
        createdAt: createdAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'songIds': songIds,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory Playlist.fromJson(Map<String, dynamic> j) => Playlist(
        id: j['id'] as String,
        name: j['name'] as String,
        songIds: List<int>.from(j['songIds'] as List),
        createdAt: DateTime.fromMillisecondsSinceEpoch(j['createdAt'] as int),
      );

  static String encodeList(List<Playlist> list) =>
      jsonEncode(list.map((e) => e.toJson()).toList());

  static List<Playlist> decodeList(String raw) {
    final list = jsonDecode(raw) as List;
    return list.map((e) => Playlist.fromJson(e as Map<String, dynamic>)).toList();
  }
}
