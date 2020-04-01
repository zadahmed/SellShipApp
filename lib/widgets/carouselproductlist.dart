import 'package:flutter/material.dart';
import 'package:sellship/global.dart';

enum CarouselTypes { home, details }

class CarouselProductList extends StatefulWidget {
  final CarouselTypes type;
  final List<String> productList;
  const CarouselProductList({
    Key key,
    @required this.type,
    @required this.productList,
  }) : super(key: key);

  @override
  _CarouselProductListState createState() => _CarouselProductListState();
}

class _CarouselProductListState extends State<CarouselProductList> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      child: Column(
        children: <Widget>[
          Expanded(
            child: PageView.builder(
              controller: PageController(
                viewportFraction:
                    widget.type == CarouselTypes.details ? .75 : .95,
              ),
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: widget.productList.length,
              itemBuilder: (ctx, id) {
                return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      color: widget.type == CarouselTypes.details
                          ? Colors.white
                          : Colors.transparent,
                    ),
                    margin: widget.type == CarouselTypes.details &&
                            _currentIndex != id
                        ? const EdgeInsets.symmetric(
                            horizontal: 9.0, vertical: 15.0)
                        : const EdgeInsets.symmetric(
                            horizontal: 9.0, vertical: 0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: Image.network(
                        "${widget.productList[id]}",
                        fit: BoxFit.cover,
                      ),
                    ));
              },
            ),
          ),
          SizedBox(height: 9),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.productList.length, (i) {
                return Container(
                  width: 9.0,
                  height: 9.0,
                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == _currentIndex ? Colors.black : Colors.grey,
                  ),
                );
              }))
        ],
      ),
    );
  }
}
