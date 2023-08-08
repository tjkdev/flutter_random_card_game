import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:random_card_game/game/game_result.dart';
import 'package:random_card_game/repository.dart';
import 'package:random_card_game/game/enemy.dart';

import 'card_status.dart';

class CardGame extends StatefulWidget {
  const CardGame({super.key});

  @override
  State<StatefulWidget> createState() => _CardGameState();
}

class _CardGameState extends State<CardGame> {
  var repo = Repository();

  List<Enemy> enemies = [];

  List<Widget> myCardViews = [];
  List<CardStatus> myCardStatuses = [];
  List<Widget> enemyCardViews = [];
  List<CardStatus> enemyCardStatuses = [];

  int level = 0;
  int currentEnemyIndex = -1;
  int myChosenCardIndex = -1;
  int myWinCount = 0;
  int enemyWinCount = 0;
  int drawCount = 0;
  bool isBattleFinished = false;

  double screenWidth = 0.0;
  double screenHeight = 0.0;

  @override
  void initState() {
    super.initState();

    loadUserInfo();
  }

  void loadUserInfo() async {
    repo.getUsers().then((value) {
      setState(() {
        if (value is List<Enemy>) {
          enemies = value;
          currentEnemyIndex = 0;
          initData();
        } else if (value is DioError) {
          showDialog(context: context, builder: (context) {
            return AlertDialog(
                surfaceTintColor: Colors.white,
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)
              ),
              title: const Column(
                children: [
                  Text("Http Error")
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value.message)
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("ok")
                )
              ],
            );
          });
        }
      });
    });
  }

  void initData() {
    setLevel(enemies[currentEnemyIndex].id);
    if (level > 0) {
      initEnemyCardStatuses();
      initMyCardStatuses();
      myWinCount = 0;
      enemyWinCount = 0;
      drawCount = 0;
      isBattleFinished = false;
    }

    Future.delayed(const Duration(seconds: 1), () {
      unlockMyCardView();
    });
  }

  void getDeviceScreen() {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
  }

  void setLevel(int id) {
    switch(id) {
      case > -1 && < 3:
        level = 1;
        break;
      case > 3 && < 6:
        level = 2;
        break;
      case > 5:
        level = 3;
        break;
      case < 0:
        Fluttertoast.showToast(
          msg: "invalid current enemy index.",
          gravity: ToastGravity.BOTTOM
        );
        break;
    }
  }

  void initEnemyCardStatuses() {
    enemyCardStatuses.clear();

    var maxCardValue = 9; // card value 1 ~ 9
    List<int> cardValues = [];

    while (true) {
      var randomCardValue = Random().nextInt(maxCardValue) + 1;
      if (!cardValues.contains(randomCardValue)) {
        cardValues.add(randomCardValue);
        enemyCardStatuses.add(CardStatus.enemyCardDefault(randomCardValue));
      }

      if (cardValues.length == maxCardValue) break;
    }
  }

  void initEnemyCards() {
    enemyCardViews.clear();

    if (enemyCardStatuses.length > level + 1) {
      for (var i = 0; i < level + 2; i++) {
        enemyCardViews.add(makeEnemyCardView(i, enemyCardStatuses[i]));
      }
    }
  }

  double initEnemyCardAnimationStartPosition(int index) {
    double result = 0.0;
    switch (level) {
      case 1:
        result = - screenWidth * 0.08 + (screenWidth * 0.25 * (index + 1));
        break;
      case 2:
        result = - screenWidth * 0.08 + (screenWidth * 0.2 * (index + 1));
        break;
      case 3:
        result = - screenWidth * 0.115 + (screenWidth * 0.18 * (index + 1));
        break;
    }
    return result;
  }

  void chooseEnemyCard() {
    while (true) {
      var chosenCardIndex = Random().nextInt(enemyCardViews.length);
      if (!enemyCardStatuses[chosenCardIndex].isSlideAnimationDone) {
        setState(() {
          enemyCardStatuses[chosenCardIndex].isSlideAnimationDone = true;
        });
        break;
      }
    }
  }

  void initMyCardStatuses() {
    myCardStatuses.clear();
    myCardStatuses = [
      CardStatus.myCardDefault(), CardStatus.myCardDefault(), CardStatus.myCardDefault(), CardStatus.myCardDefault()
    ];

    var maxCardValue = 9; // card value 1 ~ 9
    List<int> cardValues = [];

    while (true) {
      var randomCardValue = Random().nextInt(maxCardValue) + 1;
      if (!cardValues.contains(randomCardValue)) {
        cardValues.add(randomCardValue);
      }

      if (cardValues.length == maxCardValue) break;
    }

    for (int i = 0; i < myCardStatuses.length; i++) {
      myCardStatuses[i].value = cardValues[i];
    }
  }

  void initMyCards() {
    myCardViews.clear();

    for (var i = 0; i < myCardStatuses.length; i++) {
      myCardViews.add(makeMyCardView(i, myCardStatuses[i]));
    }
  }

  void openChosenCards(CardStatus status) {
    if (myChosenCardIndex > -1) {
      setState(() {
        status.isOpenAnimationDone = true;
      });
    }
  }

  void compareChosenCardValues(int enemyChosenCardIndex) {
    if (myChosenCardIndex > -1 && enemyChosenCardIndex > -1) {
      var myCardValue = myCardStatuses[myChosenCardIndex].value;
      var enemyCardValue = enemyCardStatuses[enemyChosenCardIndex].value;

      if (myCardValue > enemyCardValue) {
        Fluttertoast.showToast(
          msg: "You Win!",
          gravity: ToastGravity.BOTTOM
        );
        myWinCount += 1;
      } else if (myCardValue == enemyCardValue) {
        Fluttertoast.showToast(
          msg: "Draw Game.",
          gravity: ToastGravity.BOTTOM
        );
        drawCount += 1;
      } else {
        Fluttertoast.showToast(
          msg: "You Lost!",
          gravity: ToastGravity.BOTTOM
        );
        enemyWinCount += 1;
      }

      sleep(const Duration(milliseconds: 1000));
      setState(() {
        myCardStatuses[myChosenCardIndex].isRemoveAnimationDone = true;
        enemyCardStatuses[enemyChosenCardIndex].isRemoveAnimationDone = true;
      });
      checkIsBattleFinished();
      myChosenCardIndex = -1;
    }
  }

  void checkIsBattleFinished() {
    GameResult result = GameResult.none;
    if (myWinCount > 1) {
      result = GameResult.win;
      isBattleFinished = true;
    } else if (enemyWinCount > 1) {
      result = GameResult.lost;
      isBattleFinished = true;
    } else if (myWinCount + drawCount + enemyWinCount == 3) {
      if (myWinCount > enemyWinCount) {
        result = GameResult.win;
      } else if (enemyWinCount > myWinCount) {
        result = GameResult.lost;
      } else {
        result = GameResult.draw;
      }
      isBattleFinished = true;
    }

    if (isBattleFinished) {
      showBattleResult(result);
    } else {
      unlockMyCardView();
    }
  }

  void lockMyCardView() {
    for (var status in myCardStatuses) {
      status.isClickable = false;
    }
  }

  void unlockMyCardView() {
    for (var status in myCardStatuses) {
      if (!status.isRemoveAnimationDone) {
        status.isClickable = true;
      }
    }
  }

  void showBattleResult(GameResult result) {
    switch (result) {
      case GameResult.win:
        toNextLevel();
        break;
      case GameResult.draw:
        initData();
        break;
      case GameResult.lost:
        showLostToast();
        break;
      case GameResult.none:
        break;
    }
  }

  void toNextLevel() {
    getNextEnemy();
  }

  void getNextEnemy() {
    if (currentEnemyIndex + 1 == enemies.length) {
      Fluttertoast.showToast(
          msg: "You beaten every enemy!",
          gravity: ToastGravity.BOTTOM
      );
    } else {
      currentEnemyIndex += 1;
      initData();
    }
  }

  void showLostToast() {
    Fluttertoast.showToast(
      msg: "You failed. Try again!",
      gravity: ToastGravity.BOTTOM
    );
  }

  Widget initEnemyInfoView() {
    initEnemyCards();
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (enemies.isNotEmpty) Image.network(
            enemies[currentEnemyIndex].imageUrl,
            width: screenHeight * 0.1,
            height: screenHeight * 0.1,
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (enemies.isNotEmpty) Text(
                "${enemies[currentEnemyIndex].firstName} ${enemies[currentEnemyIndex].lastName}",
                style: const TextStyle(
                  fontSize: 25
                ),
              ),
              if (enemies.isNotEmpty) Text(
                enemies[currentEnemyIndex].email,
                style: const TextStyle(
                    fontSize: 15
                )
              ),
              Text(
                "Lv. $level",
                style: const TextStyle(
                    fontSize: 15
                )
              )
            ],
          )
        ],
      ),
    );
  }

  Widget makeEnemyCardView(int index, CardStatus status) {
    return Container(
      alignment: Alignment.center,
      width: screenWidth,
      height: screenHeight * 0.38,
      child: AnimatedOpacity(
        opacity: status.isRemoveAnimationDone ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 500),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedPositioned(
              top: status.isSlideAnimationDone ? screenHeight * 0.38 - 120 : 0.0,
              left: status.isSlideAnimationDone ? screenWidth * 0.4 : initEnemyCardAnimationStartPosition(index),
              duration: const Duration(milliseconds: 300),
              onEnd: () {
                openChosenCards(status);
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(5)
                    ),
                    width: 60,
                    height: 80,
                    child: Text(
                      status.value.toString(),
                      style: const TextStyle(
                          fontSize: 25
                      )
                    )
                  ),
                  AnimatedOpacity(
                    opacity: status.isOpenAnimationDone ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    onEnd: () {
                      compareChosenCardValues(index);
                    },
                    child: Image.asset(
                      'images/trump_card.jpg',
                      width: 60,
                      height: 120,
                    ),
                  )
                ]
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget makeMyCardView(int index, CardStatus status) {
    return Container(
      alignment: Alignment.center,
      width: screenWidth,
      height: screenHeight * 0.38,
      child: AnimatedOpacity(
        opacity: status.isRemoveAnimationDone ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 500),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedPositioned(
              top: status.isSlideAnimationDone ? 0.0 : screenHeight * 0.38 - 120,
              left: status.isSlideAnimationDone ? screenWidth * 0.4 : - screenWidth * 0.08 + (screenWidth * 0.2 * (index + 1)),
              duration: const Duration(milliseconds: 300),
              onEnd: () {
                if (status.isSlideAnimationDone) {
                  chooseEnemyCard();
                }
              },
              child: GestureDetector(
                onTap: () {
                  if (status.isClickable) {
                    lockMyCardView();
                    setState(() {
                      status.isSlideAnimationDone = true;
                      myChosenCardIndex = index;
                    });
                  }
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(5)
                      ),
                      width: 60,
                      height: 80,
                      child: Text(
                        status.value.toString(),
                        style: const TextStyle(
                          fontSize: 25
                        )
                      )
                    )
                  ]
                ),
              ),
            )
          ]
        ),
      ),
    );
  }

  Widget initEnemyCardDeckView() {
    return Stack(
      children: [
        for (Widget cardView in enemyCardViews) cardView
      ],
    );
  }

  Widget initMyCardDeckView() {
    initMyCards();
    return Stack(
      children: [
        for (Widget cardView in myCardViews) cardView
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    getDeviceScreen();
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                initEnemyInfoView(),
                initEnemyCardDeckView(),
                const Spacer(),
                initMyCardDeckView(),
              ],
            ),
            Container(
              alignment: AlignmentDirectional.centerStart,
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Spacer(),
                  const SizedBox(height: 90),
                  Text(
                    "$enemyWinCount",
                    style: const TextStyle(
                        fontSize: 60.0
                    )
                  ),
                  Text(
                    "$myWinCount",
                    style: const TextStyle(
                        fontSize: 60.0
                    )
                  ),
                  const Spacer()
                ],
              ),
            ),
            Container(
              alignment: AlignmentDirectional.center,
              padding: const EdgeInsets.only(top: 60),
              child: Visibility(
                visible: isBattleFinished,
                child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        currentEnemyIndex = 0;
                        initData();
                      });
                    },
                    child: const Text(
                      "Retry",
                      style: TextStyle(
                        fontSize: 30.0
                      ),
                    )
                ),
              ),
            ),
          ]
        ),
      ),
    );
  }
}