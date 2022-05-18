import 'package:animetv/class/animesearch.dart';
import 'package:animetv/services/animescrape.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/style.dart';

var title = "Lorem Ipsum Movie";
var descr = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus rutrum odio quis elit vehicula, id laoreet quam faucibus. Praesent eros augue, viverra nec lorem in, finibus tincidunt quam. Duis laoreet diam sodales, venenatis magna sed, suscipit ipsum. Mauris sit amet arcu a velit ornare fringilla. Phasellus varius fringilla urna, nec ultrices nisl feugiat non. Quisque suscipit dui eget aliquam efficitur. Quisque a congue odio. Vivamus venenatis malesuada tortor id imperdiet. Aliquam vulputate pretium turpis vel tristique. Donec vel ipsum non felis tristique blandit. Ut sit amet ipsum vitae urna vulputate venenatis. ";
var img = "";
var totaleps = 0;

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  bool searchMenu = false;
  bool infoMenu = false;
  bool loading = false;
  bool hasChanged = false;
  bool hasCloseChanged = false;
  String globalLink = "";
  String searchKey = "";
  List<AnimeSearch> animeSearch = [];
  List<String> keyboardtop = ['q', 'w', 'e', 'r', 't', 'y', 'u','i','o','p'];
  List<String> keyboardmiddle = ['a', 's', 'd', 'f', 'g', 'h', 'j','k','l'];
  List<String> keyboardbottom = ['z', 'x', 'c', 'v', 'b', 'n', 'm'];

  Future<void> searchAnime(String srch) async {
    print(srch);
    if (srch.length < 4) return;
    setState(() {
      loading = true;
    });
    AnimeScrape scr = AnimeScrape(url: "");
    await scr.getAnimeSearch(srch);
    setState(() {
      searchMenu = false;
      animeSearch = scr.search;
      loading = false;
    });
  }

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.greenAccent;
    }
    return Colors.blueAccent;
  }
  EdgeInsetsGeometry getPadding(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return EdgeInsets.all(3);
    }
    return EdgeInsets.all(19);
  }

  BorderSide getSides(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return const BorderSide(width: 5.0, color: Colors.white);
    }
    return const BorderSide(width: 0.0, color: Colors.transparent);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
          ),
        ),
        Expanded(
          flex: 14,
          child: Container(
              color: Color(0xff151515),
              child: Stack(
                children: [
                  Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: EdgeInsets.all(20),
                        child: Row(
                          children: [
                            ElevatedButton(
                              autofocus: true,
                              onPressed: (searchMenu || infoMenu) ? null : () {
                                setState(() {
                                  searchMenu = true;
                                });
                              },
                              child: Container(
                                width: 1/3 * MediaQuery.of(context).size.width,
                                height: 1/15 * MediaQuery.of(context).size.height,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: const BorderRadius.all(Radius.circular(30)),
                                  border: Border.all(color: Colors.blueAccent),
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 20.0,
                                    ),
                                    Center(
                                      child: Text(
                                        searchKey,
                                        style: TextStyle(
                                          fontSize: FontSize.xxLarge.size,
                                          color: Colors.black
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(Colors.transparent),
                                elevation: MaterialStateProperty.all(0),

                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 7,
                      child: Container(
                        child: animeSearch.isNotEmpty ? GridView.count(
                          padding: EdgeInsets.all(20),
                            crossAxisCount: 5,
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 20,
                            childAspectRatio: 2/3,
                            children: animeSearch.map((e) =>
                              ElevatedButton(
                                  onPressed: (searchMenu || infoMenu) ? null : () async {
                                    AnimeScrape scr = AnimeScrape(url: e.link);
                                    await scr.getAnime();
                                    setState(() {
                                      infoMenu = true;
                                      searchMenu = false;
                                      title = scr.anime!.title;
                                      descr = scr.anime!.synopsis;
                                      img = scr.element!.find('img')!['src']!;
                                      totaleps = scr.anime!.totalEps;
                                      globalLink = e.link;
                                    });
                                  },
                                  child: Stack(
                                  fit: StackFit.expand,
                                children: [
                                  Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(e.img),
                                      fit: BoxFit.cover,
                                    )
                                  ),
                                ),
                                  Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        gradient: LinearGradient(
                                            begin: FractionalOffset.bottomCenter,
                                            end: FractionalOffset.topCenter,
                                            colors: [
                                              Colors.black.withOpacity(1),
                                              Colors.black.withOpacity(0)
                                            ],
                                            stops: const [
                                              0.0,
                                              1.0
                                            ]
                                        )
                                    ),
                                  ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      e.title,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: FontSize.large.size
                                      ),
                                    ),
                                    SizedBox(
                                      height: 1/40 * MediaQuery.of(context).size.height,
                                    )
                                  ],
                                ),
                                ]
                              ),
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(Colors.transparent),
                                padding: MaterialStateProperty.resolveWith((states) => getPadding(states)),
                                elevation: MaterialStateProperty.all(0),
                                overlayColor: MaterialStateProperty.all(Colors.transparent),
                                side: MaterialStateProperty.resolveWith((states) => getSides(states))
                              ),
                              )
                            ).toList(),
                        ) : Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: Text(
                            "Search bar empty or no result",
                            style: TextStyle(
                              fontSize: FontSize.xxLarge.size! * 2,
                              fontWeight: FontWeight.w200,
                              color: Colors.white
                            ),
                          ),
                        )
                      ),
                    )
                  ],
                ),
                  searchMenu ? Container(
                    color: Colors.black.withOpacity(0.4),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                              searchKey,
                            style: TextStyle(
                              fontSize: FontSize.xxLarge.size! * 2,
                              color: Colors.white
                            ),
                          ),
                          SizedBox(
                            height: 1/15 * MediaQuery.of(context).size.height,
                          ),
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ElevatedButton(onPressed: () async {
                                        setState(() {
                                          searchMenu = false;
                                        });
                                      },
                                          autofocus: true,child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text("Close", style: TextStyle(fontSize: FontSize.xxLarge.size)),
                                      ),
                                          style: ButtonStyle(
                                              backgroundColor: MaterialStateProperty.resolveWith((states) => getColor(states))
                                          )),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ElevatedButton(
                                      autofocus: true,
                                        onPressed: () {setState(() {
                                      if (searchKey.isNotEmpty) {
                                        searchKey = searchKey.substring(0, searchKey.length - 1);
                                      }
                                    });}, child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text("Backspace", style: TextStyle(fontSize: FontSize.xxLarge.size)),
                                    ),
                                        style: ButtonStyle(
                                            backgroundColor: MaterialStateProperty.resolveWith((states) => getColor(states))
                                        )),
                                  ),
                                  Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ElevatedButton(onPressed: () async {
                                        await searchAnime(searchKey);
                                        }, child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text("Search", style: TextStyle(fontSize: FontSize.xxLarge.size)),
                                      ),
                                          style: ButtonStyle(
                                              backgroundColor: MaterialStateProperty.resolveWith((states) => getColor(states))
                                          )),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children:
                                  keyboardtop.map((e) => Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ElevatedButton(onPressed: () {setState(() {searchKey += e;});}, child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(e, style: TextStyle(fontSize: FontSize.xxLarge.size)),
                                    ),
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.resolveWith((states) => getColor(states))
                                    )),
                                  )).toList()
                                ,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: keyboardmiddle.map((e) => Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(onPressed: () {setState(() {searchKey += e;});}, child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(e, style: TextStyle(fontSize: FontSize.xxLarge.size)),
                                  ),
                                      style: ButtonStyle(
                                          backgroundColor: MaterialStateProperty.resolveWith((states) => getColor(states))
                                      )),
                                )).toList(),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: keyboardbottom.map((e) => Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(onPressed: () {setState(() {searchKey += e;});}, child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(e, style: TextStyle(fontSize: FontSize.xxLarge.size)),
                                  ),
                                      style: ButtonStyle(
                                          backgroundColor: MaterialStateProperty.resolveWith((states) => getColor(states))
                                      )),
                                )).toList(),
                              ),
                              Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(onPressed: () {setState(() {
                                    searchKey += " ";
                                  });}, child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("             Space             ", style: TextStyle(fontSize: FontSize.xxLarge.size)),
                                  ),
                                      style: ButtonStyle(
                                          backgroundColor: MaterialStateProperty.resolveWith((states) => getColor(states))
                                      )),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ) : SizedBox(),
                  infoMenu ? Container(
                    color: Colors.black.withOpacity(0.8),
                    child: Center(
                      child: Container(
                        margin: EdgeInsets.all(80.0),
                        color: Color(0xff151515),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 40.0,
                            ),
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
                              flex: 3,
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
                                    Row(
                                      children: [
                                        ElevatedButton(
                                          onFocusChange: (bool b) {
                                            setState(() {
                                              hasChanged = b;
                                            });
                                          },
                                          autofocus: true,
                                          onPressed: totaleps!=0 ? () {
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
                                        ),
                                        SizedBox(
                                          width: 40.0,
                                        ),
                                        ElevatedButton(
                                          onFocusChange: (bool b) {
                                            setState(() {
                                              hasCloseChanged = b;
                                            });
                                          },
                                          onPressed: () {
                                            setState(() {
                                              infoMenu = false;
                                            });
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 25.0),
                                            child: Icon(
                                              Icons.close,
                                              size: 1/30 * MediaQuery.of(context).size.height,
                                              color: Colors.black,
                                            ),
                                          ),
                                          style: ButtonStyle(
                                              backgroundColor: totaleps != 0 ? (hasCloseChanged ? MaterialStateProperty.all(const Color(0xff66fff7)) : MaterialStateProperty.all(const Color(0xffd5d5d5))) : MaterialStateProperty.all(Colors.redAccent),
                                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(25.0),
                                                  )
                                              )
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ) : SizedBox()
                ]
              ),
          ),
        ),
      ],
    );
  }
}
