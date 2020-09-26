import 'package:mood_manager/features/mood_manager/data/models/parse/base_m_parse_mixin.dart';
import 'package:mood_manager/features/mood_manager/data/models/parse/photo_parse.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/city.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/country.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/gender.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/photo.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/region.dart';
import 'package:mood_manager/features/mood_manager/domain/entities/user_profile.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class UserProfileParse extends UserProfile with BaseMParseMixin {
  UserProfileParse({
    String id,
    String firstName,
    String lastName,
    String about,
    DateTime dateOfBirth,
    String profession,
    City city,
    Country country,
    ParseUser user,
    Region region,
    Photo profilePicture,
    bool isActive,
    Gender gender,
  }) : super(
          id: id,
          firstName: firstName,
          lastName: lastName,
          about: about,
          dateOfBirth: dateOfBirth,
          profession: profession,
          city: city,
          country: country,
          user: user,
          region: region,
          profilePicture: profilePicture,
          isActive: isActive,
          gender: gender,
        );

  static Future<UserProfileParse> fromParseObject(
      ParseObject parseObject) async {
    /*var country;
    var city;
    var region;
    if (parseObject.get('country', defaultValue: '').isNotEmpty) {
      country = await metadataSource.getCountryByCountry(
          country: parseObject.get('country'));
      if (parseObject.get('region', defaultValue: '').isNotEmpty) {
        region = await metadataSource.getRegionByRegion(
            region: parseObject.get('region'), country: country);
        if (parseObject.get('city', defaultValue: '').isNotEmpty) {
          city = await metadataSource.getCityByCity(
              city: parseObject.get('city'), country: country);
        }
      }
    }*/
    if (parseObject == null) {
      return Future.value(null);
    }
    return UserProfileParse(
        id: parseObject.get('objectId'),
        firstName: parseObject.get('firstName'),
        lastName: parseObject.get('lastName'),
        about: parseObject.get('about'),
        dateOfBirth: (parseObject.get('dateOfBirth') as DateTime).toLocal(),
        profession: parseObject.get('profession'),
        //city: city,
        //country: country,
        user: parseObject.get('user'),
        profilePicture:
            await PhotoParse.fromParseObject(parseObject.get('profilePicture')),
        //region: region,
        isActive: parseObject.get('isActive'));
  }

  ParseObject toParseObject() {
    ParseObject tMoodParse = baseParseObject(this);
    tMoodParse.set('firstName', firstName);
    tMoodParse.set('lastName', lastName);
    tMoodParse.set('about', about);
    tMoodParse.set('dateOfBirth', dateOfBirth.toUtc());
    tMoodParse.set('profession', profession);
    tMoodParse.set('user', user);
    tMoodParse.set(
        'profilePicture', (profilePicture as PhotoParse)?.toParseObject());
    //tMoodParse.set('city', city.city);
    //tMoodParse.set('country', country.code);
    return tMoodParse;
  }
}
