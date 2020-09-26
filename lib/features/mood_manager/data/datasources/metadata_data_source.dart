import 'dart:developer';

import 'package:mood_manager/core/error/exceptions.dart';
import 'package:mood_manager/features/mood_manager/data/datasources/rest_countries.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/city.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/country.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/region.dart';

abstract class MetadataRemoteDataSource {
  Future<List<City>> getCitiesByCountryAndRegion(
      {Country country, Region region});
  Future<List<Country>> getCountries();
  Future<List<Region>> getRegionByCountry({Country country});
  Future<Region> getRegionByRegion({Region region, Country country});
  Future<Country> getCountryByCountry({Country country});
  Future<City> getCityByCity({City city, Country country});
}

class MetadataRemoteDataSourceImpl implements MetadataRemoteDataSource {
  final RestCountries restCountries;
  MetadataRemoteDataSourceImpl({this.restCountries});

  @override
  Future<List<City>> getCitiesByCountryAndRegion(
      {Country country, Region region}) {
    if (country == null || region == null) {
      return Future.value([]);
    }
    return restCountries.getCities(
        region: region.region, country: country.code);
  }

  @override
  Future<List<Country>> getCountries() {
    return restCountries.getCountries();
  }

  @override
  Future<Country> getCountryByCountry({Country country}) async {
    try {
      return (await restCountries.searchCountry(keyword: country.name)).first;
    } catch (e) {
      return Future.value(null);
    }
  }

  @override
  Future<City> getCityByCity({City city, Country country}) async {
    try {
      return (await restCountries.getCities(
              keyword: city.city, country: country.code))
          .first;
    } catch (e) {
      return Future.value(null);
    }
  }

  @override
  Future<List<Region>> getRegionByCountry({Country country}) {
    if (country == null) {
      return Future.value([]);
    }
    return restCountries.getRegions(countryCode: country.code);
  }

  @override
  Future<Region> getRegionByRegion({Region region, Country country}) async {
    try {
      return (await restCountries.searchRegion(
              keyword: region.region, countryCode: country.code))
          .first;
    } catch (e) {
      return Future.value(null);
    }
  }
}
