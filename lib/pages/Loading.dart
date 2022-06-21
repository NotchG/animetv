import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class Loading extends StatelessWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Center(
          child: Image.asset(
            'assets/notchginc.gif',
          )
        ),
      ),
    );
  }
}

/*
AnimatedTextKit(
            animatedTexts: [
              RotateAnimatedText(
                  "NotchG Inc.",
                  duration: Duration(milliseconds: 2500),
                  textStyle: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.1,
                    color: Colors.white
                  )
              ),
              RotateAnimatedText(
                  "Loading...",
                  duration: Duration(milliseconds: 2500),
                  textStyle: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.1,
                      color: Colors.white
                  )
              )
            ],
            repeatForever: true,
            pause: Duration(milliseconds: 2000),
          ),
 */
