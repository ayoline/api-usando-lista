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
  Future<List<Post>> _recuperarPostagens(http.Client client) async {
    http.Response response = await client
        .get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));
    return compute(parsePostagens, response.body);
  }

  List<Post> parsePostagens(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

    return parsed.map<Post>((json) => Post.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Consumo de serviço avançado"),
      ),
      body: FutureBuilder<List<Post>>(
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
    );
  }
}
