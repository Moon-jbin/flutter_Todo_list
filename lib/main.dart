import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todolistapp/pages/todolistpage.dart';
import 'package:firebase_core/firebase_core.dart';
// WidgetsFlutterBinding.ensureInitialized()를 사용하기 위해선
// firebase_core 패키지를 설치해야 한다.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: 'AIzaSyAxjogFj4A8SOY7867DzC294MnQBsSdmHg',
          appId: '1:600765676289:android:c5d8e7e39a7135f274b900',
          messagingSenderId: '600765676289',
          projectId: 'flutter-to-do-list-be786'
      )
  );
  // 위의 방식은 flutter와 firebase의 연동에 있어서 필수적인 코드 방식이다.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ToDo App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: ToDoListPage(),
    );
  }
}