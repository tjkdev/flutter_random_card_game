import 'package:flutter/material.dart';
import 'package:random_card_game/game/card_game.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Tutorial extends StatelessWidget {
  Tutorial({super.key});

  final PageController pageController = PageController(initialPage: 0);

  final List<Widget> pages = [
    SizedBox.expand(
      child: Container(
        alignment: Alignment.center,
        child: Image.asset(
          'images/tutorial1.png',
        ),
      ),
    ),
    SizedBox.expand(
      child: Container(
        alignment: Alignment.center,
        child: Image.asset(
          'images/tutorial2.png',
        ),
      ),
    ),
    SizedBox.expand(
      child: Container(
        alignment: Alignment.center,
        child: Image.asset(
          'images/tutorial3.png',
        ),
      ),
    )
  ];

  void setTutorialDisable() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setBool("showTutorial", false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    itemCount: pages.length,
                    controller: pageController,
                    itemBuilder: (_, index) {
                      return pages[index];
                    },
                  ),
                ),
                SmoothPageIndicator(
                  controller: pageController,
                  count: pages.length,
                  effect: const SlideEffect(),
                )
              ]
            ),
            Positioned(
              right: 0,
              child: OutlinedButton(
                onPressed: () {
                  setTutorialDisable();
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CardGame()));
                },
                child: const Text(
                  "Start",
                  style: TextStyle(
                    fontSize: 20.0
                  ),
                )
              ),
            )
          ],
        ),
      ),
    );
  }
}