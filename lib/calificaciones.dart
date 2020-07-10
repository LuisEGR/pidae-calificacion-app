import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pidaeCalificacion/CalObj.dart';
import 'package:pidaeCalificacion/main.dart';
import 'package:pidaeCalificacion/service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Calificaciones extends StatefulWidget {
  // Calificaciones() : super(key: key);
  Map<dynamic, dynamic> calificaciones;

  Calificaciones({Map<dynamic, dynamic> cal}) : this.calificaciones = cal;

  @override
  _CalificacionesState createState() => _CalificacionesState(calificaciones);
}

class _CalificacionesState extends State<Calificaciones> {
  _CalificacionesState(this.calificaciones);
  final Map<dynamic, dynamic> calificaciones;


  int _counter = 0;
  Map<dynamic, dynamic> califs = null;
  String textBg = "";

  dynamic _refreshCals() async {}

  bool isJSON(str) {
    try {
      jsonDecode(str);
    } catch (e) {
      return false;
    }
    return true;
  }

  void _incrementCounter() async {
    setState(() {
      califs = null;
      textBg = "Cargando...";
    });

    var svc = MyService();
    await svc.create();

    setState(() {
      califs = svc.getCalificaciones();
      textBg = "";
    });
  }

  // void initState() {
  //   super.initState();
  //   SchedulerBinding.instance.addPersistentFrameCallback((timeStamp) {
  //     _refreshCals();
  //   });
  // }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Salir'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Estás seguro?'),
                Text('Esto borrará tu sesión almacenada.'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Salir'),
              onPressed: () {
                final storage = new FlutterSecureStorage();
                storage.deleteAll();
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => MyApp()));
                // Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print("CALIG");
    print(this.calificaciones);
    return Scaffold(
        // appBar: AppBar(
        //   // Here we take the value from the Calificaciones object that was created by
        //   // the App.build method, and use it to set our appbar title.
        //   title: Text(widget.title),
        // ),
        body: SafeArea(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Stack(
            children: <Widget>[
              Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    textBg,
                    style: TextStyle(
                        color: Colors.black26,
                        fontSize: 30,
                        fontWeight: FontWeight.w200),
                  )
                ],
              )),
              Padding(
                  padding: EdgeInsets.all(10),
                  child: GridView.count(
                      crossAxisCount: 2,
                      padding: EdgeInsets.all(10),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      // childAspectRatio: 1.7,
                      children: _getCalifWidgets(califs: calificaciones)
                      // <Widget>[
                      // MateriaCal(
                      //     color: Color(0xFF71ca9d), materia: "TRABAJO TERMINAL II"),
                      // MateriaCal(
                      //     color: Color(0xFFe57373),
                      //     materia: "Teoria de comunicaciones y señales II"),
                      // MateriaCal(color: Color(0xFFf8ae59)),
                      // MateriaCal(color: Color(0xFFf87758)),
                      // MateriaCal(color: Color(0xFFf8ae59)),
                      // MateriaCal(color: Color(0xFFf87758)),
                      // MateriaCal(color: Color(0xFFf8ae59)),
                      // MateriaCal(color: Color(0xFFf87758)),
                      // MateriaCal(color: Color(0xFFf8ae59)),
                      // MateriaCal(color: Color(0xFFf87758)),

                      // ],
                      )),
            ],
          ),
        ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 31),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: FloatingActionButton(
                  heroTag: null,
                  backgroundColor: Color(0xFF702F46),
                  onPressed: _showMyDialog,
                  tooltip: 'Exit',
                  child: Icon(Icons.exit_to_app),
                ),
              ),
            ),
            // FloatingActionButton(
            //   backgroundColor: Color(0xFF702F46),
            //   onPressed: _incrementCounter,
            //   tooltip: 'Refresh',
            //   child: Icon(Icons.replay),
            // ),

            Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                heroTag: null,
                backgroundColor: Color(0xFF702F46),
                onPressed: _incrementCounter,
                tooltip: 'Refresh',
                child: Icon(Icons.replay),
              ),
            )
          ],
        ) // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}

Color getColorCalif(num) {
  if (num == null) {
    return Color(0xFF61a6f1);
  }
  var n = int.parse(num);
  if (n >= 8) {
    return Color(0xFF71ca9d);
  }
  if (n >= 6) {
    return Color(0xFFf8ae59);
  }
  return Color(0xFFe57373);
}

List<Widget> _getCalifWidgets({Map<dynamic, dynamic> califs}) {
  print("Generando widgets...");
  print(califs);
  List<Widget> califWidgets = new List<Widget>();
  // califWidgets.add(MateriaCal(color: Color(0xFFf87758)));
  if (califs == null) return califWidgets;
  califs.forEach((key, value) {
    califWidgets.add(
      MateriaCal(
        color: getColorCalif(value['calif']),
        materia: key,
        cal: value['calif'],
        tipoCal: value['tipo'],
      ),
    );
    print("New Widget $key");
  });

  return califWidgets;
}

class MateriaCal extends StatelessWidget {
  Color colorBg;
  String materia = "OsK";
  String tipoCal = "";
  String cal = "";
  MateriaCal({Color color, String materia, String cal, String tipoCal}) {
    colorBg = color;
    print("MRWEI$materia");
    this.materia = materia != null ? materia : '';
    this.tipoCal = tipoCal != null ? tipoCal : '';
    this.cal = cal != null ? cal : '-';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 2,
      height: MediaQuery.of(context).size.width / 2,
      decoration: BoxDecoration(
        color: colorBg,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(5),
          topLeft: Radius.circular(5),
        ),
        boxShadow: [
          BoxShadow(
            color: colorBg.withAlpha(90),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      padding: EdgeInsets.all(15.0),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Text(
            materia,
            style: TextStyle(
              color: Colors.white70,
            ),
          ),
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  cal,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 40),
                ),
              ]),
          Positioned(
              bottom: 0,
              right: 0,
              // width: MediaQuery.of(context).size.width,
              child: Text(
                tipoCal,
                style: TextStyle(color: Colors.white54),
              ))
        ],
      ),
    );
  }
}
