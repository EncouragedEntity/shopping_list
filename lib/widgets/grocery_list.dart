import 'package:flutter/material.dart';

import '../models/grocery_item.dart';
import 'grocery_list_item.dart';

class GroceryList extends StatelessWidget {
  const GroceryList({
    super.key,
    required this.list,
    required this.onRemoved,
  });

  final List<GroceryItem> list;
  final void Function(GroceryItem item) onRemoved;
  @override
  Widget build(BuildContext context) {
    return list.isNotEmpty
        ? ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              return Dismissible(
                key: ValueKey(list[index].id),
                child: ListItem(item: list[index]),
                onDismissed: (direction) {
                  onRemoved(list[index]);
                },
              );
            },
          )
        : Center(
            child: Text(
              'Nothing here',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          );
  }
}
