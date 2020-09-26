import 'package:dio/dio.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/city.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/country.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/region.dart';

class RestCountries {
  static RestCountries instance;
  String key;
  Dio client;
  RestCountries({this.key})
      : assert(key != null && key != ''),
        client = Dio(BaseOptions(
            queryParameters: {'key': key},
            baseUrl: 'http://battuta.medunes.net/api'));
  static RestCountries setup(String key) {
    instance = RestCountries(key: key);
    return instance;
  }

  Future<int> checkQuota() async {
    var response = await client.get('quota');
    return response.data['remaining quota'];
  }

  Future<List<dynamic>> _get(String path,
      {Map<String, String> parameters}) async {
    var response = await client.get(path, queryParameters: parameters);
    return response.data as List<dynamic>;
  }

  Future<List<Country>> getCountries() async {
    return (await _get('/country/all'))
        .map((data) => Country.fromJsonMap(data))
        .toList();
  }

  Future<List<Country>> searchCountry(
      {String keyword = '', String city = '', String region = ''}) async {
    Map<String, String> params = {};
    if (keyword.isNotEmpty) {
      params['country'] = keyword;
    }
    if (region.isNotEmpty) {
      params['region'] = region;
    }
    if (city.isNotEmpty) {
      params['city'] = city;
    }
    return (await _get('/country/search', parameters: params))
        .map((data) => Country.fromJsonMap(data))
        .toList();
  }

  Future<List<City>> getCities(
      {String country = '', String region = '', String keyword = ''}) async {
    Map<String, String> params = {};
    if (keyword.isNotEmpty) {
      params['city'] = keyword;
    }
    if (region.isNotEmpty) {
      params['region'] = region;
    }
    return (await _get('/city/$country/search', parameters: params))
        .map((data) => City.fromJsonMap(data))
        .toList();
  }

  Future<List<Region>> getRegions({String countryCode = ''}) async {
    return (await _get('/region/$countryCode/all'))
        .map((data) => Region.fromJsonMap(data))
        .toList();
  }

  Future<List<Region>> searchRegion(
      {String keyword = '', String city = '', String countryCode = ''}) async {
    Map<String, String> params = {};
    if (keyword.isNotEmpty) {
      params['region'] = keyword;
    }
    if (city.isNotEmpty) {
      params['city'] = city;
    }
    return (await _get('/region/$countryCode/search', parameters: params))
        .map((data) => Region.fromJsonMap(data))
        .toList();
  }
}
