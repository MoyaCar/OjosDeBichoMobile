import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path/path.dart';
import 'package:async/async.dart';

String textoVacio = '';
String textoSeleccion = 'Carga una foto con Ojos de Insecto';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PantallaInicial(),
    );
  }
}

class PantallaInicial extends StatefulWidget {
  PantallaInicial({Key key}) : super(key: key);

  _PantallaInicialState createState() => _PantallaInicialState();
}

class _PantallaInicialState extends State<PantallaInicial> {
  File img;

  upload(File imageFile) async {
    var stream =
        new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    var length = await imageFile.length();

    String base = 'https://bugseyes.onrender.com/';
    var uri = Uri.parse(base + 'analyze');
    var request = http.MultipartRequest('POST', uri);
    var multiPartFile = http.MultipartFile('file', stream, length,
        filename: basename(imageFile.path));
    request.files.add(multiPartFile);
    var response = await request.send();
    print(response.statusCode);
    response.stream.transform(utf8.decoder).listen((value) {
      print(value);
      int l = value.length;
      textoVacio = value;
      setState(() {});
    });
  }

  imagePicker(int a) async {
    textoSeleccion = '';
    setState(() {});
    print('imagePicker activado');
    img = await ImagePicker.pickImage(
        source: a == 0 ? ImageSource.camera : ImageSource.gallery);

    textoVacio = 'Analizando...';
    print(img.toString());
    upload(img);
    setState(() {});
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        title: new Text('Ojos de Bichos'),
      ),
      body: new Container(
        child: Center(
          child: Column(
            children: <Widget>[
              img == null
                  ? new Text(
                      textoSeleccion,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 32.0,
                      ),
                    )
                  : new Image.file(img,
                      height: MediaQuery.of(context).size.height * 0.6,
                      width: MediaQuery.of(context).size.width * 0.8),
              new Text(
                textoVacio,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 32.0,
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: new Stack(
        children: <Widget>[
          Align(
              alignment: Alignment(1.0, 1.0),
              child: new FloatingActionButton(
                onPressed: () {
                  imagePicker(0);
                },
                child: new Icon(Icons.camera_alt),
              )),
          Align(
              alignment: Alignment(1.0, 0.8),
              child: new FloatingActionButton(
                  onPressed: () {
                    imagePicker(1);
                  },
                  child: new Icon(Icons.image))),
        ],
      ),
    );
  }
}
