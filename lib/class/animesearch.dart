import 'dart:convert';

class AnimeSearch {

  String title, img, link = "";

  AnimeSearch(this.title, this.img, this.link);

  factory AnimeSearch.fromJson(Map<String, dynamic> jsonData) {
    return AnimeSearch(
        jsonData['title'],
        jsonData['img'],
        jsonData['link'],
    );
  }

  static Map<String, dynamic> toMap(AnimeSearch novel) => {
    'title': novel.title,
    'img': novel.img,
    'link': novel.link,
  };

  static String encode(List<AnimeSearch> novels) => json.encode(
    novels
        .map<Map<String, dynamic>>((novel) => AnimeSearch.toMap(novel))
        .toList(),
  );

  static List<AnimeSearch> decode(String novels) =>
      (json.decode(novels) as List<dynamic>)
          .map<AnimeSearch>((item) => AnimeSearch.fromJson(item))
          .toList();

}