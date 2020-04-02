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
              child: Column(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 100,
                    margin: const EdgeInsets.only(right: 15.0),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (ctx, i) {
                        return Row(
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedCat = i;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 25.0),
                                width: 110.0,
                                constraints: BoxConstraints(minHeight: 101),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: _selectedCat == i
                                      ? Border.all(color: Colors.amber)
                                      : Border(),
                                  color: _selectedCat == i
                                      ? Colors.transparent
                                      : Colors.amber,
                                  borderRadius: BorderRadius.circular(9.0),
                                ),
                                child: Text(
                                  "${categories[i].title}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .button
                                      .copyWith(
                                          color: _selectedCat == i
                                              ? Colors.amber
                                              : Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            )
                          ],
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
