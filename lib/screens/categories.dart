import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sellship/global.dart';
import 'package:sellship/screens/categorydetail.dart';

class CategoryScreen extends StatefulWidget {
  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  int _selectedCat = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Categories",
              style: Theme.of(context)
                  .textTheme
                  .display1
                  .copyWith(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(
              height: 15,
            ),
            Expanded(
              child: Row(
                children: <Widget>[
                  Container(
                    width: 50,
                    margin: const EdgeInsets.only(right: 15.0),
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: categories.length,
                      itemBuilder: (ctx, i) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCat = i;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 25.0),
                            width: 50.0,
                            constraints: BoxConstraints(minHeight: 101),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border:
                                  _selectedCat == i ? Border.all() : Border(),
                              color: _selectedCat == i
                                  ? Colors.transparent
                                  : Colors.black,
                              borderRadius: BorderRadius.circular(9.0),
                            ),
                            child: RotatedBox(
                              quarterTurns: -1,
                              child: Text(
                                "${categories[i].title}",
                                style: Theme.of(context)
                                    .textTheme
                                    .button
                                    .copyWith(
                                        color: _selectedCat == i
                                            ? Colors.black
                                            : Colors.white),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

//                  Content of categories
                  Expanded(
                    flex: 4,
                    child: ListView.builder(
                      itemCount: categories[_selectedCat].subCat.length,
                      itemBuilder: (ctx, i) {
                        return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CategoryDetail(
                                        category:
                                            categories[_selectedCat].title)),
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.only(bottom: 15),
                              padding: const EdgeInsets.all(9.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      "${categories[_selectedCat].subCat[i].title}",
                                    ),
                                  ),
                                  Icon(Icons.chevron_right)
                                ],
                              ),
                            ));
                      },
                    ),
                  )
                ],
              ),
            ),
          ],
        ));
  }
}
