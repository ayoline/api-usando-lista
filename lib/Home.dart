import 'package:api_usando_lista/Post.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _urlBase = 'https://jsonplaceholder.typicode.com';

  Future<List<Post>> _recuperarPostagens(http.Client client) async {
    http.Response response = await client.get(Uri.parse('$_urlBase/posts'));
    return compute(parsePostagens, response.body);
  }

  List<Post> parsePostagens(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

    return parsed.map<Post>((json) => Post.fromJson(json)).toList();
  }

  // Metodo da API utilizado para mostrar um recurso
  _post() async {
    var corpo = json.encode({
      'userId': 120,
      'id': null,
      'title': 'Título',
      'body': 'Corpo da postagem'
    });

    http.Response response = await http.post(Uri.parse('$_urlBase/posts'),
        headers: {'Content-type': 'application/json; charset=UTF-8'},
        body: corpo);

    print('resposta: ${response.statusCode}');
    print('resposta: ${response.body}');
  }

  // Metodo da API utilizado para atualizar um recurso
  _put() async {
    var corpo = json.encode({
      'userId': 120,
      'id': null,
      'title': 'Título alterado',
      'body': 'Corpo da postagem alterada'
    });

    http.Response response = await http.put(Uri.parse('$_urlBase/posts/2'),
        headers: {'Content-type': 'application/json; charset=UTF-8'},
        body: corpo);

    print('resposta: ${response.statusCode}');
    print('resposta: ${response.body}');
  }

  // Metodo da API utilizado para atualizar um recurso
  // funciona como o PUT, com a diferença que pode ser enviado somente o que vai ser alterado e não tudo.
  _patch() async {
    var corpo =
        json.encode({'userId': 120, 'body': 'Corpo da postagem alterada'});

    http.Response response = await http.patch(Uri.parse('$_urlBase/posts/2'),
        headers: {'Content-type': 'application/json; charset=UTF-8'},
        body: corpo);

    print('resposta: ${response.statusCode}');
    print('resposta: ${response.body}');
  }

  // Metodo da API utilizado para deletar um recurso
  _delete() async {
    http.Response response = await http.delete(Uri.parse('$_urlBase/posts/2'));

    print('resposta: ${response.statusCode}');
    print('resposta: ${response.body}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Consumo de serviço avançado"),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                ElevatedButton(
                  child: Text('Salvar'),
                  onPressed: _post,
                ),
                ElevatedButton(
                  child: Text('Atualizar'),
                  onPressed: _patch,
                ),
                ElevatedButton(
                  child: Text('Remover'),
                  onPressed: _delete,
                ),
              ],
            ),

            // serve para ocupar o espaço restante da tela com esse item
            Expanded(
              child: FutureBuilder<List<Post>>(
                future: _recuperarPostagens(http.Client()),
                builder: (context, snapshot) {
                  var retorno;
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return Center(
                        child: (CircularProgressIndicator()),
                      );
                    case ConnectionState.active:
                    case ConnectionState.done:
                      if (snapshot.hasError) {
                        print('erro ao carregar');
                      } else {
                        print('lista carregou!');
                        retorno = ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              List<Post>? lista = snapshot.data;
                              Post post = lista![index];
                              return ListTile(
                                contentPadding: const EdgeInsets.all(8.0),
                                title: Text(post.title),
                                subtitle: Text(post.body),
                              );
                            });
                      }
                      break;
                  }
                  return retorno;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
