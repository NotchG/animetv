import 'dart:ffi';

import 'package:animetv/class/anime.dart';
import 'package:animetv/pages/Loading.dart';
import 'package:animetv/pages/search.dart';
import 'package:animetv/services/animescrape.dart';
import 'package:dpad_container/dpad_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  String Username = "NotchG Inc.";

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
      //_popular.add(ImageCard(image: _images[i], link: _link[i], anime: scr.anime, update: _Update, updateImg: _UpdateImg, updateLink: _UpdateLink));
      _popular.add(AnimeButton(_images[i], scr.anime!, _link[i]));
    }

    setState(() {
      loading = false;
    });
  }

  Widget AnimeButton(String image, Anime anime, String link) {
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.red;
    }
    EdgeInsetsGeometry getPadding(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return const EdgeInsets.all(3);
      }
      return const EdgeInsets.all(19);
    }

    return (
      ElevatedButton(
        onPressed: () {
        },
        onFocusChange: (b) {
          if(b) {
            player.pause();
            player.seek(const Duration(milliseconds: 0));
            player.play();
            print("play");
            setState(() {
              title = anime.title;
              descr = anime.synopsis;
              totaleps = anime.totalEps;
              img = image;
              globalLink = link;
            });
          }
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            border: Border.all(
              color: Colors.white,
              width: 5,
            ),
            image: DecorationImage(
              image: NetworkImage(image),
              fit: BoxFit.cover,
            ),
          ),
        ),
        style: ButtonStyle(
          padding: MaterialStateProperty.resolveWith((states) => getPadding(states)),
          backgroundColor: MaterialStateProperty.all(Colors.transparent),
          elevation: MaterialStateProperty.all(0)
        ),
      )
    );
  }

  @override
  void initState() {
    initAnime();
    super.initState();
  }

  bool hasChanged = false;

  int currItem = 1;

  bool onMenu = false;

  bool popularMenu = false;
  bool searchMenu = false;
  bool profileMenu = false;
  bool popularHover = false;
  bool searchHover = false;
  bool profileHover = false;

  @override
  Widget build(BuildContext context) {
    return loading ? const Loading() : Scaffold(
      backgroundColor: const Color(0xff151515),
      body: Stack(
        children: [
          popularMenu ? popular() : const SizedBox(),
          searchMenu ? const Search() : const SizedBox(),
          (popularMenu || searchMenu || profileMenu) ? const SizedBox() :
          Container(
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container()
                ),
                Expanded(
                  flex: 14,
                  child: Padding(
                    padding: const EdgeInsets.all(50.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome $Username",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: FontSize.xxLarge.size! * 3,
                            fontWeight: FontWeight.w200
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xff151515),
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
                        const SizedBox(
                          height: 50.0,
                        ),
                        Container(
                      width: 1/35 * MediaQuery.of(context).size.width,
                      height: 1/35 * MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,

                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage("https://media-exp1.licdn.com/dms/image/C4E03AQGYy7nj4orOQg/profile-displayphoto-shrink_100_100/0/1629097702192?e=1652918400&v=beta&t=iGo0IIl1m4kyl4p3ORY3xJNaF87Xfyj3sUjbY6NHDsk"),
                              fit: BoxFit.fill,
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                          ElevatedButton(
                          child: Container(),
                          onPressed: () {
                            setState(() {
                              popularMenu = false;
                              searchMenu = false;
                              profileMenu = true;
                            });
                          },
                            onFocusChange: (bool b) {
                              setState(() {
                                profileHover = b;
                              });
                            },
                          style: ElevatedButton.styleFrom(
                            fixedSize: Size(1/35 * MediaQuery.of(context).size.width, 1/35 * MediaQuery.of(context).size.width),
                            shape: const CircleBorder(),
                            primary: Colors.transparent
                          ),
                        ),

                        ]
                      ),
                    ),
                        const SizedBox(
                          height: 50.0,
                        ),
                        ElevatedButton.icon(
                            onPressed: () {
                             setState(() {
                               popularMenu = false;
                               searchMenu = true;
                             });
                            },
                            onFocusChange: (bool b) {
                              setState(() {
                                searchHover = b;
                              });
                            },
                            style: ButtonStyle(
                              elevation: MaterialStateProperty.all(0),
                              backgroundColor: MaterialStateProperty.all(const Color(0xff151515)),
                                overlayColor: MaterialStateProperty.all(Colors.transparent)
                            ),
                            icon: Icon(
                              Icons.search,
                              color:  searchHover ? Colors.greenAccent : (searchMenu ? Colors.redAccent : Colors.white),
                              size: 40.0,
                            ),
                            label: Padding(
                              padding: EdgeInsets.all((popularHover || searchHover || profileHover) ? 13.0 : 0),
                              child: Text((popularHover || searchHover || profileHover) ? "Search" : "", style: TextStyle(fontSize: FontSize.xxLarge.size, fontWeight: FontWeight.w200),),
                            )
                        ),
                        const SizedBox(
                          height: 50.0,
                        ),
                        ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                popularMenu = true;
                                searchMenu = false;
                              });
                            },
                            onFocusChange: (bool b) {
                              setState(() {
                                popularHover = b;
                              });
                            },
                            style: ButtonStyle(
                                elevation: MaterialStateProperty.all(0),
                                backgroundColor: MaterialStateProperty.all(const Color(0xff151515)),
                              overlayColor: MaterialStateProperty.all(Colors.transparent)
                            ),
                            icon: Icon(
                              Icons.local_fire_department_outlined,
                              color: popularHover ? Colors.greenAccent : (popularMenu ? Colors.redAccent : Colors.white),
                              size: 40.0,
                            ),
                            label: Padding(
                              padding: EdgeInsets.all((popularHover || searchHover || profileHover) ? 13.0 : 0),
                              child: Text((popularHover || searchHover || profileHover) ? "Popular" : "", style: TextStyle(fontSize: FontSize.xxLarge.size, fontWeight: FontWeight.w200),),
                            )
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 1/30 * MediaQuery.of(context).size.width,
                ),
                Expanded(
                    flex: (popularHover || searchHover || profileHover) ? 5 : 14,
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
                                  maxLines: 7,
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
                                print(globalLink);
                                AnimeScrape(url: globalLink).getBaseEpisodeLink().then((value) => Navigator.pushNamed(context, '/player', arguments: {
                                  'url': value + "-episode-",
                                  'totalEps': totaleps
                                }));
                              } : null,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 25.0),
                                child: Icon(
                                  Icons.play_arrow_rounded,
                                  size: 1/30 * MediaQuery.of(context).size.height,
                                  color: Colors.black,
                                ),
                              ),
                              style: ButtonStyle(
                                  backgroundColor: totaleps != 0 ? (hasChanged ? MaterialStateProperty.all(const Color(0xff66fff7)) : MaterialStateProperty.all(const Color(0xffd5d5d5))) : MaterialStateProperty.all(Colors.redAccent),
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
          player.seek(const Duration(milliseconds: 0));
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
        padding: hasChange ? const EdgeInsets.all(3) : const EdgeInsets.all(19),
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
