import 'package:flutter/material.dart';
import 'package:random_card_game/game/card_game.dart';
import 'package:random_card_game/tutorial/tutorial.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> setStartWidget() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    var value = pref.getBool("showTutorial");
    value ??= true;
    Widget widget;
    if (value) {
      widget = Tutorial();
    } else {
      widget = const CardGame();
    }
    return widget;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: setStartWidget(),
      builder: (BuildContext context, AsyncSnapshot<Widget> widget) {
        return MaterialApp(
          title: 'Random Card Game',
          theme: ThemeData(
            // This is the theme of your application.
            //
            // TRY THIS: Try running your application with "flutter run". You'll see
            // the application has a blue toolbar. Then, without quitting the app,
            // try changing the seedColor in the colorScheme below to Colors.green
            // and then invoke "hot reload" (save your changes or press the "hot
            // reload" button in a Flutter-supported IDE, or press "r" if you used
            // the command line to start the app).
            //
            // Notice that the counter didn't reset back to zero; the application
            // state is not lost during the reload. To reset the state, use hot
            // restart instead.
            //
            // This works for code too, not just values: Most code changes can be
            // tested with just a hot reload.
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: widget.data,
        );
      }
    );
  }
}
