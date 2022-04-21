import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../todo.dart';

// Todo 리스트의 카드 클래스 위젯이다.
class ToDoCard extends StatefulWidget {
  @override
  _ToDoCardState createState() => _ToDoCardState();
}

class _ToDoCardState extends State<ToDoCard> {
  //할 일 목록을 저장할 변수와 입력받은 할 일 문자열을 조작하는 컨트롤러가 필요하다. (TextEditingController)
  final _items = <ToDo>[]; // 할일 저장할 리스트 이다.
  // 나중에 배열형태를 map 형식을 돌려서 item list 식으로 보여줄 것이다.
  final _todoController = TextEditingController();

  // TextField를 사용해 입력한 값을 다루기 위해서는 이 컨트롤러가  반드시 필요하다.
  // 이 컨트롤러가 텍스트의 변화를 감지하고 핸들링 해준다.
  // onChange를 쓰는 방법중 다른 하나의 방법이다.
  @override
  void dispose() {
    // dispose()는 라이플 사이클 중 삭제에 해당되는 부분이다.
    // State 객체가 영구적으로 제거 된다는 뜻이다.
    // 즉, 더이상 build가 되지 않는 화면인것이다.
    _todoController.dispose(); // 컨트롤러는 종료시 반드시 해제해줘야 한다.
    // 텍스트에디팅 컨트롤러를 제거하고, 등록된 리스너도 제거된다.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                  child: TextField(
                controller: _todoController,
                // 입력한 text의 값을 실시간으로 감지 시켜주는 controller 이다.
              )),
              ElevatedButton(
                  onPressed: () {
                    _addTodo(ToDo(_todoController.text));
                    // 추가 버튼을 클릭시 _addTodo 가 ToDo(인자)를 인자로 받는데, 이는
                    // 해당 입력을 ToDo(입력한 값) 을 인자로 넘겨준다.
                    // 입력한 값은 title에 해당 될 것이다.
                  },
                  child: const Text(
                    '추가',
                    style: TextStyle(color: Colors.white),
                  ))
            ],
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('todo').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }
              final documents = snapshot.data?.docs;
              return Expanded(
                  child: ListView(
                      children: documents!
                          .map((doc) => _buildItemWidget(doc))
                          .toList())
                  // 이부분이 중요하다.
                  // _items는 현재 빈 배열이다.
                  // 따라서 children은 배열을 갖기 때문에 [] 이부분을 쓰지 않고 바로
                  // _items 를 사용했으며, 해당 배열 item을 map 돌면서 나타내는 함수 형식으로
                  // 코드를 구성했다. (react 때 배열 형태를 map 도는 것과 비슷한 유형이다.)
                  // 단, 마지막에 toList() 를 해야 오류가 안나니 이를 숙지 하도록 하자.
                  );
            },
          )
        ],
      ),
    );
  }

  void _addTodo(ToDo todo) {
    FirebaseFirestore.instance
        .collection('todo')
        .add({'title': todo.title, 'isDone': todo.isDone});
    _todoController.text = '';
  }

  void _deleteTodo(DocumentSnapshot snapshot) {
    // 이것은 삭제 버튼이다, 마찬 가지로 배열에 있는 아이템을
    // 내가 누른 listTile에 있는 삭제 버튼을 누르면 해당 Tile이 삭제 된다.
    FirebaseFirestore.instance
        .collection('todo')
        .doc(snapshot.id)
        .delete();
    print(snapshot.id);
  }

  // 현재 클릭한 문서값을 나타내는 것만 배운다면 firebase 연동
  // CRUD는 완벽하다.
  // 내일은 아침일찍 일어나서 해당 코드 파악 후,
  // 바로 로그인, 로그아웃, 회원가입 공부에 들어가자.

  void _toggleTodo(DocumentSnapshot snapshot) {
    FirebaseFirestore.instance
        .collection('todo')
        .doc(snapshot.id)
        .update({'isDone': !snapshot['isDone']});
  }

  Widget _buildItemWidget(DocumentSnapshot snapshot) {
    // 이 _buildItemWidget 은 인자로 데이터 베이스에서의 doc 을 받는다.
    final todo = ToDo(snapshot['title'], isDone: snapshot['isDone']);
    // todo 변수는 ToDo()클래스로 인자에다가 데이터 베이스에서 받아오는
    // doc['title'], isDone: doc['isDone']을 넣는다.
    return ListTile(
      onTap: () {
        // 클릭하면 완료/ 취소 등의 작업을 할 예정입니다.
        return _toggleTodo(snapshot);
      },
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () {
          // delete icon 클릭시 해당 아이템 삭제하기
          return _deleteTodo(snapshot);
        },
      ),
      title: Text(todo.title,
          style: todo.isDone
              ? const TextStyle(
                  decoration: TextDecoration.lineThrough,
                  fontStyle: FontStyle.italic)
              : null),
    );
  }
}
