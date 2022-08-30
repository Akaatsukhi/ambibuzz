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
  final fetchDogData = FetchDogData();

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
      return FutureBuilder<List<DogBreed>>(
        future: fetchDogData.getDogBreed(query: query),
        builder: (context, snapshot) {
          // If snapshot hasData but data is empty
          // In case where there is no breed of dog.
          if (snapshot.hasData && snapshot.data!.isEmpty) {
            return Center(
              child:
                  Text('Unable to find dog with this name : ${snapshot.data}'),
            );
          }

          if (snapshot.hasData) {
            // Data of DogBreed.
            final data = snapshot.data;

            return ListView.builder(
                itemCount: data!.length,
                itemBuilder: (context, index) {
                  return DogWidget(
                      fetchDogData: fetchDogData, data: data, index: index);
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

/// Dog Widget reponsible for displayig the dog image in the listview.
/// And prior to that it relay on parent Future builder which provide
/// breed data such as [breed_id] and [breed_name] and once snapshot.hadData
/// It will display the `DogWidget`  correspomding to `breed_id` and
/// will display the list image when snapshot is ready.
/// It has two main parameter  [fetchDogData] --> object which hold method for fetch Image from breed_id.
/// [data] --> Breed related Data which been fetched from above parent FutureBuilder.
class DogWidget extends StatefulWidget {
  const DogWidget({
    Key? key,
    required this.fetchDogData,
    required this.data,
    required this.index,
  }) : super(key: key);

  // FetchDogData class object hold method for fetching breed_name and breed Images.
  final FetchDogData fetchDogData;

  // List Dogbreed which hold  property beed_id and beed_name.
  final List<DogBreed>? data;

  // index value from parent listView builder.
  final int index;

  @override
  State<DogWidget> createState() => _DogWidgetState();
}

class _DogWidgetState extends State<DogWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SizedBox(
      height: MediaQuery.of(context).size.height / 3,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          // Show the images of Dogs.
          child: FutureBuilder<DogImage>(
            future: widget.fetchDogData.dogImage(widget.data![widget.index].id),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Image.network(
                  snapshot.data!.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                        child: Center(
                      child: CircularProgressIndicator(),
                    ));
                  },
                );
              }

              return Center(
                child: Text(
                  widget.data![widget.index].dogBreedName,
                  textScaleFactor: 1.3,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

// Class for to networking such fetching Data related Dog's.
class FetchDogData {
  Future<List<DogImage>> dogData(List<DogBreed> dogData) async {
    var future = dogData.map((e) {
      return dogImage(e.id);
    });

    // return DogData(dogbreed: uid, dogImage: await Future.wait(future));
    return Future.wait(future);
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

// Class hold Data realted to Dod image which can be obtained from breed_id.
class DogImage {
  final String imageUrl;

  DogImage({required this.imageUrl});
  factory DogImage.fromJson(Map<String, dynamic> json) {
    return DogImage(imageUrl: json['url']);
  }
}
