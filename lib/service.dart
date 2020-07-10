import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

import 'package:pidaeCalificacion/CalObj.dart';

class MyService {
  Map<dynamic, dynamic> calificaciones;
  dynamic getVal(arr, idx) {
    print("Arrlen:${arr.length}:$idx");
    if (arr.length == 0 || arr.length < idx || idx < 0) {
      return null;
    }
    print("ArrVal:${arr[idx]}");
    return arr[idx].value;
  }

  parseCalificaciones(String cal) {
    // var res = json.decode(cal);
    print("Parsing CALS:$cal");
    CalObj res = calObjFromJson(cal);
    var obj = {};
    print(res);

    res.data[0].asMap().forEach((i, materia) {
      obj[materia.label] = {
        "ordinario": getVal(res.data[5], i),
        "extraOrdinario": getVal(res.data[4], i),
        "final": getVal(res.data[3], i),
        "promedio": getVal(res.data[2], i),
        "infoOrdinario": getVal(res.data[1], i)
      };
      obj[materia.label]['calif'] = obj[materia.label]['infoOrdinario'] != null
          ? obj[materia.label]['infoOrdinario']
          : obj[materia.label]['extraOrdinario'];
      obj[materia.label]['tipo'] = obj[materia.label]['infoOrdinario'] != null
          ? 'Ordinario'
          : obj[materia.label]['extraOrdinario'] != null
              ? 'Extraordinario'
              : 'No info';
    });
    //  print(obj);
    calificaciones = obj;
  }

getCalificaciones(){
  return this.calificaciones;
}


  Map<String, String> headers = {
    "content-type": "application/x-www-form-urlencoded",
    "dnt": "1",
    "Origin": "https://www.pidae.ipn.mx",
    "User-Agent":
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.88 Safari/537.36",
    "Sec-Fetch-User": "?1",
    "Sec-Fetch-Site": "same-origin",
    "Sec-Fetch-Mode": "navigate",
    "Referer": "https://www.pidae.ipn.mx/index.cfm"
  };

  Map<String, String> cookies = {};

  final storage = new FlutterSecureStorage();

  Future<List<Object>> iniciarSesion(String user, String password, bool save) async {
    if(user == '' || password == '' || user == null || password == null){
      return [false, "Ingrese los datos de sesión"];
    }

    print("inicialdno sesión:$user:$password:$save");
    if (save) {
      await storage.write(key: 'user', value: user);
      await storage.write(key: 'pass', value: password);
    }
    return await startSession(user, password);
  }

  Future<List<Object>> startSession(u, p) async {
    var url = 'https://www.pidae.ipn.mx/';
    var response = await http.get(url);

   
    //print('Response body: ${response.body}');
    updateCookie(response);

    print("==== LOGIN ====");
    final uri = 'https://www.pidae.ipn.mx/public/login/autenticacion';
    // final uri = "https://postman-echo.com/post";

    var map = new Map<String, dynamic>();
    map['Usuario'] = u;
    map['Password'] = p;
    http.Response response2 = await http.post(uri, body: map, headers: headers);
    updateCookie(response2);
    // print('Response2 status: ${response2.statusCode}');
    // print('Response2 headers: ${response2.headers}');
    print('Response2 body: ${response2.body}');
    print('LOGIN Response headers: ${response2.headers}');
    print('LOGIN Response status: ${response2.statusCode}');

   
    print("LoginCookies:${response2.headers['set-cookie']}");

    var ck = response2.headers['set-cookie'];
    if(ck.indexOf("LOGIN.MESSAGE") != -1){
      String msg = Uri.decodeFull(ck);
      // ; 
      // print(msg);
      return [false, msg.substring(14,msg.indexOf(";"))];
    }


    if(response2.statusCode != 301){
      print("Sesion incorrecta");
      await storage.write(key: 'session', value: null);
      return [false, "Error al iniciar sesión"];
    } 

    await storage.write(key: 'session', value: 'OK');
    // create();
    return [true, "Sesión correcta"];
  }

  create() async {
    var url = 'https://www.pidae.ipn.mx/';
    var response = await http.get(url);

    print('Response headers: ${response.headers}');
    print('Response status: ${response.statusCode}');
    //print('Response body: ${response.body}');
    updateCookie(response);

    print("==== LOGIN ====");
    final uri = 'https://www.pidae.ipn.mx/public/login/autenticacion';
    // final uri = "https://postman-echo.com/post";

    var map = new Map<String, dynamic>();

    map['Usuario'] = await storage.read(key: 'user');
    map['Password'] =  await storage.read(key: 'pass');

    http.Response response2 = await http.post(uri, body: map, headers: headers);
    updateCookie(response2);
    print('Response2 status: ${response2.statusCode}');
    print('Response2 headers: ${response2.headers}');
    print('Response2 body: ${response2.body}');

    print("==== GET CALIFICACIONES ====");
    final uri2 =
        "https://www.pidae.ipn.mx/alumnos/acceso/principal/principalAl/obtenerDatosGrafica";
    print('consulta calificacion-..');
    var map2 = new Map<String, dynamic>();
    map2['p1'] = '';
    map2['p2'] = '';

    http.Response response3 =
        await http.post(uri2, body: map2, headers: headers);
    print('Response3 status: ${response3.statusCode}');
    print('Response3 body: ${response3.body}');

    parseCalificaciones(response3.body);

    print("==== CERRANDO SESIÓN ====");

    url = "https://www.pidae.ipn.mx/public/login/terminarSesion";
    response = await http.get(url);

    print('Response headers: ${response.headers}');
    print('Response status: ${response.statusCode}');
    //print('Response body: ${response.body}');
    updateCookie(response);
  }

  void _setCookie(String rawCookie) {
    if (rawCookie.length > 0) {
      var keyValue = rawCookie.split('=');
      if (keyValue.length == 2) {
        var key = keyValue[0].trim();
        var value = keyValue[1];

        // ignore keys that aren't cookies
        if (key == 'path' || key == 'expires') return;

        this.cookies[key] = value;
      }
    }
  }

  String _generateCookieHeader() {
    String cookie = "";

    for (var key in cookies.keys) {
      if (cookie.length > 0) cookie += ";";
      cookie += key + "=" + cookies[key];
    }

    return cookie;
  }

  void updateCookie(http.Response response) {
    String allSetCookie = response.headers['set-cookie'];

    if (allSetCookie != null) {
      var setCookies = allSetCookie.split(',');

      for (var setCookie in setCookies) {
        var cookies = setCookie.split(';');
        String c = cookies[0];

        // for (var cookie in cookies) {
        _setCookie(c);
        // }
      }

      headers['cookie'] = _generateCookieHeader();
      print("COOKIE:" + headers['cookie']);
    }
  }
}
