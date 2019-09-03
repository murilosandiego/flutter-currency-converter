import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = 'https://api.hgbrasil.com/finance?key=f0d70006';

void main() async {
  runApp(MaterialApp(home: Home()));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();
  final bitcoinController = TextEditingController();

  double dolar;
  double euro;
  double bitcoin;

  void _handleRealChanged(String text) {
    if (_textIsEmpty(text)) return;
    double real = double.parse(text);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
    bitcoinController.text = (real / bitcoin).toStringAsFixed(2);
  }

  void _handleDolarChanged(String text) {
    if (_textIsEmpty(text)) return;
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
    bitcoinController.text = (dolar * this.dolar / bitcoin).toStringAsFixed(2);
  }

  void _handleEuroChanged(String text) {
    if (_textIsEmpty(text)) return;
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
    bitcoinController.text = (euro * this.euro / bitcoin).toStringAsFixed(2);
  }

  void _handleBitcoinChanged(String text) {
    if (_textIsEmpty(text)) return;
    double bitcoin = double.parse(text);
    realController.text = (bitcoin * this.bitcoin).toStringAsFixed(2);
    dolarController.text = (bitcoin * this.bitcoin / dolar).toStringAsFixed(2);
    euroController.text = (bitcoin * this.bitcoin / euro).toStringAsFixed(2);
  }

  bool _textIsEmpty(String text) {
    if (text.isEmpty) {
      _handleClearAll();
      return true;
    }
    return false;
  }

  void _handleClearAll() {
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(147, 31, 197, 0),
      appBar: AppBar(
        title: Text(
          'Conversor ₿\$€',
          style: TextStyle(color: Colors.amber),
        ),
        backgroundColor: Color.fromRGBO(147, 31, 197, 0),
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text(
                  'Carregando dados...',
                  style: TextStyle(color: Colors.amber, fontSize: 20.0),
                  textAlign: TextAlign.center,
                ),
              );
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Erro ao carregar dados :(',
                    style: TextStyle(color: Colors.amber, fontSize: 20.0),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                dolar = snapshot.data['results']['currencies']['USD']['buy'];
                euro = snapshot.data['results']['currencies']['EUR']['buy'];
                bitcoin = snapshot.data['results']['currencies']['BTC']['buy'];

                return SingleChildScrollView(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(Icons.monetization_on,
                          size: 150, color: Colors.amber),
                      Divider(),
                      _buildTextField('Bitcoin', '₿ ', bitcoinController,
                          _handleBitcoinChanged),
                      Divider(),
                      _buildTextField(
                          'Real', 'R\$ ', realController, _handleRealChanged),
                      Divider(),
                      _buildTextField('Dolar', 'US\$ ', dolarController,
                          _handleDolarChanged),
                      Divider(),
                      _buildTextField(
                          'Euro', '€ ', euroController, _handleEuroChanged),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Widget _buildTextField(
    String label, String prefix, TextEditingController controller, Function f) {
  return TextField(
    keyboardType: TextInputType.numberWithOptions(decimal: true),
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.amber),
      border: OutlineInputBorder(),
      prefixText: prefix,
      prefixStyle: TextStyle(color: Colors.amber, fontSize: 20.0),
      enabledBorder:
          OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
      focusedBorder:
          OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
    ),
    style: TextStyle(color: Colors.amber, fontSize: 20.0),
    onChanged: f,
  );
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}
