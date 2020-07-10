import 'dart:convert';



CalObj calObjFromJson(String str) => CalObj.fromJson(json.decode(str));

String calObjToJson(CalObj data) => json.encode(data.toJson());

class CalObj {
    CalObj({
        this.data,
    });

    List<List<Datum>> data;

    factory CalObj.fromJson(Map<String, dynamic> json) => CalObj(
        data: List<List<Datum>>.from(json["data"].map((x) => List<Datum>.from(x.map((x) => Datum.fromJson(x))))),
    );

    Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => List<dynamic>.from(x.map((x) => x.toJson())))),
    };
}

class Datum {
    Datum({
        this.label,
        this.value,
    });

    String label;
    String value;

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        label: json["label"] == null ? null : json["label"],
        value: json["value"] == null ? null : json["value"],
    );

    Map<String, dynamic> toJson() => {
        "label": label == null ? null : label,
        "value": value == null ? null : value,
    };
}
