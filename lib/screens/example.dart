import 'package:http/http.dart' as http;
import 'dart:convert';

class FetchDogData {
  // Future which return data reagarding dog such as bread name and image url.
  Future<List<DogData>> getDogData({String? query}) async {
    final response = await http.get(
        Uri.parse('https://api.thecatapi.com/v1/breeds/search?q=$query'),
        // Uri.parse(
        //     'https://api.thedogapi.com/v1/images/search?limit=6&q=$query'),

        // Authenticating api-key registered with api.thedogi.com.
        headers: {
          'x-api-key':
              'live_m1Di7hdd23gFNTj5aPxsyXxWH6aBgqAl0rEABK8aiJyQ2eFkccCZ9aqKCrL7kg6d'
        });
    // Check if request is successsful (200 OK) or not .
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      // print(data);
      // convert the JSON Map into an List of DogData using the fromJson() factory method.
      final result = data.map((e) => DogData.fromJson(e)).toList();

      // Logic for search when use type query. If typed query is not null then it been checked coresponding the
      // result we get from api call. And if result conatins the query which been typed
      // then return the result accordingly.
      if (query != null) {
        return result
            .where((element) =>
                element.imageUrl.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
      return result;
    } else {
      // If server not return the a 200 OK response,
      // then throw  a exception.
      throw Exception('Failed to load the DogData');
    }
  }
}

// class hold data field of json call.
// or json modal  classes.
class DogData {
  final String imageUrl;

  final String dogBreedName;

  DogData({required this.imageUrl, required this.dogBreedName});

  factory DogData.fromJson(Map<String, dynamic> json) {
    return DogData(
      imageUrl: json['name'] ?? 'null',
      dogBreedName: json['breeds']?[0]['name'] ?? 'null',
    );
  }
}

void main() async {
  final dog = FetchDogData();
  final data2 = await dog.getDogData(query: 'american');
  for (var element in data2) {
    print(element.dogBreedName);
    print(element.imageUrl);
  }
}
