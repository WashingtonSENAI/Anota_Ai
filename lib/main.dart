import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'tela_inicial.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('carlos main.');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Quizz Brabo',
        home: MyHomePage(),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Color.fromRGBO(25, 88, 123, 1),
          appBarTheme: AppBarTheme(
            color: Color.fromRGBO(25, 88, 123, 1),
          ),
          scaffoldBackgroundColor: Color.fromRGBO(25, 88, 123, 1),
        ));
  }
}
