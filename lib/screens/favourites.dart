import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:sellship/screens/details.dart';

class FavouritesScreen extends StatefulWidget {
  @override
  FavouritesScreenState createState() => FavouritesScreenState();
}

class FavouritesScreenState extends State<FavouritesScreen> {
  var userid;
  final storage = new FlutterSecureStorage();

  List<String> Itemid = List<String>();
  List<String> Itemname = List<String>();
  List<String> Itemimage = List<String>();
  List<String> Itemcategory = List<String>();
  List<String> Itemprice = List<String>();

  getfavourites() async {
    userid = await storage.read(key: 'userid');
    print(userid);
    if (userid != null) {
      var url = 'https://sellship.co/api/favourites/' + userid;
      final response = await http.get(url);
      if (response.statusCode == 200) {
        var respons = json.decode(response.body);
        var profilemap = respons;
        print(profilemap);
        for (var i = 0; i < profilemap.length; i++) {
          Itemid.add(profilemap[i]['_id']['\$oid']);
          Itemname.add(profilemap[i]['name']);
          Itemimage.add(profilemap[i]['image']);
          Itemprice.add(profilemap[i]['price']);
          Itemcategory.add(profilemap[i]['category']);
        }

        setState(() {
          Itemid = Itemid;
          Itemname = Itemname;
          Itemimage = Itemimage;
          Itemprice = Itemprice;
          Itemcategory = Itemcategory;
          loading = false;
        });
      } else {
        print(response.statusCode);
      }
    }
  }

  var loading;

  @override
  void initState() {
    super.initState();
    setState(() {
      loading = true;
    });
    getfavourites();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return loading == false
        ? Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Favourites ❤️",
                  style: Theme.of(context).textTheme.display1.copyWith(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
                SizedBox(
                  height: 15,
                ),

//          Bag list
                Expanded(
                    child: new ListView.builder(
                        itemCount: Itemname.length,
                        itemBuilder: (BuildContext ctxt, int Index) {
                          return new InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          Details(itemid: Itemid[Index])),
                                );
                              },
                              child: Card(
                                  child: ListTile(
                                title: Text(Itemname[Index]),
                                trailing: Text(Itemprice[Index]),
                                leading: Container(
                                  height: 60,
                                  width: 60,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Image.network(
                                    Itemimage[Index],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                subtitle: Text(Itemcategory[Index]),
                              )));
                        }))
              ],
            ),
          )
        : Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)), //this right here
            child: Container(
              height: 100,
              width: 100,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Loading'),
                    SizedBox(
                      height: 10,
                    ),
                    CircularProgressIndicator()
                  ],
                ),
              ),
            ),
          );
  }
}
