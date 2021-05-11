import 'package:SellShip/models/Items.dart';

class Orders {
  final List<Item> items;
  final String orderid;
  final String orderdate;
  final int offerstage;
  final String sellername;
  final String sellerid;
  final String messageid;
  final String orderamount;

  Orders({
    this.items,
    this.sellername,
    this.sellerid,
    this.offerstage,
    this.orderamount,
    this.orderid,
    this.orderdate,
    this.messageid,
  });
}
