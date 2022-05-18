import 'dart:convert';

class Anime {

  String title, status, synopsis = "";
  int totalEps = 0;

  Anime(this.title, this.status, this.synopsis, this.totalEps);

  factory Anime.fromJson(Map<String, dynamic> jsonData) {
    return Anime(
      jsonData['title'],
      jsonData['status'],
      jsonData['synopsis'],
      jsonData['totalEps']
    );
  }

  static Map<String, dynamic> toMap(Anime novel) => {
    'title': novel.title,
    'status': novel.status,
    'synopsis': novel.synopsis,
    'totalEps': novel.totalEps
  };

  static String encode(List<Anime> novels) => json.encode(
    novels
        .map<Map<String, dynamic>>((novel) => Anime.toMap(novel))
        .toList(),
  );

  static List<Anime> decode(String novels) =>
      (json.decode(novels) as List<dynamic>)
          .map<Anime>((item) => Anime.fromJson(item))
          .toList();

}