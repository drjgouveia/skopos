import 'dart:core';
import 'package:flutter/material.dart';
import 'package:skopos/data_handling.dart';

class SelectionScreen extends StatelessWidget {
  SelectionScreen({Key? key}) : super(key: key);

  Future<List<dynamic>> loadProds() async {
    List<dynamic> list = await getListProds();
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
        future: loadProds(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<dynamic> list = snapshot.data ?? [];
            return Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(38.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                        "Escolha um produto",
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w700
                        )
                    ),
                    Expanded(
                      child: ListView.separated(
                        itemCount: list.length,
                        itemBuilder: (context, index) =>
                            Card(
                              key: ValueKey(list[index]["id"]),
                              color: Colors.grey[200],
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 0),
                              child: ListTile(
                                title: Text(list[index]['name']),
                                subtitle: Text(
                                    '${list[index]["price"].toStringAsFixed(2)} €'),
                                onTap: () {
                                  addCart(list[index]["id"], list[index]["name"], list[index]["price"]);
                                  Navigator.pop(context);
                                },
                              ),
                            ), separatorBuilder: (BuildContext context, int index) => const Divider(),
                      ),
                    )
                  ],
                ),
              ),
            );
          } else {
            return const CircularProgressIndicator();
          }
        }
    );
  }
}