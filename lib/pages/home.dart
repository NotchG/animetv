import 'dart:ffi';

import 'package:animetv/class/anime.dart';
import 'package:animetv/pages/Loading.dart';
import 'package:animetv/services/animescrape.dart';
import 'package:dpad_container/dpad_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

var title = "";
var descr = "";
var img = "";
var totaleps = 0;
final player = AudioPlayer();

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  List<String> _images = [];
  List<String> _link = [];
  List<Widget> _popular = [];
  bool loading = true;
  String globalLink = "";

  void _Update(Anime anime) {
    setState(() {
      title = anime.title;
      descr = anime.synopsis;
      totaleps = anime.totalEps;
    });
  }

  void _UpdateImg(String imgg) {
    setState(() {
      img = imgg;
    });
  }

  void _UpdateLink(String link) {
    setState(() {
      globalLink = link;
    });
  }

  Future<void> initAnime() async {
    loading = true;
    var duration = await player.setAsset('assets/moveanimetv.mp3');
    AnimeScrape scrape = AnimeScrape(url: '/popular.html');
    await scrape.getPopular();
    for (var element in scrape.popular!) { 
      _images.add(element.find('img')!["src"]!);
      _link.add(element.find('a')!["href"]!);
    }
    for(int i = 0;i < _images.length;i++) {
      AnimeScrape scr = AnimeScrape(url: _link[i]);
      await scr.getAnime();
      _popular.add(ImageCard(image: _images[i], link: _link[i], anime: scr.anime, update: _Update, updateImg: _UpdateImg, updateLink: _UpdateLink));
    }

    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    initAnime();
    super.initState();
  }

  bool hasChanged = false;

  int currItem = 1;

  bool onMenu = false;

  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
      backgroundColor: Color(0xff151515),
      body: Stack(
        children: [
          popular(),
          Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xff151515),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.8),
                          spreadRadius: 10,
                          blurRadius: 40,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 50.0,
                        ),
                        DpadContainer(
                          onFocus: (bool isFocused) {
                            setState(() {
                              onMenu = isFocused;
                            });
                          },
                          onClick: () {},
                          child: ElevatedButton.icon(
                              onPressed: () {

                              },
                              style: ButtonStyle(
                                elevation: MaterialStateProperty.all(0),
                                backgroundColor: MaterialStateProperty.all(Color(0xff151515))
                              ),
                              icon: Icon(
                                Icons.search,
                                color: Colors.white,
                                size: 40.0,
                              ),
                              label: Text("")
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 1/30 * MediaQuery.of(context).size.width,
                ),
                Expanded(
                    flex: onMenu ? 5 : 14,
                    child: Container()
                )
              ]
          ),
        ]
      )
    );
  }

  Widget popular() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
          ),
        ),
        SizedBox(
          width: 1/30 * MediaQuery.of(context).size.width,
        ),
        Expanded(
          flex: 14,
          child: Column(
            children: [
              Container(
                height: 6/10 * MediaQuery.of(context).size.height,
                child: Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(img.isNotEmpty ? img : "https://i.pinimg.com/originals/f5/05/24/f50524ee5f161f437400aaf215c9e12f.jpg"),
                              fit: BoxFit.contain,
                            ),
                          ),
                        )
                    ),
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(50.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            /*SizedBox(
                                      height: 1/20 * MediaQuery.of(context).size.height
                                  ),*/
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 1/30 * MediaQuery.of(context).size.width,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                SizedBox(
                                    height: 1/40 * MediaQuery.of(context).size.height
                                ),
                                Text(
                                  descr,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 1/80 * MediaQuery.of(context).size.width,
                                      fontWeight: FontWeight.w300
                                  ),
                                  maxLines: 8,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(
                                    height: 1/40 * MediaQuery.of(context).size.height
                                ),
                                Text(
                                  "Total Episodes: " + totaleps.toString(),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 1/90 * MediaQuery.of(context).size.width,
                                      fontWeight: FontWeight.w300
                                  ),
                                  maxLines: 1,
                                ),
                              ],
                            ),
                            SizedBox(
                                height: 1/30 * MediaQuery.of(context).size.height
                            ),
                            ElevatedButton(
                              onFocusChange: (bool b) {
                                setState(() {
                                  hasChanged = b;
                                });
                              },
                              onPressed: totaleps!=0 ? () {
                                AnimeScrape(url: globalLink).getBaseEpisodeLink().then((value) => print(value + "-episode-1"));
                                print("clicked");
                                AnimeScrape(url: globalLink).getBaseEpisodeLink().then((value) => Navigator.pushNamed(context, '/player', arguments: {
                                  'url': value + "-episode-",
                                  'totalEps': totaleps,
                                  'title': title
                                }));
                              } : null,
                              child: DpadContainer(
                                onClick: () {

                                },
                                onFocus: (bool isFocused) {
                                  print("Button");
                                  setState(() {
                                    hasChanged = isFocused;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 25.0),
                                  child: Icon(
                                    Icons.play_arrow_rounded,
                                    size: 1/30 * MediaQuery.of(context).size.height,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              style: ButtonStyle(
                                  backgroundColor: totaleps != 0 ? (hasChanged ? MaterialStateProperty.all(Color(0xff66fff7)) : MaterialStateProperty.all(Color(0xffd5d5d5))) : MaterialStateProperty.all(Colors.redAccent),
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25.0),
                                      )
                                  )
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                height: 4/11 * MediaQuery.of(context).size.height,
                child: GridView.count(
                  scrollDirection: Axis.horizontal,
                  crossAxisCount: 1,
                  crossAxisSpacing: 1,
                  mainAxisSpacing: 1,
                  childAspectRatio: 3/2,
                  children: _popular,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

}

class ImageCard extends StatefulWidget {
  const ImageCard({Key? key, required this.image, required this.link, required this.anime, required this.update, required this.updateImg, required this.updateLink}) : super(key: key);

  final String image;
  final String link;
  final Anime? anime;
  final ValueChanged<Anime> update;
  final ValueChanged<String> updateImg;
  final ValueChanged<String> updateLink;

  @override
  _ImageCardState createState() => _ImageCardState();
}

class _ImageCardState extends State<ImageCard> {
  bool hasChange = false;
  bool isClicked = false;

  @override
  Widget build(BuildContext context) {
    return DpadContainer(
      onClick: () {
      },
      onFocus: (focus) async {
        if(focus) {
          player.pause();
          player.seek(Duration(milliseconds: 0));
          player.play();
          print("play");
        }
          setState(() {
            if(focus != hasChange) {
              widget.update(widget.anime!);
              widget.updateImg(widget.image);
              widget.updateLink(widget.link);
              print(title);
            }
            hasChange = focus;
          });
      },
      child: Padding(
        padding: hasChange ? EdgeInsets.all(3) : EdgeInsets.all(19),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: hasChange ? Colors.white : Colors.black,
            border: Border.all(
              color: Colors.white,
              width: 5,
            ),
            image: DecorationImage(
              image: NetworkImage(widget.image),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
