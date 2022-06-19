import 'package:animetv/services/animescrape.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:dpad_container/dpad_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  int totalEps = 0;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    checkNextEp();
    try {
      final sub = _controller.url.listen((event) {
        if (event.contains("nextEpisodeNotchG")) {
          if (currEps < totalEps) {
            AnimeScrape(url: Url.replaceAll("https://gogoanime.fi", "") +
                (currEps + 1).toString()).getPlayer().then((value) =>
                _controller.loadUrl(value));
            setState(() {
              currEps++;
              isPause = true;
            });
            autoPlayEp();
          }
        }
      });
    } catch (e) {
      Navigator.pop(context);
    }

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

  void checkNextEp() async {
    await Future.delayed(Duration(seconds: 1));
    await _controller.executeScript('if(document.getElementsByClassName("jw-progress jw-reset")[0].style.width == "100%") {window.location.replace("nextEpisodeNotchG");}');
    await _controller.executeScript('document.getElementsByTagName("iframe")[document.getElementsByTagName("iframe").length - 1].remove();');
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
                AnimeScrape(url: Url.replaceAll("https://gogoanime.fi", "") + currEps.toString()).getPlayer().then((value) => _controller.loadUrl(value));
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
            AnimeScrape(url: Url.replaceAll("https://gogoanime.fi", "") + currEps.toString()).getPlayer().then((value) => _controller.loadUrl(value));
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


  @override
  Widget build(BuildContext context) {

    if (data.isEmpty) {
      String temp = "";
      data = ModalRoute.of(context)!.settings.arguments as Map;
      Url = data['url'].toString();
      totalEps = data['totalEps'];
      AnimeScrape(url: Url.replaceAll("https://gogoanime.fi", "") + currEps.toString()).getPlayer().then((value) => _controller.loadUrl(value));
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

    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          DpadContainer(
              onClick: () {},
              child: SizedBox(),
              onFocus: (bool b) {
                setState(() {
                  onMenu = !b;
                });
              }),
          Container(
            width: onMenu ? MediaQuery.of(context).size.width : 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onHover: (bool b) {

                      },
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith((states) => getColor(states))
                      ),
                      onPressed: () async {
                        await _controller.executeScript('document.getElementsByTagName("video")[0].click();');
                        setState(() {
                          isPause = !isPause;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(isPause ? Icons.play_arrow : Icons.pause, size: 1/50 * MediaQuery.of(context).size.width,),
                      ),
                    ),
                    SizedBox(
                      width: 40.0,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await _controller.executeScript('document.getElementsByTagName("iframe")[document.getElementsByTagName("iframe").length - 1].remove();');
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Delete Ad", style: TextStyle(fontSize: 1/70 * MediaQuery.of(context).size.width),),
                      ),
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith((states) => getColor(states)),
                          elevation: MaterialStateProperty.all(0)
                      ),
                    ),
                    SizedBox(
                      width: 25.0,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if(!isPause) {
                          await _controller.executeScript('document.getElementsByTagName("video")[0].click();');
                        }
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Back", style: TextStyle(fontSize: 1/70 * MediaQuery.of(context).size.width),),
                      ),
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith((states) => getColor(states)),
                          elevation: MaterialStateProperty.all(0)
                      ),
                    ),
                    SizedBox(
                      width: 25.0,
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          await _controller.executeScript('document.getElementsByTagName("video")[0].click();');
                          await _controller.executeScript('document.getElementsByTagName("video")[0].click();');
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("FullScreen", style: TextStyle(fontSize: 1/70 * MediaQuery.of(context).size.width),),
                        ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith((states) => getColor(states)),
                        elevation: MaterialStateProperty.all(0)
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 20.0,),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for(int i = 1;i <= totalEps;i++) episodesButton(i)
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
      body: Center(
        child: compositeView(),
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

class ImageCard extends StatefulWidget {
  const ImageCard({Key? key, required this.ep}) : super(key: key);

  final int ep;

  @override
  _ImageCardState createState() => _ImageCardState();
}

class _ImageCardState extends State<ImageCard> {
  bool hasChange = false;
  bool isClicked = false;

  @override
  Widget build(BuildContext context) {
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

    return Row(
      children: [
        (
            ElevatedButton(
              onPressed: () {
                setState(() {
                  currEps = widget.ep;
                });
                AnimeScrape(url: Url.replaceAll("https://gogoanime.fi", "") + currEps.toString()).getPlayer().then((value) => _controller.loadUrl(value));
                setState(() {
                  currEps = widget.ep;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(widget.ep.toString(), style: TextStyle(fontSize: 1/80 * MediaQuery.of(context).size.width),),
              ),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith((states) => getColor(states, widget.ep == currEps)),
                  elevation: MaterialStateProperty.all(0)
              ),
            )
        ),
        SizedBox(width: 10.0,)
      ],);
  }
}
