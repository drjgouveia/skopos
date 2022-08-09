import 'dart:core';
import 'package:flutter/material.dart';
import 'package:skopos/data_handling.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  List<dynamic> list_prods = [];
  List<dynamic> results = [];
  Widget results_list = const Text("Sem dados.");
  double price = 0.0;
  String name = "";

  Widget generateList(List<dynamic> list) {
    return ListView.separated(
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
                removeProd(list[index]["id"].toString());
                setState(() {
                  results_list = generateList(list_prods);
                });
              },
              icon: const Icon(Icons.delete_outline, size: 27)
          ),
          title: Text(list[index]['name']),
          subtitle: Text('${list[index]["price"].toStringAsFixed(2)} €'),
        ),
      ),
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }

  Future<Widget> loadList() async {
    list_prods = await getListProds();
    results = list_prods;

    if(list_prods.isEmpty) {
      results_list = const Text("Sem produtos.");
      return results_list;
    } else {
      results_list = generateList(results);
      return results_list;
    }
  }

  void runFilter(String enteredKeyword) {
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = list_prods;
    } else {
      results = list_prods.where((prod) => prod["name"].toLowerCase().contains(enteredKeyword.toLowerCase())).toList();
    }

    setState(() {
      results = results;
      results_list = generateList(results);
    });
  }

  void formAddProd(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Stack(
            children: <Widget>[
              Positioned(
                right: -40.0,
                top: -40.0,
                child: InkResponse(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: const CircleAvatar(
                    child: Icon(Icons.close, color: Colors.white),
                    backgroundColor: Colors.red,
                  ),
                ),
              ),
              Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      "Novo produto",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white70)
                          ),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.blueGrey)
                          ),
                          hintText: "Nome",
                        ),
                        keyboardType: TextInputType.name,
                        onSaved: (value) {
                          name = value ?? "";
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        decoration: const InputDecoration(
                            border: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white70)
                            ),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.blueGrey)
                            ),
                            hintText: "Preço"
                        ),
                        keyboardType: TextInputType.number,
                        onSaved: (value) {
                          value = value?.replaceAll(",", ".");
                          price = double.parse(value ?? "0.0");
                        },
                      ),
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.blueGrey),
                        padding: MaterialStateProperty.all(const EdgeInsets.all(8.0)),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          addProd(name, price);
                          list_prods = await getListProds();
                          setState(() {
                            results_list = generateList(list_prods);
                          });
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text(
                          "Adicionar"
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: loadList(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Padding(
            padding: const EdgeInsets.all(35.0),
            child: Column(
              children: [
                Container(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Página principal",
                          style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w700
                          )
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                            elevation: MaterialStateProperty.all(0),
                            backgroundColor: MaterialStateProperty.all<Color>(Colors.blueGrey),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                          onPressed: () {
                            formAddProd(context);
                          },
                          child: const Text(
                            "Add Produto"
                          )
                        ),
                      ],
                    )
                ),
                const SizedBox(height: 5),
                Container(
                  alignment: Alignment.centerLeft,
                  child: const SizedBox(
                    height: 3,
                    width: 150,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                          color: Colors.black12
                      )
                    ),
                  ),
                ),
                /* const SizedBox(height: 10),
                TextField(
                  onChanged: (value) => runFilter(value),
                  decoration: const InputDecoration(
                    labelText: 'Search',
                    suffixIcon: Icon(Icons.search)
                  ),
                ), */
                const SizedBox(height: 30),
                Expanded(
                  flex: 1,
                  child: Container(
                    constraints: const BoxConstraints.expand(),
                    child: Center(
                        child: results_list
                    ),
                  ),
                )
              ],
            ),
          );
        } else {
          return const Center(
              child: CircularProgressIndicator()
          );
        }
      }
    );
  }
}
