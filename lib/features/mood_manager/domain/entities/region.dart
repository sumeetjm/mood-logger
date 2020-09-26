import 'package:equatable/equatable.dart';

class Region extends Equatable {
  String region;
  String country;

  Region.fromJsonMap(Map<String, dynamic> map)
      : region = map['region'],
        country = map['country'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['region'] = region;
    data['country'] = country;
    return data;
  }

  @override
  List<Object> get props => [region, country];
}
