import 'dart:collection';

class Property {
  String propertyName, address, area, cost, id, tenant, url;
  Property(this.propertyName, this.address, this.area, this.cost, this.id,
      this.tenant, this.url);

  Property.fromJson(LinkedHashMap<dynamic, dynamic> data)
      : propertyName = data["propertyName"],
        address = data["address"],
        area = data["area"],
        cost = data["cost"],
        tenant = data["tenant"],
        id = data["id"],
        url = data["url"];
}
