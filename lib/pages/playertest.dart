import 'package:animetv/services/animescrape.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:disposebag/disposebag.dart';
import 'package:dpad_container/dpad_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';

import 'package:webview_windows/webview_windows.dart';

final navigatorKey = GlobalKey<NavigatorState>();
int currEps = 1;
String Url = "";
final _controller = WebviewController();
class Player extends StatefulWidget {
  const Player({Key? key}) : super(key: key);

  @override
  _PlayerState createState() => _PlayerState();
}

class _PlayerState extends State<Player> {

  bool _isWebviewSuspended = false;
  Map data = {};
  String title = "";

  String baseUrl = "gogoanime.lu";
  int totalEps = 0;

  double currSec = 0;
  bool hideMenu = false;
  bool stopEverything = false;

  DisposeBag bag = DisposeBag();

  final streamController = BehaviorSubject<String>();

  int timer = 5;

  void hideMenuTimer() async {
    if(stopEverything) {
      return;
    }
    await Future.delayed(Duration(seconds: 1));
    if(stopEverything) {
      return;
    }
    if (timer == 0) {
      if(!hideMenu) {
        if (mounted) {
          setState(() {
            hideMenu = true;
          });
        }
      }
      hideMenuTimer();
    } else {
      timer--;
      hideMenuTimer();
    }
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
    Future.delayed(Duration(seconds: 1)).whenComplete(() {
    videoSlider();
        hideMenuTimer();
    deleteAd();
  });

    final sub = _controller.title.listen(streamController.add);
    streamController.listen((e) {
      if (mounted) {
        setState(() {
          currSec = double.tryParse(e) ?? 0;
        });
      }
    });
    bag.add(sub);
    bag.add(streamController);
  }

  void initContTitleStream() async {
    /*var sub = _controller.title.listen((event) {
      setState(() {
        currSec = double.tryParse(event) ?? 0;
      });
    });*/
      final sub = _controller.title.listen(streamController.add);
      streamController.listen((e) {
          currSec = double.tryParse(e) ?? 0;
      });
    while(!stopEverything) {
      await Future.delayed(Duration(seconds: 1));
    }
    print("initContTitleStream Stopped");
  }

  void videoSlider() async {
    if(stopEverything) {
      return;
    }
    await _controller.executeScript('document.title = parseFloat(document.getElementsByClassName("jw-progress jw-reset")[0].style.width)');
    print("slider");
    videoSlider();
  }

  void autoPlayEp() async {
    await Future.delayed(Duration(seconds: 15));
    await _controller.executeScript('document.getElementsByTagName("video")[0].click();');
    await _controller.executeScript('document.getElementsByTagName("video")[0].click();');
    await _controller.executeScript('document.getElementsByTagName("video")[0].click();');
    setState(() {
      isPause = false;
    });
  }

  void deleteAd() async {
    if(stopEverything) {
      return;
    }
    await _controller.executeScript('document.getElementsByTagName("iframe")[document.getElementsByTagName("iframe").length - 1].remove();');
    deleteAd();
  }

  void checkNextEp() async {
    await Future.delayed(Duration(seconds: 1));
    await _controller.executeScript('if(document.getElementsByClassName("jw-progress jw-reset")[0].style.width == "100%") {window.location.replace("nextEpisodeNotchG");}');
    checkNextEp();
  }

  void fullscreen() async {
    await _controller.ready;
  }

  Color getColor(Set<MaterialState> states, bool curr) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.greenAccent;
    }
    if (curr) {
      return Colors.redAccent;
    } else {
      return Colors.blueAccent;
    }

  }

  Widget episodesButton(int ep) {
    return Row(
      children: [
        (
            ElevatedButton(
              onPressed: () {
                setState(() {
                  currEps = ep;
                });
                AnimeScrape(url: Url.replaceAll("https://" + baseUrl + "", "") + currEps.toString()).getPlayer().then((value) => _controller.loadUrl(value));
                setState(() {
                  currEps = ep;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(ep.toString(), style: TextStyle(fontSize: 1/80 * MediaQuery.of(context).size.width),),
              ),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith((states) => getColor(states, ep == currEps)),
                  elevation: MaterialStateProperty.all(0)
              ),
            )
        ),
        SizedBox(width: 10.0,)
      ],);
  }

  @override
  void dispose() async {
      await bag.dispose();
      super.dispose();

  }


  Future<void> initPlatformState() async {
    // Optionally initialize the webview environment using
    // a custom user data directory
    // and/or a custom browser executable directory
    // and/or custom chromium command line flags
    //await WebviewController.initializeEnvironment(
    //    additionalArguments: '--show-fps-counter');

    try {
      await _controller.initialize();

      await _controller.setBackgroundColor(Colors.transparent);
      await _controller.setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);
      fullscreen();
      if (!mounted) return;
      setState(() {});
    } on PlatformException catch (e) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('Error'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Code: ${e.code}'),
                  Text('Message: ${e.message}'),
                ],
              ),
              actions: [
                TextButton(
                  child: Text('Continue'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            ));
      });
    }
  }

  Widget compositeView() {
    if (!_controller.value.isInitialized) {
      return const Text(
        'Not Initialized',
        style: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return Column(
        children: [
          Expanded(
            child: Card(
                color: Colors.transparent,
                elevation: 0,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: Stack(
                  children: [
                    Webview(
                      _controller,
                      permissionRequested: _onPermissionRequested,
                    ),
                  ],
                )),
          ),
        ],
      );
    }
  }

  Widget EpisodeButton(int ep) {
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.greenAccent;
      }
      return ep == currEps ? Colors.redAccent : Colors.blueAccent;
    }

    return(
        ElevatedButton(
          onPressed: () {
            currEps = ep;
            AnimeScrape(url: Url.replaceAll("https://" + baseUrl + "", "") + currEps.toString()).getPlayer().then((value) => _controller.loadUrl(value));
            setState(() {

            });
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(ep.toString(), style: TextStyle(fontSize: 1/80 * MediaQuery.of(context).size.width),),
          ),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith((states) => getColor(states)),
              elevation: MaterialStateProperty.all(0)
          ),
        )
    );
  }
  bool onMenu = true;
  bool isPause = true;
  bool pauseButton = false;
  bool back10secButton = false;
  bool forward10secButton = false;
  bool fullscreenButton = false;
  bool backButton = false;
  bool episodeMenuButton = false;

  void initializeAnime() async {
    if (!_controller.value.isInitialized) {
      await Future.delayed(const Duration(seconds: 1));
      initializeAnime();
    } else {
      AnimeScrape(url: Url.replaceAll("https://" + baseUrl + "", "") + currEps.toString()).getPlayer().then((value) => _controller.loadUrl(value));
    }
  }

  @override
  Widget build(BuildContext context) {

    if (data.isEmpty) {
      data = ModalRoute.of(context)!.settings.arguments as Map;
      Url = data['url'].toString();
      totalEps = data['totalEps'];
      title = data['title'].toString();
      initializeAnime();
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
    return RawKeyboardListener(
      autofocus: true,
      onKey: (e) {
        timer = 5;
        setState(() {
          hideMenu = false;
        });
      },
      focusNode: FocusNode(),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Center(
            child: compositeView(),
          ),
            hideMenu ? SizedBox() : Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      gradient: LinearGradient(
                          begin: FractionalOffset.topCenter,
                          end: FractionalOffset.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(1),
                            Colors.black.withOpacity(0)
                          ],
                          stops: const [
                            0.0,
                            0.3
                          ]
                      )
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 20.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Row(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      stopEverything = true;
                                      //await bag.dispose();
                                      dispose();
                                      //await streamController.close();
                                      Navigator.pop(context);
                                    },
                                    style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all(Colors.transparent),
                                        overlayColor: MaterialStateProperty.all(Colors.transparent),
                                        elevation: MaterialStateProperty.all(0)
                                    ),
                                    onFocusChange: (bool b) {
                                      setState(() {
                                        backButton = b;
                                      });
                                    },
                                    icon: Icon(
                                      Icons.arrow_back_ios,
                                      size: 1/30 * MediaQuery.of(context).size.width,
                                      color: backButton ? Colors.greenAccent : Colors.white,
                                    ), label: SizedBox(),
                                  ),
                                  Text(
                                    title,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.0
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () async {

                                    },
                                    style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all(Colors.transparent),
                                        overlayColor: MaterialStateProperty.all(Colors.transparent),
                                        elevation: MaterialStateProperty.all(0)
                                    ),
                                    onFocusChange: (bool b) {
                                      setState(() {
                                        episodeMenuButton = b;
                                      });
                                    },
                                    icon: Icon(
                                      Icons.video_collection_sharp,
                                      size: 1/30 * MediaQuery.of(context).size.width,
                                      color: episodeMenuButton ? Colors.greenAccent : Colors.white,
                                    ), label: SizedBox(),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: onMenu ? MediaQuery.of(context).size.width : 0,
                        child: Stack(
                            alignment: AlignmentDirectional.bottomCenter,
                            children: [
                              Container(
                                height: MediaQuery.of(context).size.height,
                                width: MediaQuery.of(context).size.width,
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
                                  Padding(
                                    padding: const EdgeInsets.all(30.0),
                                    child: SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        disabledActiveTrackColor: Colors.white,
                                        disabledInactiveTrackColor: Colors.grey,
                                        disabledThumbColor: Colors.white,
                                      ),
                                      child: Slider(
                                        value: currSec,
                                        onChanged: null,
                                        min: 0.0,
                                        max: 100.0,
                                        inactiveColor: Colors.white,
                                        thumbColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          await _controller.executeScript('document.getElementsByClassName("jw-icon jw-icon-inline jw-button-color jw-reset jw-icon-rewind")[0].click()');
                                        },
                                        style: ButtonStyle(
                                            backgroundColor: MaterialStateProperty.all(Colors.transparent),
                                            overlayColor: MaterialStateProperty.all(Colors.transparent),
                                            elevation: MaterialStateProperty.all(0)
                                        ),
                                        onFocusChange: (bool b) {
                                          setState(() {
                                            back10secButton = b;
                                          });
                                        },
                                        icon: Icon(
                                          Icons.fast_rewind,
                                          size: 1/25 * MediaQuery.of(context).size.width,
                                          color: back10secButton ? Colors.greenAccent : Colors.white,
                                        ), label: SizedBox(),
                                      ),
                                      SizedBox(
                                        width: 10.0,
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          await _controller.executeScript('document.getElementsByTagName("video")[0].click();');
                                          setState(() {
                                            isPause = !isPause;
                                          });
                                        },
                                        autofocus: true,
                                        style: ButtonStyle(
                                            backgroundColor: MaterialStateProperty.all(Colors.transparent),
                                            overlayColor: MaterialStateProperty.all(Colors.transparent),
                                            elevation: MaterialStateProperty.all(0)
                                        ),
                                        onFocusChange: (bool b) {
                                          setState(() {
                                            pauseButton = b;
                                          });
                                        },
                                        icon: Icon(
                                          isPause ? Icons.play_circle : Icons.pause_circle,
                                          size: 1/25 * MediaQuery.of(context).size.width,
                                          color: pauseButton ? Colors.greenAccent : Colors.white,
                                        ), label: SizedBox(),
                                      ),
                                      SizedBox(
                                        width: 10.0,
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          await _controller.executeScript('document.getElementsByClassName("jw-icon jw-icon-inline jw-button-color jw-reset")[9].click()');
                                        },
                                        style: ButtonStyle(
                                            backgroundColor: MaterialStateProperty.all(Colors.transparent),
                                            overlayColor: MaterialStateProperty.all(Colors.transparent),
                                            elevation: MaterialStateProperty.all(0)
                                        ),
                                        onFocusChange: (bool b) {
                                          setState(() {
                                            forward10secButton = b;
                                          });
                                        },
                                        icon: Icon(
                                          Icons.fast_forward,
                                          size: 1/25 * MediaQuery.of(context).size.width,
                                          color: forward10secButton ? Colors.greenAccent : Colors.white,
                                        ), label: SizedBox(),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 40.0,
                                  )
                                ],
                              ),
                            ]
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              ],
            ),
          ]
        ),
      ),
    );
  }

  Future<WebviewPermissionDecision> _onPermissionRequested(
      String url, WebviewPermissionKind kind, bool isUserInitiated) async {
    final decision = await showDialog<WebviewPermissionDecision>(
      context: navigatorKey.currentContext!,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('WebView permission requested'),
        content: Text('WebView has requested permission \'$kind\''),
        actions: <Widget>[
          TextButton(
            onPressed: () =>
                Navigator.pop(context, WebviewPermissionDecision.deny),
            child: const Text('Deny'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, WebviewPermissionDecision.allow),
            child: const Text('Allow'),
          ),
        ],
      ),
    );

    return decision ?? WebviewPermissionDecision.none;
  }

}
