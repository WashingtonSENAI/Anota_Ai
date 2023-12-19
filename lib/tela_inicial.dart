import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'bloco_notas.dart';
import 'gerenciador.dart';

class Record {
  final String titulo;
  final bool checked;
  final DocumentReference reference;

  Record({
    required this.titulo,
    required this.checked,
    required this.reference,
  });

  factory Record.fromMap(Map<String, dynamic>? map,
      {required DocumentReference reference}) {
    return Record(
      titulo: map?['Titulo'] as String? ?? '',
      checked: map?['Checked'] as bool? ?? false,
      reference: reference,
    );
  }

  @override
  String toString() => "Record<$titulo:$checked>";
}

class NavDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.50,
      child: Drawer(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        width: 250,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const SizedBox(
              height: 100, // To change the height of DrawerHeader
              width: double.infinity, // To Change the width of DrawerHeader
              child: DrawerHeader(
                decoration: BoxDecoration(color: Color(0xffffffff)),
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Color(0xff000000),
                    fontSize: 40,
                  ),
                ),
              ),
            ),
            ListTile(
              title: const Text('Bloco de Notas'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BlocoNotas()),
                );
              },
            ),
            ListTile(
              title: const Text('Gerenciador de Tarefas'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Gerenciador()),
                );
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(title: Text('AnotaAi')),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('AnotaAi')
          .doc('CARKrWpi3vRzvyV2hGSM')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();
        var data = snapshot.data!.data();
        if (data == null) return Container();
        return _buildListItem(context, data);
      },
    );
  }

  Widget _buildListItem(BuildContext context, Map<String, dynamic> data) {
    final record = Record.fromMap(data,
        reference: FirebaseFirestore.instance // Specify the reference argument
            .collection('AnotaAi')
            .doc('CARKrWpi3vRzvyV2hGSM'));
    return Padding(
      key: ValueKey(record.titulo),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
          title: Text(record.titulo),
          trailing: Checkbox(
            value: record.checked,
            onChanged: (value) {
              record.reference.update({'checked': value});
            },
          ),
        ),
      ),
    );
  }
}
