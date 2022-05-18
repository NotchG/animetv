import 'package:animetv/pages/hometest.dart';
import 'package:animetv/pages/search.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:animetv/pages/playertest.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Must add this line.
  await windowManager.ensureInitialized();

  // Use it only after calling `hiddenWindowAtLaunch`
  windowManager.waitUntilReadyToShow().then((_) async {
    // Hide window title bar
    await windowManager.setTitleBarStyle('hidden');
    await windowManager.maximize();
  });
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'AnimeTV',
    initialRoute: '/',
    routes: {
      '/': (context) => Home(),
      '/player': (context) => Player()
    },
  ));
}