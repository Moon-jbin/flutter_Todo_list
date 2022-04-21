import 'package:flutter/material.dart';

import '../components/todocard.dart';



class ToDoListPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: GlobalKey<ScaffoldState>(),
      appBar: AppBar(
        title: const Text('TODO LIST'),
      ),
      body: ToDoCard(),
    );
  }
}