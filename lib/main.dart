import 'package:flutter/material.dart';
import 'package:pidaeCalificacion/calificaciones.dart';
import 'package:pidaeCalificacion/service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo 1',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Pages'),
      // home: Calificaciones()
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController userCtrl = new TextEditingController();
  TextEditingController paswCtrl = new TextEditingController();
  String _textStatusSesion = "";
  MyService svc = MyService();
  int _counter = 0;
  bool checkedValue = true;
  void _incrementCounter() {
    setState(() {
      _counter++;
      // var svc = MyService();
      // svc.create();
    });
  }

  void continuar() async {
    print("Continuando...${userCtrl.text}:${paswCtrl.text}:${checkedValue}");
    List<Object> sesion = await svc.iniciarSesion(userCtrl.text, paswCtrl.text, checkedValue);
    if(sesion[0]){
      validarSesion();
    } else {
      setState(() {
        _textStatusSesion = sesion[1];
      });
    }
  }

  void validarSesion() async {
    final storage = new FlutterSecureStorage();
    String user = await storage.read(key: "user");
    String pass = await storage.read(key: "pass");
    String sess = await storage.read(key: 'session');
    print("USER:$user");
    print("PASS:$pass");
    print("SESS:$sess");
    if (sess == "OK") {
      // Navigator.replace(context, oldRoute: null, newRoute: null)
      await svc.create();
      var c = await svc.getCalificaciones();
      try {

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Calificaciones(cal: c)));
      }catch(e){
        print("E");
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Building...");

    validarSesion();

    return Scaffold(
      backgroundColor: Color(0xFF702F46),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          print("TAP");
          // FocusScope.of(context).unfocus();
          FocusScope.of(context).requestFocus(new FocusNode());

          // FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'PIDAE',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 50,
                    fontWeight: FontWeight.w900),
              ),
              Text(
                'Calificaciones',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                ),
              ),
              Container(
                height: 40,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromARGB(50, 0, 0, 0),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 6), // changes position of shadow
                    ),
                  ],
                  borderRadius: BorderRadius.all(Radius.circular(7)),
                ),
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: userCtrl,
                      decoration: InputDecoration(
                          border: InputBorder.none, hintText: 'Usuario'),
                    ),
                    TextField(
                      obscureText: true,
                      controller: paswCtrl,
                      decoration: InputDecoration(
                          border: InputBorder.none, hintText: 'Contraseña'),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(15.0),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.50,
                // decoration: BoxDecoration(color: Colors.red),
                padding: EdgeInsets.fromLTRB(0, 0, 0, 20.0),
                child: Column(
                  children: <Widget>[
                    Switch(
                      activeColor: Color(0xFF9e396c),
                      activeTrackColor: Color(0xFF5d213f),
                      value: checkedValue,
                      onChanged: (value) => {
                        // print("val:${value}")
                        setState(() => {checkedValue = value})
                      },
                    ),
                    Text("Recordar sesión"),
                  ],
                ),
              ),
              MaterialButton(
                elevation: 5.0,
                minWidth: 200.0,
                height: 35,
                color: Color(0xFF0F1108),
                onPressed: () => {
                  continuar()
                  // setState(() => {checkedValue = value})
                },
                child: Text(
                  "Ingresar",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Text(_textStatusSesion, textAlign: TextAlign.center,)

            ],
          ),
        ),
      ),
    );
  }
}
