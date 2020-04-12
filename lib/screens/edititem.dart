import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:sellship/models/Items.dart';
import 'package:sellship/screens/login.dart';

class EditItem extends StatefulWidget {
  final String itemid;

  EditItem({Key key, this.itemid}) : super(key: key);

  @override
  EditItemState createState() => EditItemState();
}

class EditItemState extends State<EditItem>
    with SingleTickerProviderStateMixin {
  bool _status = true;
  final FocusNode myFocusNode = FocusNode();

  String itemid;

  var loading;

  @override
  void initState() {
    super.initState();
    setState(() {
      itemid = widget.itemid;
      loading = true;
    });
    getProfileData();
  }

  Future getImage() async {
    var images = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 400, maxWidth: 400);

    setState(() {
      image = images;
    });
  }

  final storage = new FlutterSecureStorage();

  var itemname;
  var itemdescription;
  var itemprice;
  var itemimage;

  var userid;
  File image;

  void getProfileData() async {
    var url = 'https://sellship.co/api/getitem/' + itemid;
    final response = await http.get(url);
    if (response.statusCode == 200) {
      var respons = json.decode(response.body);
      var profilemap = respons[0];
      print(profilemap);

      if (mounted) {
        setState(() {
          itemname = profilemap['name'];
          itemdescription = profilemap['description'];
          itemimage = profilemap['image'];
          itemprice = profilemap['price'];

          firstnamecontr.text = itemname;
          lastnamecontr.text = itemdescription;
          emailnamecontr.text = itemprice;
          loading = false;
        });
        userid = await storage.read(key: 'userid');
        setState(() {
          userid = userid;
        });
      }
    } else {
      print('Error');
    }
  }

  TextEditingController firstnamecontr = TextEditingController();
  TextEditingController lastnamecontr = TextEditingController();
  TextEditingController emailnamecontr = TextEditingController();
  TextEditingController phonenamecontr = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            'Edit Item',
            style: TextStyle(color: Colors.black),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
              size: 22.0,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: loading == false
            ? new Container(
                color: Colors.white,
                child: new ListView(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        new Container(
                          color: Color(0xffFFFFFF),
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 25.0),
                            child: new Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                    padding: EdgeInsets.only(
                                        left: 25.0, right: 25.0, top: 25.0),
                                    child: new Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        new Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            new Text(
                                              'Item Details',
                                              style: TextStyle(
                                                  fontSize: 18.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        new Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            _status
                                                ? _getEditIcon()
                                                : new Container(),
                                          ],
                                        )
                                      ],
                                    )),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    InkWell(
                                      onTap: () {
                                        getImage();
                                      },
                                      child: Container(
                                          decoration: BoxDecoration(
                                              color: Colors.grey.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          height: 120,
                                          width: 120,
                                          child: image == null
                                              ? Image.network(
                                                  itemimage,
                                                  fit: BoxFit.cover,
                                                )
                                              : Image.file(
                                                  image,
                                                  fit: BoxFit.cover,
                                                )),
                                    ),
                                  ],
                                ),
                                Padding(
                                    padding: EdgeInsets.only(
                                        left: 25.0, right: 25.0, top: 25.0),
                                    child: new Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        new Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            new Text(
                                              'Item Name',
                                              style: TextStyle(
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )),
                                Padding(
                                    padding: EdgeInsets.only(
                                        left: 25.0, right: 25.0, top: 2.0),
                                    child: new Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        new Flexible(
                                          child: new TextField(
                                            decoration: const InputDecoration(
                                              hintText: "Enter Your Item Name",
                                            ),
                                            enabled: !_status,
                                            controller: firstnamecontr,
                                            autofocus: !_status,
                                          ),
                                        ),
                                      ],
                                    )),
                                Padding(
                                    padding: EdgeInsets.only(
                                        left: 25.0, right: 25.0, top: 25.0),
                                    child: new Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        new Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            new Text(
                                              'Item Description',
                                              style: TextStyle(
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )),
                                Padding(
                                    padding: EdgeInsets.only(
                                        left: 25.0, right: 25.0, top: 2.0),
                                    child: new Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        new Flexible(
                                          child: new TextField(
                                            decoration: const InputDecoration(
                                              hintText:
                                                  "Enter Your Item Description",
                                            ),
                                            enabled: !_status,
                                            maxLines: 5,
                                            controller: lastnamecontr,
                                            autofocus: !_status,
                                          ),
                                        ),
                                      ],
                                    )),
                                Padding(
                                    padding: EdgeInsets.only(
                                        left: 25.0, right: 25.0, top: 25.0),
                                    child: new Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        new Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            new Text(
                                              'Item Price',
                                              style: TextStyle(
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )),
                                Padding(
                                    padding: EdgeInsets.only(
                                        left: 25.0, right: 25.0, top: 2.0),
                                    child: new Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        new Flexible(
                                          child: new TextField(
                                            decoration: const InputDecoration(
                                                hintText: "Enter Item Price"),
                                            enabled: !_status,
                                            controller: emailnamecontr,
                                            keyboardType: TextInputType
                                                .numberWithOptions(),
                                          ),
                                        ),
                                      ],
                                    )),
                                !_status
                                    ? _getActionButtons()
                                    : new Container(),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              )
            : Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(20.0)), //this right here
                child: Container(
                  height: 100,
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
              ));
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    myFocusNode.dispose();
    super.dispose();
  }

  Widget _getActionButtons() {
    return Padding(
      padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 45.0),
      child: new Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(3),
              child: Container(
                  child: new RaisedButton(
                child: new Text("Save"),
                textColor: Colors.white,
                color: Colors.green,
                onPressed: () async {
                  var url = 'https://sellship.co/api/updateitem/' + itemid;

                  Dio dio = new Dio();
                  var response;

                  if (image != null) {
                    String fileName = image.path.split('/').last;
                    FormData formData = FormData.fromMap({
                      'name': firstnamecontr.text,
                      'description': lastnamecontr.text,
                      'price': emailnamecontr.text,
                      'image': await MultipartFile.fromFile(image.path,
                          filename: fileName)
                    });
                    response = await dio.post(url, data: formData);
                  } else {
                    FormData formData = FormData.fromMap({
                      'name': firstnamecontr.text,
                      'description': lastnamecontr.text,
                      'price': emailnamecontr.text,
                    });
                    response = await dio.post(url, data: formData);
                  }

                  if (response.statusCode == 200) {
                    print(response.data);
                    setState(() {
                      _status = true;
                      FocusScope.of(context).requestFocus(new FocusNode());
                      getProfileData();
                    });
                  } else {
                    print(response.statusCode);
                  }
                },
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0)),
              )),
            ),
            flex: 2,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(3),
              child: Container(
                  child: new RaisedButton(
                child: new Text("Cancel"),
                textColor: Colors.white,
                color: Colors.amber,
                onPressed: () {
                  setState(() {
                    _status = true;
                    FocusScope.of(context).requestFocus(new FocusNode());
                  });
                },
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0)),
              )),
            ),
            flex: 2,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(3),
              child: Container(
                  child: new RaisedButton(
                child: new Text("Delete"),
                textColor: Colors.white,
                color: Colors.red,
                onPressed: () async {
                  var url = 'https://sellship.co/api/deleteitem/' +
                      itemid +
                      "/" +
                      userid;

                  var response = await http.get(url);

                  if (response.statusCode == 200) {
                    print(response.body);
                    setState(() {
                      _status = true;
                      FocusScope.of(context).requestFocus(new FocusNode());
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    });
                  } else {
                    print(response.statusCode);
                  }
                },
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0)),
              )),
            ),
            flex: 2,
          ),
        ],
      ),
    );
  }

  Widget _getEditIcon() {
    return new GestureDetector(
      child: new CircleAvatar(
        backgroundColor: Colors.red,
        radius: 14.0,
        child: new Icon(
          Icons.edit,
          color: Colors.white,
          size: 16.0,
        ),
      ),
      onTap: () {
        setState(() {
          _status = false;
        });
      },
    );
  }
}
