import 'package:flutter/material.dart';
import 'package:flash_chat/Components/rounded_button.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation animation, animation2;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );

    animation = CurvedAnimation(parent: controller, curve: Curves.decelerate);
    animation2 =
        ColorTween(begin: Colors.black.withOpacity(1), end: Colors.white)
            .animate(controller);

    controller.forward();

    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: animation2.value,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Hero(
                  tag: 'logo',
                  child: Container(
                    child: Image.asset('images/logo.png'),
                    height: animation.value * 90,
                  ),
                ),
                AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText('Flash Chat',
                        textStyle: TextStyle(
                          fontSize: 45.0,
                          fontWeight: FontWeight.w900,
                        ),
                        speed: Duration(milliseconds: 200))
                  ],
                  isRepeatingAnimation: true,
                  totalRepeatCount: 2,
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            RoundedButton(
              buttonColor: Colors.blue,
              buttonText: 'login',
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
            ),
            RoundedButton(
              buttonColor: Colors.blueAccent,
              buttonText: 'Register',
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
            ),
            Row(
              children: <Widget>[
                Expanded(child: SizedBox(width: 150.0, height: 65)),
                const Text(
                  'Instant',
                  style: TextStyle(fontSize: 13.0, fontStyle: FontStyle.italic),
                ),
                Expanded(
                  child: DefaultTextStyle(
                    style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Horizon',
                        color: Colors.amber),
                    child: AnimatedTextKit(
                      animatedTexts: [
                        RotateAnimatedText('MESSAGING'),
                        RotateAnimatedText('HAPPINESS'),
                      ],
                      isRepeatingAnimation: true,
                      repeatForever: true,
                      pause: Duration(milliseconds: 0),
                      onTap: () {
                        print("Tap Event");
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
