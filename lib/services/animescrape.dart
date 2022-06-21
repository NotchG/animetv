import 'dart:io';
import 'package:animetv/class/animesearch.dart';
import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:http/http.dart';

import '../class/anime.dart';

class AnimeScrape {
  String url;
  List<Bs4Element>? popular = [];
  Anime? anime;
  Bs4Element? element;
  List<AnimeSearch> search = [];
  String baseUrl = 'gogoanime.lu';
  Map<String, String> header = {
    HttpHeaders.userAgentHeader: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36',
    HttpHeaders.acceptHeader: 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
    HttpHeaders.acceptLanguageHeader: 'en-US,en;q=0.5',
    HttpHeaders.acceptEncodingHeader: 'gzip',
    HttpHeaders.connectionHeader: 'close',
  };
  AnimeScrape({required this.url});

  Future<void> getPopular() async {
    Response response = await get(Uri.https(baseUrl, url));

    BeautifulSoup bs = BeautifulSoup(response.body);
    List<Bs4Element>? res = bs.find('ul', class_: 'items')?.contents;

    popular = res;
  }

  Future<void> getAnime() async {
    Response response = await get(Uri.https(baseUrl, url));

    BeautifulSoup bs = BeautifulSoup(response.body);
    Bs4Element? res = bs.find('div', class_: 'anime_info_body_bg');
    element = res;
    Bs4Element? res2 = bs.find('ul', id: 'episode_page');
    anime = Anime(res!.find('h1')!.text, res.findAll('p', class_: 'type')[4].text, res.findAll('p', class_: 'type')[1].text, int.parse(res2!.findAll('li').last.find('a')!['ep_end']!));
  }

  Future<void> getAnimeSearch(String key) async {
    Response response = await get(Uri.https(baseUrl, '/search.html', {
      'keyword': key
    }));

    BeautifulSoup bs = BeautifulSoup(response.body);
    List<Bs4Element>? res = bs.find('div', class_: 'last_episodes')?.findAll('li');
    res?.forEach((element) {
      Bs4Element res2 = element.find('div', class_: 'img')!;
      print(res2.find('a')!['title']!);
      search.add(AnimeSearch(res2.find('a')!['title']!, res2.find('img')!['src']!, res2.find('a')!['href']!));
    });
  }

  Future<String> getBaseEpisodeLink() async {
    print("https://" + baseUrl + "/" + url.replaceAll("https://" + baseUrl + "/category/", "").replaceFirst("/category/", ""));
    return "https://" + baseUrl + "/" + url.replaceAll("https://" + baseUrl + "/category/", "").replaceFirst("/category/", "");
  }


  Future<String> getPlayer() async {
    Response response = await get(Uri.https(baseUrl, url));

    BeautifulSoup bs = BeautifulSoup(response.body);
    Bs4Element? res = bs.find('div', class_: 'play-video');
    return "https:" + res!.find("iframe")!["src"]!;
  }
}

