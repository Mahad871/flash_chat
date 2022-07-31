import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

late String userEmail;

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  var _textController = TextEditingController();
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  String? messageText;
  User? currentLoggedinUser;

  void getCurrentUser() async {
    try {
      final newUser = _auth.currentUser;

      if (newUser != null) {
        currentLoggedinUser = newUser;
        userEmail = currentLoggedinUser!.email!;
        print(currentLoggedinUser?.email);
      }
    } catch (e) {
      print(e);
    }
  }

  void getDataStream() async {
    await for (var snapshot in _fireStore.collection('messages').snapshots()) {
      for (var message in snapshot.docs) {
        print(message.data());
      }
    }
    ;
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                // _auth.signOut();
                // Navigator.pop(context);
                getDataStream();
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MessageBuilder(fireStore: _fireStore),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      onChanged: (value) {
                        messageText = value;
                        //Do something with the user input.
                      },
                      style: TextStyle(color: Colors.black87),
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  Material(
                    child: TextButton(
                      onPressed: () {
                        var sendTime = Timestamp.now();

                        _textController.clear();
                        _fireStore.collection('messages').add({
                          'sender': currentLoggedinUser?.email,
                          'text': messageText,
                          'time': sendTime
                        });
                        //Implement send functionality.
                      },
                      child: Icon(
                        Icons.send,
                        color: Colors.lightBlueAccent,
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBuilder extends StatelessWidget {
  const MessageBuilder({
    Key? key,
    required FirebaseFirestore fireStore,
  })  : _fireStore = fireStore,
        super(key: key);

  final FirebaseFirestore _fireStore;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _fireStore
          .collection('messages')
          .orderBy('time', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!(snapshot.hasData)) {
          EasyLoading.show();
        } else {
          EasyLoading.dismiss();
          final chat = snapshot.data?.docs;
          List<Widget> chatList = [];
          for (var message in chat!) {
            final text = message.get('text');
            final sender = message.get('sender');

            Widget textBubble = MessageBubble(
              text: text,
              sender: sender,
            );

            chatList.add(textBubble);
          }
          return Expanded(
            child: ListView(
              reverse: true,
              children: chatList,
            ),
          );
        }
        return Expanded(
          child: ListView(
            children: [],
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble({
    required this.text,
    required this.sender,
  });

  final String text;
  final String sender;
  CrossAxisAlignment alignment = CrossAxisAlignment.end;
  Color messageColor = Colors.lightBlueAccent;
  Color textColor = Colors.white;
  double topRight = 0, topLeft = 50;
  @override
  Widget build(BuildContext context) {
    if (userEmail != sender) {
      alignment = CrossAxisAlignment.start;
      messageColor = Colors.white;
      textColor = Colors.black;
      topRight = 50;
      topLeft = 0;
    }
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Text(
              sender,
              style: TextStyle(
                fontSize: 10,
              ),
            ),
          ),
          Material(
            elevation: 5,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(topLeft),
                topRight: Radius.circular(topRight),
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50)),
            color: messageColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Text(
                text,
                style: TextStyle(fontSize: 15, color: textColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
