import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DogScreen extends StatefulWidget {
  static const String id = 'dog_screen';

  const DogScreen({super.key});

  @override
  State<DogScreen> createState() => _DogScreenState();
}

class _DogScreenState extends State<DogScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
      actions: [
        IconButton(
            onPressed: () {
              showSearch(context: context, delegate: MySearchDelegate());
            },
            icon: const Icon(Icons.search))
      ],
    ));
  }
}

class MySearchDelegate extends SearchDelegate {
  final fetchDogBreed = FetchDogData();

  @override
  // Leading Widget on Appbar which handle logic of Navigating back.
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  // List of Widget after search which can used accordingly to handle
  // different task such as clearing the query or toggling any state.
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () async {
          if (query.isEmpty) {
            close(context, null);
          } else {
            query = '';
          }
        },
        icon: const Icon(Icons.close_rounded),
      )
    ];
  }

  @override
  // The results shown after the user submits a search from the search page.
  Widget buildResults(BuildContext context) {
    return Center(
      child: Text(query),
    );
  }

  @override
  // Suggestions shown in the body of the search page while the user types a query into the search field.
  Widget buildSuggestions(BuildContext context) {
    // Show the result only if user type the character more then 3.
    if (query.length > 3) {
      return FutureBuilder<DogData>(
        // future: Future.wait(
        //     [fetchDogBreed.getDogBreed(query: query), fetchDogBreed.dog()]),
        future: fetchDogBreed.dogData(query),
        builder: (context, snapshot) {
          final data = snapshot.data;
          if (snapshot.hasData && data!.dogbreed.isEmpty) {
            return const Center(
                child: Text('Unable to find dog with this name'));
          }

          if (snapshot.hasData) {
            return ListView.builder(
                // if length of the result is greater than it show the 6 result
                // to prevent the rate limiter.
                itemCount: data!.dogbreed.length,
                itemBuilder: (context, index) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height / 3,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          // Show the images of Dogs.
                          child: Image.network(
                            data.dogImage[index].imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              // Show the dog breed name until image are loaded.
                              return Center(
                                  child: Text(
                                data.dogbreed[index].dogBreedName,
                                textScaleFactor: 1.5,
                              ));
                            },
                          )),
                    ),
                  );
                });
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          // By default, show loading spinner.
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );
    }

    // By default, show the Text when type character are
    // not more than required one.
    return const Center(
        child: Text(
      'Please alleast three character to search',
    ));
  }
}

// Class for to networking such fetching relate Work.
class FetchDogData {
  Future<DogData> dogData(String? query) async {
    final uid = await getDogBreed(query: query);
    var future = uid.map((e) {
      return dogImage(e.id);
    });

    return DogData(dogbreed: uid, dogImage: await Future.wait(future));
  }

  Future<DogImage> dogImage(int id) async {
    final res = await http.get(
        Uri.parse(
            'https://api.thedogapi.com/v1/images/search?breed_id=$id&limit=6'),
        headers: {
          'x-api-key':
              'live_m1Di7hdd23gFNTj5aPxsyXxWH6aBgqAl0rEABK8aiJyQ2eFkccCZ9aqKCrL7kg6d'
        });
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);

      if (data.isNotEmpty) {
        return DogImage.fromJson(data[0]);
      } else {
        return DogImage(
            imageUrl:
                'https://www.thermaxglobal.com/wp-content/uploads/2020/05/image-not-found-300x169.jpg');
      }
      // bull
    } else {
      throw Exception();
    }
  }

  // Future which return data reagarding dog such as bread name and image url.
  Future<List<DogBreed>> getDogBreed({String? query}) async {
    final response = await http.get(
        Uri.parse('https://api.thedogapi.com/v1/breeds/search?q=$query'),
        headers: {
          'x-api-key':
              'live_m1Di7hdd23gFNTj5aPxsyXxWH6aBgqAl0rEABK8aiJyQ2eFkccCZ9aqKCrL7kg6d'
        });

    // Check if request is successsful (200 OK) or not .
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      // print(data);
      // convert the JSON Map into an List of DogBreed using the fromJson() factory method.
      final result = data.map((e) {
        return DogBreed.fromJson(json: e);
      }).toList();

      if (query != null) {
        return result
            .where((element) => element.dogBreedName
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      }
      return result;
    } else {
      // If server not return the a 200 OK response,
      // then throw  a exception.
      throw Exception('Failed to load the DogBreed');
    }
  }
}

// Information related to Dog
// Such that it hold dog image  and dogbreed
class DogData {
  final List<DogBreed> dogbreed;
  final List<DogImage> dogImage;
  DogData({required this.dogbreed, required this.dogImage});
}

// class hold data field of json call.
// or json modal  classes.
// Information realted to dog breed name and breed id.
// which is help in find out the image correspond to it.
class DogBreed {
  final int id;
  final String dogBreedName;

  DogBreed({
    required this.id,
    required this.dogBreedName,
  });

  factory DogBreed.fromJson({required Map<String, dynamic> json}) {
    return DogBreed(
      id: json['id'],
      dogBreedName: json['name'],
    );
  }
}

// Dog image which obtain breed id.
class DogImage {
  final String imageUrl;

  DogImage({required this.imageUrl});
  factory DogImage.fromJson(Map<String, dynamic> json) {
    return DogImage(
        imageUrl: json['url'] ??
            'https://wellesleysocietyofartists.org/wp-content/uploads/2015/11/image-not-found.jpg');
  }
}
