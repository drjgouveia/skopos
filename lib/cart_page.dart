import 'package:flutter/material.dart';
import 'package:skopos/selection_prod.dart';

import 'data_handling.dart';


class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<dynamic> list_cart = [];
  List<dynamic> results = [];
  double total = 0.0;
  Widget results_list = const Text("Sem dados.");

  Widget generateList(List<dynamic> list) {
    list = list[1];
    return ListView.separated(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, index) => Card(
        key: ValueKey(list[index]["id"]),
        color: Colors.grey[200],
        elevation: 1,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
        ),
        margin: const EdgeInsets.symmetric(vertical: 0),
        child: ListTile(
          trailing: IconButton(
              onPressed: () {
                removeCart(list[index]["id"].toString());
                setState(() {
                  results_list = generateList(list_cart);
                });
              },
              icon: const Icon(Icons.remove, size: 27, color: Colors.red)
          ),
          title: Text(list[index]['name']),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${list[index]["price"].toStringAsFixed(2)} €'),
              Text(
                'x${list[index]["qty"]}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold
                )
              )
            ]
          ),
        ),
      ), separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }

  double calcTotal(List<dynamic> list_cart) {
    double val = 0.0;
    List<dynamic> list = [];
    if(list_cart.isNotEmpty) {
      for (var item in list_cart[1]) {
        list.add({
          "id": item["id"],
          "id_prod": item["id_prod"],
          "name": item["name"],
          "price": item["price"],
          "qty": item["qty"]
        });
      }
    }

    if(list.isNotEmpty) {
      for (var result in list_cart[1]) {
        val += result["price"] * result["qty"];
      }
    } else {
      val = 0.0;
    }

    return val;
  }

  Future<Widget> loadList() async {
    list_cart = await getListCart();
    results = list_cart;
    total = calcTotal(list_cart);

    if(list_cart.isEmpty) {
      results_list = Text("Sem produtos.");
      return results_list;
    } else {
      results_list = generateList(results);
      return results_list;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: loadList(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(35.0, 45.0, 35.0, 40.0),
            child: Column(
              children: <Widget>[
                Container(
                  alignment: Alignment.centerLeft,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                            "Conta",
                            style: TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.w700
                            )
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                            elevation: MaterialStateProperty.all(0.0),
                            backgroundColor: MaterialStateProperty.all(Colors.blueGrey),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                          onPressed: () async {
                            if(list_cart.isNotEmpty) {
                              addExpense();
                              results_list = await loadList();
                              setState(() {
                                results_list = results_list;
                              });
                            }
                          },
                          child: Row(
                            children: const [
                              Icon(Icons.save),
                              SizedBox(width: 20),
                              Text("Guardar")
                            ],
                          ),
                        )
                      ]
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  alignment: Alignment.centerLeft,
                  child: const SizedBox(
                    height: 3,
                    width: 30,
                    child: DecoratedBox(
                        decoration: BoxDecoration(
                            color: Colors.black12
                        )
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  flex: 1,
                  child: ListView(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    children: [
                      Card(
                        color: Colors.blueGrey[300],
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Conta:",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  )
                                ),
                                Text(
                                  "${total.toStringAsFixed(2)} €",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  )
                                )
                              ]
                            )
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.blueGrey),
                        ),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SelectionScreen()),
                          );
                          results_list = await loadList();
                          setState(() {
                            results_list = results_list;
                          });
                        },
                        child: const Center(
                            child: Padding(
                              padding: EdgeInsets.all(0.0),
                              child: Text(
                                'Adicionar produto',
                                style: TextStyle(color: Colors.white, fontSize: 17,fontWeight: FontWeight.w500),
                              ),
                            )
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
                          child: results_list,
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        } else {
          return const CircularProgressIndicator();
        }
      }
    );
  }
}
