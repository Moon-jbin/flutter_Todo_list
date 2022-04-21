import 'package:flutter/material.dart';

// Todo에 관한 클래스이다.
// ToDO 클래스는 인자로 isDone, title을 받는다.
class ToDo{
  bool isDone;
  String title;

  // isDone 값은 초기값 설정이 false 이고, title 값을 필수이다.
  ToDo(this.title, {this.isDone = false});
}