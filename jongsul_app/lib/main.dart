import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'ui/AlertCard.dart';
import 'ui/connect_button.dart';
import 'ui/crtl_box.dart';
import 'provider/app_state.dart';
import 'provider/connect_state.dart';
import 'ui/setting.dart';
import 'ui/videdodisplay.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => MyAppState(),
        ),
        ChangeNotifierProvider(
          create: (context) => ConeectState(),
        )
      ],
      child: MaterialApp(
        title: 'Observer',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blueAccent, brightness: Brightness.dark),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Setting(),
        title: Text("Active Violation Dectect Syetem"),
        centerTitle: true,
        actions: [
          ConnectButton(),
        ],
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 640, height: 480, child: VideoDisplay()),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AlertCard(),
              SizedBox(width: 640, height: 380, child: CtrlBox()),
            ],
          ),
        ],
      ),
    );
  }
}
