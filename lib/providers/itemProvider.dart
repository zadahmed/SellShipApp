import 'package:SellShip/models/Items.dart';

class ItemProvider {
  //properties
  List<Item> forSaleList;

//class methods

// Future<List<Item>> fetchItems(int skip, int limit) async {
//   if (country == null) {
//     _getLocation();
//   } else {
//     var url = 'https://api.sellship.co/api/getitems/' +
//         locationcountry +
//         '/' +
//         0.toString() +
//         '/' +
//         20.toString();
//
//     final response = await http.post(Uri.parse(url), body: {
//       'latitude': position.latitude.toString(),
//       'longitude': position.longitude.toString()
//     });
//     if (response.statusCode == 200) {
//       var jsonbody = json.decode(response.body);
//       itemsgrid.clear();
//       for (var i = 0; i < jsonbody.length; i++) {
//         var q = Map<String, dynamic>.from(jsonbody[i]['dateuploaded']);
//
//         DateTime dateuploade =
//         DateTime.fromMillisecondsSinceEpoch(q['\$date']);
//         var dateuploaded = timeago.format(dateuploade);
//         Item item = Item(
//           itemid: jsonbody[i]['_id']['\$oid'],
//           date: dateuploaded,
//           name: jsonbody[i]['name'],
//           condition: jsonbody[i]['condition'] == null
//               ? 'Like New'
//               : jsonbody[i]['condition'],
//           username: jsonbody[i]['username'],
//           image: jsonbody[i]['image'],
//           likes: jsonbody[i]['likes'] == null ? 0 : jsonbody[i]['likes'],
//           comments: jsonbody[i]['comments'] == null
//               ? 0
//               : jsonbody[i]['comments'].length,
//           userid: jsonbody[i]['userid'],
//            price: jsonbody[i]['price'].toString(),
//   saleprice: jsonbody[i].containsKey('saleprice')
//                 ? jsonbody[i]['saleprice'].toString()
//                 : null,
//           category: jsonbody[i]['category'],
//           sold: jsonbody[i]['sold'] == null ? false : jsonbody[i]['sold'],
//         );
//         itemsgrid.add(item);
//       }
//     }
}
