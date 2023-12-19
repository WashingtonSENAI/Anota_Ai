import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'bloco_notas.dart';

class Gerenciador extends StatefulWidget {
  const Gerenciador({Key? key}) : super(key: key);

  @override
  _GerenciadorState createState() => _GerenciadorState();
}

class _GerenciadorState extends State<Gerenciador> {
  List<Record> documentos = [];

  @override
  void initState() {
    super.initState();

    // Chama o método para listar os documentos da coleção "AnotaAi"
    _listarDocumentos();
  }

  Future<void> _listarDocumentos() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('AnotaAi')
        .get(); // Obtém os documentos da coleção "AnotaAi"

    setState(() {
      documentos = snapshot.docs.map((doc) {
        final record = Record.fromMap(doc.data() as Map<String, dynamic>,
            reference: doc.reference);
        return record;
      }).toList();
    });
  }

  Future<void> _adicionarDocumento(String titulo) async {
    final DocumentReference documentReference =
        await FirebaseFirestore.instance.collection('AnotaAi').add({
      'titulo': titulo,
      'checked': false,
    });

    final Record novoDocumento =
        Record(titulo: titulo, checked: false, reference: documentReference);

    setState(() {
      documentos.add(novoDocumento);
    });
  }

  Future<void> _editarDocumento(Record documento) async {
    String novoTitulo = documento.titulo;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar Documento'),
          content: TextField(
            onChanged: (value) {
              novoTitulo = value;
            },
            decoration: InputDecoration(
              labelText: 'Novo Título',
            ),
            controller: TextEditingController(text: documento.titulo),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                documento.titulo = novoTitulo;
                await _atualizarDocumento(documento);
                Navigator.of(context).pop();
                await _listarDocumentos(); // Atualiza a lista após a edição
              },
              child: Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _excluirDocumento(Record documento) async {
    await documento.reference.delete(); // Exclui o documento do banco de dados
    setState(() {
      documentos.remove(documento);
    });
  }

  Future<void> _atualizarDocumento(Record documento) async {
    await documento.reference.update({'checked': documento.checked});
    await documento.reference.update({'titulo': documento.titulo});
    await _listarDocumentos(); // Atualiza a lista após a edição
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        width: 250,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            SizedBox(
              height: 100,
              width: double.infinity,
              child: DrawerHeader(
                decoration: BoxDecoration(color: Color(0xfffdfdfd)),
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
      appBar: AppBar(
        title: Text('Gerenciador'),
      ),
      body: ListView.builder(
        itemCount: documentos.length,
        itemBuilder: (context, index) {
          final documento = documentos[index];

          return ListTile(
            title: GestureDetector(
              onTap: () => _editarDocumento(documento),
              child: Text(
                documento.titulo,
                style: TextStyle(
                  color: Colors.white,
                  decoration: documento.checked
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  decorationStyle: TextDecorationStyle.solid,
                ),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: documento.checked,
                  onChanged: (newValue) {
                    setState(() {
                      documento.checked = newValue ?? false;
                    });
                    _atualizarDocumento(documento);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _excluirDocumento(documento),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              String novoTitulo = '';

              return AlertDialog(
                title: Text('Nova Tarefa'),
                content: TextField(
                  onChanged: (value) {
                    novoTitulo = value;
                  },
                  decoration: InputDecoration(
                    labelText: 'Título',
                    fillColor: Color.fromRGBO(25, 88, 123, 1),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _adicionarDocumento(novoTitulo);
                      Navigator.of(context).pop();
                    },
                    child: Text('Adicionar'),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class Record {
  String titulo;
  bool checked;
  final DocumentReference reference;

  Record({
    required this.titulo,
    required this.checked,
    required this.reference,
  });

  factory Record.fromMap(Map<String, dynamic>? map,
      {required DocumentReference reference}) {
    return Record(
      titulo: map?['titulo'] as String? ?? '',
      checked: map?['checked'] as bool? ?? false,
      reference: reference,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'checked': checked,
    };
  }

  @override
  String toString() => "Record<$titulo:$checked>";
}
