import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

List<dynamic> calculateQuantities(items) {
  Map<String, dynamic> uniqueItems = {};

  for (Map item in items) {
    final key = '${item["id_prod"]}';

    try {
      (uniqueItems[key] == null)
          ? uniqueItems[key] = item
          : uniqueItems[key]['qty'] += item['qty'];
    } catch(e) {
      uniqueItems[key] = item;
    }
  }

  return uniqueItems.values.toList();
}

List<dynamic> organizeExpenses(List<dynamic> items) {
  Map<String, dynamic> uniqueItems = {};
  
  items.removeWhere((element) => element.length == 0);
  for(var item in items) {
    List<dynamic> venda = [];
    try {
      for(var i in item[1]) {
        venda.add({"id": i["id_prod"], "name": i["name"], "price": i["price"], "qty": i["qty"]});
      }
    } on RangeError {
      venda = [];
    }

    if(uniqueItems.containsKey(item[0].toString())) {
      Map<String, dynamic> x = uniqueItems[item[0].toString()];
      for(var z in x["prods"]) {
        for(var v in venda) {
          if(v["id_prod"] == z["id_prod"]) {
            z["qty"] += v["qty"];
          }
        }
      }
    } else {
      Map<String, dynamic> temp = {"prods": venda, "date": item[0].toString()};
      uniqueItems[item[0].toString()] = temp;
    }
  }

  return uniqueItems.values.toList();
}

Future<FlutterSecureStorage> loadSharedPreferences() async {
  const storage = FlutterSecureStorage();
  return storage;
}

Future<List<dynamic>> getListProds() async {
  var storage = await loadSharedPreferences();
  String listEncoded = await storage.read(key: "prods") ?? "";
  try {
    return json.decode(listEncoded);
  } on FormatException {
    return [];
  }
}

void addProd(String name, double price) async {
  List<dynamic> list = await getListProds();
  FlutterSecureStorage storage = await loadSharedPreferences();

  if(list.isNotEmpty) {
    list.sort((a, b) => a["id"].compareTo(b["id"]));
    int last_element = list.last["id"];
    list.add({"id": last_element + 1, "name": name, "price": price});
  } else {
    list.add({"id": 1, "name": name, "price": price});
  }

  storage.write(key: "prods", value: json.encode(list));
}

void removeProd(String id) async {
  List<dynamic> list = await getListProds();
  FlutterSecureStorage storage = await loadSharedPreferences();

  list.removeWhere((prod) => prod["id"].toString() == id);

  storage.write(key: "prods", value: json.encode(list));
}

Future<List<dynamic>> getListCart() async {
  var storage = await loadSharedPreferences();
  String listEncoded = await storage.read(key: "cart") ?? "";
  try {
    return json.decode(listEncoded);
  } on FormatException {
    return [];
  }
}

void addCart(int id_prod, String name, double price) async {
  List<dynamic> all = await getListCart();
  FlutterSecureStorage storage = await loadSharedPreferences();
  var list = [];

  try {
    for(var item in all[1]) {
      list.add({"id": item["id"], "id_prod": item["id_prod"], "name": item["name"], "price": item["price"], "qty": item["qty"]});
    }
  } on RangeError {
    list = [];
  }
  var temp = list;

  DateTime now = DateTime.now();
  String time = "${(now.day).toString().padLeft(2,"0")}-${now.month.toString().padLeft(2,"0")}-${now.year.toString()}";

  if(list.isNotEmpty) {
    temp.sort((a, b) => a["id"].compareTo(b["id"]));
    int last_element = temp.last["id"];
    list.add({"id": last_element + 1, "id_prod": id_prod, "name": name, "price": price, "qty": 1});
    list = calculateQuantities(list);
  } else {
    list.add({"id": 1, "id_prod": id_prod, "name": name, "price": price, "qty": 1});
  }

  if(all.isEmpty) {
    all.add(time);
    all.add(list);
  } else {
    all[0] = time;
    all[1] = list;
  }

  storage.write(key: "cart", value: json.encode(all));
}

void removeCart(String id) async {
  List<dynamic> all = await getListCart();
  List<dynamic> list = all[1];
  FlutterSecureStorage storage = await loadSharedPreferences();

  DateTime now = DateTime.now();
  String time = "${now.day.toString().padLeft(2,"0")}-${now.month.toString().padLeft(2,"0")}-${now.year.toString()}";
  all[0] = time;
  for(var item in all[1]) {
    if(item["id"].toString() == id) {
      if(item["qty"] > 1) {
        item["qty"]--;
      } else {
        list.removeWhere((prod) => prod["id"].toString() == id);
      }
      break;
    }
  }

  if(list.isEmpty) {
    cleanCart();
  } else {
    all[1] = list;
    storage.write(key: "cart", value: json.encode(all));
  }
}

void cleanCart() async {
  FlutterSecureStorage storage = await loadSharedPreferences();
  storage.delete(key: "cart");
}

Future<List<dynamic>> getListExpenses() async {
  var storage = await loadSharedPreferences();
  String listEncoded = await storage.read(key: "expenses") ?? "";
  try {
    return json.decode(listEncoded);
  } on FormatException {
    return [];
  }
}

void addExpense() async {
  List<dynamic> cart = await getListCart();
  List<dynamic> expenses = await getListExpenses();

  FlutterSecureStorage storage = await loadSharedPreferences();
  expenses.add(cart);
  cleanCart();

  storage.write(key: "expenses", value: json.encode(expenses));
}


