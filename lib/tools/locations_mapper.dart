import 'package:geocoding/geocoding.dart';

class LocationMapper {
  // List<Placemark> placemarks;
  // var location;
  get_user_location_from_coordinates(double latitude, double longitude) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude, longitude);
    // print(placemarks);
    String state = placemarks
        .toList()[0]
        .toString()
        .split(",")[5] // uptohere we get a listlike [country,US,ZipCode,3]
        .split(":")[1]
        .replaceAll(" ", "");
    return state;
    // return placemarks;

  }
  // LocationMapper.init_location(String location){
  //   this.location = locationFromAddress(location);
  // }

  // get_state() async {
  //   String state = placemarks
  //       .toList()[0]
  //       .toString()
  //       .split(",")[5] // uptohere we get a listlike [country,US,ZipCode,3]
  //       .split(":")[1]
  //       .replaceAll(" ", "");
  //   return state;
  // }
}
