import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:skopos/data_handling.dart';


class ExpensesPage extends StatefulWidget {
  const ExpensesPage({Key? key}) : super(key: key);

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  List<dynamic> list_expenses = [], results = [];
  late Widget results_widget, finalTotal;

  Widget generateProdInfoText(Map<String, dynamic> list) {
    List<Widget> texts = [];
    double totalFinal = 0.0;
    texts.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 8.0),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("Nome", style: TextStyle(fontWeight: FontWeight.w500)),
                Text("Quantidade", style: TextStyle(fontWeight: FontWeight.w500)),
                Text("Total", style: TextStyle(fontWeight: FontWeight.w500)),
              ]
          ),
        )
    );
    for(int index=0; index < list["prods"].length; index++) {
      totalFinal += list["prods"][index]["qty"] * list["prods"][index]["price"];
      texts.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${list["prods"][index]["name"]}"),
                Text("${list["prods"][index]["qty"]}"),
                Text("${(list["prods"][index]["qty"] * list["prods"][index]["price"]).toStringAsFixed(2)}"),
              ]
          )
      );
    }

    return Column(children: texts);
  }

  Widget generateFinalTotal(Map<String, dynamic> list) {
    List<Widget> texts = [];
    double totalFinal = 0.0;
    for(int index=0; index < list["prods"].length; index++) {
      totalFinal += list["prods"][index]["qty"] * list["prods"][index]["price"];
    }

    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Total:"),
          Text("${totalFinal.toStringAsFixed(2)} €"),
        ]
    );
  }

  Widget generateSlide(var list) {
    List<dynamic> temp = list;

    return CarouselSlider.builder(
      itemCount: list.length,
      itemBuilder: (BuildContext context, int index, int pageViewIndex) =>
        Container(
          color: Colors.blueGrey[100],
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Text(
                      list[index]["date"].toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 15.0),
                    child: generateProdInfoText(list[index]),
                  ),
                  generateFinalTotal(list[index]),
                ],
              ),
            ),
          ),
        ),
      options: CarouselOptions(
        height: 400,
        aspectRatio: 16/9,
        viewportFraction: 0.8,
        initialPage: 0,
        enableInfiniteScroll: true,
        reverse: true,
        autoPlay: false,
        enlargeCenterPage: true,
        scrollDirection: Axis.horizontal,
      ),
    );
  }

  Future<Widget> loadList() async {
    var temp = await getListExpenses();

    if(temp.isEmpty) {
      results_widget = const Text("Sem dados.");
      return results_widget;
    } else {
      results = organizeExpenses(temp);
      results_widget = generateSlide(results);
      return results_widget;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: loadList(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(35.0, 45.0, 35.0, 40.0),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(35.0),
                    child: Text("Receita", style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600)),
                  ),
                  results_widget,
                ],
              )
            ),
          );
        } else {
          return const CircularProgressIndicator();
        }
      }
    );
  }
}
