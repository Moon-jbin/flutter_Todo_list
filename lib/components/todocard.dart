import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../todo.dart';

// Todo 리스트의 카드 클래스 위젯이다.
class ToDoCard extends StatefulWidget {
  const ToDoCard({Key? key}) : super(key: key);

  @override
  _ToDoCardState createState() => _ToDoCardState();
}

class _ToDoCardState extends State<ToDoCard> {
  //할 일 목록을 저장할 변수와 입력받은 할 일 문자열을 조작하는 컨트롤러가 필요하다. (TextEditingController)
  // final _items = <ToDo>[]; // 할일 저장할 리스트 이다.
  // 나중에 배열형태를 map 형식을 돌려서 item list 식으로 보여줄 것이다.
  // 하지만 이 _items는 firebase와 연동 한다면 사용하지 않는다.

  final _todoController = TextEditingController();
  String textContent = '';

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
                onChanged: (value){
                  setState(() {
                    textContent = value;
                  });
                }
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
            // flutter 에서는 StreamBuilder를 사용해 stream 처리를 한다.
            stream: FirebaseFirestore.instance.collection('todo').snapshots(),
            // firestore에 있는 todo컬렉션에 있는 데이터들을 가지고 온다.
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
                // snapshot에 데이터를 가지고 있지 않다면
                // 즉, 아직 못불러 와다면 로딩 화면을 그리라는 코드다.
              }
              final documents = snapshot.data?.docs;
              // snapshot에 data가 있다면 docs에 있는 값을 documnets 변수에 집어넣는다.
              return Expanded(
                  child: ListView(
                      children: documents!
                          .map((doc) => _buildItemWidget(doc))
                          .toList())
                  // documents! 는 null 값이 아니라는 소리다.
                // 그래서 그 값을 map 으로 돌면서 toList()로 배열 형식으로 처리한다는 소리다.
                // 그 내용은 바로 buildItemWidget으로 돌린다.
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
    // doc(snapshot.id) 자동으로 클릭된 todo컬렉션의 문서이름을 불러와 준다.
    // 정말 개편하다......javascript때를 생각하면... 따흑...
  }

  void _toggleTodo(DocumentSnapshot snapshot) {
    FirebaseFirestore.instance
        .collection('todo')
        .doc(snapshot.id)
        .update({'isDone': !snapshot['isDone']});
  }

  Widget _buildItemWidget(DocumentSnapshot snapshot) {
    // 이 _buildItemWidget 은 인자로 데이터 베이스에서의 doc을 snapshot이란 이름으로 받는다.
    final todo = ToDo(snapshot['title'], isDone: snapshot['isDone']);
    // todo 변수는 ToDo()클래스로 인자에다가 데이터 베이스에서 받아오는
    // snapshot['title'], isDone: snapshot['isDone']을 넣는다.
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
