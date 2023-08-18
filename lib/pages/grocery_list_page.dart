import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/pages/new_item_page.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list/widgets/grocery_list.dart';
import '../models/grocery_item.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  List<GroceryItem> _groceryItemsList = [];
  late Future<List<GroceryItem>> _loadedItems;
  String? error;

  Future<List<GroceryItem>> _loadItems() async {
    final url = Uri.https(
        'shopping-list-b95ac-default-rtdb.europe-west1.firebasedatabase.app',
        'shopping-list.json');

    final response = await http.get(url);

    if (response.statusCode >= 400) {
      throw Exception('Failed to fetch data. Try again later');
    }

    if (response.body == "null") {
      return [];
    }

    final Map<String, dynamic> listData = jsonDecode(response.body);
    List<GroceryItem> loadedItems = [];
    for (final item in listData.entries) {
      final category = categories.entries
          .firstWhere(
              (element) => element.value.title == item.value['category'])
          .value;
      loadedItems.add(GroceryItem(
        id: item.key,
        name: item.value['name'],
        quantity: item.value['quantity'],
        category: category,
      ));
    }
    return loadedItems;
  }

  @override
  void initState() {
    super.initState();
    _loadedItems = _loadItems();
  }

  void _addNewItem() async {
    final addedItem = await Navigator.push<GroceryItem>(
      context,
      MaterialPageRoute(
        builder: (ctx) {
          return const NewItemPage();
        },
      ),
    );
    if (addedItem != null) {
      setState(() {
        _groceryItemsList.add(addedItem);
      });
    }
  }

  void _removeItem(GroceryItem item) async {
    final url = Uri.https(
        'shopping-list-b95ac-default-rtdb.europe-west1.firebasedatabase.app',
        'shopping-list/${item.id}.json');

    final response = await http.delete(url);
    if (response.statusCode < 400) {
      setState(() {
        _groceryItemsList.remove(item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(
            onPressed: _addNewItem,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: FutureBuilder( //! NOT WORKING
        future: _loadedItems,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data!.isNotEmpty) {
              return GroceryList(
                list: snapshot.data!,
                onRemoved: _removeItem,
              );
            } else {
              return Center(
                child: Text(
                  'Nothing here',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              );
            }
          }
          return const Center(
            child: Text('Something went wrong'),
          );
        },
      ),
    );
  }
}
