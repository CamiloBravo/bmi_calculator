import 'package:flutter/material.dart';

import '../data/session.dart';
import '../data/sp_helper.dart';

class SessionsScreen extends StatefulWidget {
  SessionsScreen({Key? key}) : super(key: key);

  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> {
  final TextEditingController txtDescription = TextEditingController();
  final TextEditingController txtDuration = TextEditingController();
  final SPHelper helper = SPHelper();
  List<Session> sessions = [];
  @override
  void initState() {
    helper.init().then((value) {
      updateScreen();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Training Sessions'),
      ), // AppBar
      body: ListView(children: getContent()),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            showSessionDialog(context);
          }), // FloatingActionButton
    ); // Scaffold
  }

  Future<dynamic> showSessionDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Insert Training Session'),
            content: SingleChildScrollView(
                child: Column(children: [
              TextField(
                controller: txtDescription,
                decoration: const InputDecoration(hintText: 'Description'),
              ), // TextField
              TextField(
                controller: txtDuration,
                decoration: const InputDecoration(hintText: 'Duration'),
              ), // TextField
            ])),
            actions: [
              TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context);
                    txtDescription.text = '';
                    txtDuration.text = '';
                  }), // TextButton
              ElevatedButton(
                child: const Text('Save'),
                onPressed: saveSession,
              ), // ElevatedButton
            ],
          ); // Column // SingleChildScrollView // AlertDialog
        });
  }

  Future saveSession() async {
    DateTime now = DateTime.now();
    String today = '${now.year} -${now.month} -${now.day}';
    int id = helper.getCounter() + 1;

    Session newSession = Session(
        id, today, txtDescription.text, int.tryParse(txtDuration.text) ?? 0);
    helper.writeSession(newSession).then((_) {
      updateScreen();
      helper.setCounter();
    });
    txtDescription.text = '';
    txtDuration.text = '';
    Navigator.pop(context);
  }

  List<Widget> getContent() {
    List<Widget> tiles = [];
    sessions.forEach((session) {
      tiles.add(Dismissible(
        key: UniqueKey(),
        onDismissed: (_) {
          helper.deleteSession(session.id).then((value) => updateScreen());
        },
        child: ListTile(
          title: Text(session.description),
          subtitle: Text('${session.date} - duration: ${session.duration} min'),
        ),
      )); // ListTile
    });
    return tiles;
  }

  void updateScreen() {
    sessions = helper.getSessions();
    setState(() {});
  }
}
