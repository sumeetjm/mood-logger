import 'package:equatable/equatable.dart';

class Country extends Equatable {
  String name;
  String code;

  Country.fromJsonMap(Map<String, dynamic> map)
      : name = map['name'],
        code = map['code'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = name;
    data['code'] = code;
    return data;
  }

  @override
  List<Object> get props => [code];
}
