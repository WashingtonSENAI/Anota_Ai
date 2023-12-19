import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'gerenciador.dart';

class BlocoNotas extends StatefulWidget {
  const BlocoNotas({Key? key}) : super(key: key);

  @override
  State<BlocoNotas> createState() => _BlocoNotasState();
}

class _BlocoNotasState extends State<BlocoNotas> {
  List<Record> documentos = [];

  @override
  void initState() {
    super.initState();
    _listarDocumentos();
  }

  Future<void> _excluirDocumento(Record documento) async {
    await documento.reference.delete();
    setState(() {
      documentos.remove(documento);
    });
  }

  void _atualizarDocumento(Record documentoAtualizado) {
    setState(() {
      final index = documentos.indexWhere(
          (doc) => doc.reference.id == documentoAtualizado.reference.id);
      if (index != -1) {
        documentos[index] = documentoAtualizado;
      }
    });
  }

  Future<void> _listarDocumentos() async {
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('AnotaAi_2').get();

    setState(() {
      documentos = snapshot.docs.map((doc) {
        final record = Record.fromMap(doc.data() as Map<String, dynamic>,
            reference: doc.reference);
        return record;
      }).toList();
    });
  }

  Future<void> _adicionarDocumento(String titulo, String informacoes) async {
    final collectionRef = FirebaseFirestore.instance.collection('AnotaAi_2');
    final doc = await collectionRef.add({
      'titulo': titulo,
      'informacoes': informacoes,
    });

    setState(() {
      documentos.add(
          Record(titulo: titulo, informacoes: informacoes, reference: doc));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bloco de Notas'),
      ),
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
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
        ),
        itemCount: documentos.length,
        itemBuilder: (_, index) {
          final doc = documentos[index];
          return Stack(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetalhesDocumento(documento: doc),
                    ),
                  );
                },
                child: Card(
                  elevation: 4,
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    width: double
                        .infinity, // Define largura igual para todos os elementos
                    height: double
                        .infinity, // Define altura igual para todos os elementos
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doc.titulo,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines:
                              1, // Define o máximo de linhas para o título
                          overflow: TextOverflow
                              .ellipsis, // Adiciona "..." se for muitogrande
                        ),
                        SizedBox(height: 16),
                        Text(
                          doc.informacoes,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: -5,
                right: 1,
                child: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => _excluirDocumento(doc),
                ),
              ),
              Positioned(
                top: -5,
                right: 140,
                child: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EditarDocumento(
                                  documento: doc,
                                  onDocumentoAtualizado: (documentoAtualizado) {
                                    _atualizarDocumento(documentoAtualizado);
                                  },
                                )));
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              String novoTitulo = '';
              String novoConteudo1 = '';

              return AlertDialog(
                title: Text('Novo Bloco de Notas'),
                content: Column(
                  children: [
                    TextField(
                      onChanged: (value) {
                        novoTitulo = value;
                      },
                      decoration: InputDecoration(
                        labelText: 'Título',
                      ),
                    ),
                    TextField(
                      onChanged: (value) {
                        novoConteudo1 = value;
                      },
                      maxLines: null, // Permite várias linhas de texto
                      keyboardType: TextInputType
                          .multiline, // Define o teclado para aceitar várias linhas de texto
                      textInputAction: TextInputAction
                          .newline, // Altera o botão "Concluído" para uma quebra de linha
                      decoration: InputDecoration(
                        labelText: 'Conteúdo',
                      ),
                    ),
                  ],
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
                      _adicionarDocumento(novoTitulo, novoConteudo1);
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

class EditarDocumento extends StatefulWidget {
  final Record documento;
  final Function(Record) onDocumentoAtualizado;

  const EditarDocumento(
      {Key? key, required this.documento, required this.onDocumentoAtualizado})
      : super(key: key);

  @override
  _EditarDocumentoState createState() => _EditarDocumentoState();
}

class _EditarDocumentoState extends State<EditarDocumento> {
  late TextEditingController _tituloController;
  late TextEditingController _informacoesController;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.documento.titulo);
    _informacoesController =
        TextEditingController(text: widget.documento.informacoes);
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _informacoesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Documento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _tituloController,
              decoration: InputDecoration(
                labelText: 'Título',
                labelStyle: TextStyle(
                    color: Colors.white), // Define a cor do texto do rótulo
                hintStyle: TextStyle(
                    color: Colors.white), // Define a cor do texto de dica
                // Define a cor do texto de dica
              ),
            ),
            SizedBox(height: 16),
            TextField(
              maxLines: null, // Permite várias linhas de texto
              keyboardType: TextInputType
                  .multiline, // Define o teclado para aceitar várias linhas de texto
              controller: _informacoesController,
              decoration: InputDecoration(
                labelText: 'Informações',
                hintStyle: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _atualizarDocumento();
                Navigator.pop(context);
              },
              child: Text('Atualizar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _atualizarDocumento() async {
    widget.documento.titulo = _tituloController.text;
    widget.documento.informacoes = _informacoesController.text;

    await FirebaseFirestore.instance
        .collection('AnotaAi_2')
        .doc(widget.documento.reference.id)
        .update(widget.documento.toMap());

    widget.onDocumentoAtualizado(widget.documento);
  }
}

class DetalhesDocumento extends StatelessWidget {
  final Record documento;

  const DetalhesDocumento({Key? key, required this.documento})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(documento.titulo),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              documento.titulo,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              documento.informacoes,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class Record {
  String titulo;
  String informacoes;
  final DocumentReference reference;

  Record({
    required this.titulo,
    required this.informacoes,
    required this.reference,
  });

  factory Record.fromMap(Map<String, dynamic>? map,
      {required DocumentReference reference}) {
    return Record(
      titulo: map?['titulo'] as String? ?? '',
      informacoes: map?['informacoes'] as String? ?? '',
      reference: reference,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'informacoes': informacoes,
    };
  }

  @override
  String toString() => "Record<$titulo:$informacoes>";
}
