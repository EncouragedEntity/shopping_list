import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/category.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list/models/grocery_item.dart';

class NewItemPage extends StatefulWidget {
  const NewItemPage({super.key});

  @override
  State<NewItemPage> createState() => _NewItemPageState();
}

class _NewItemPageState extends State<NewItemPage> {
  final _formKey = GlobalKey<FormState>();
  String _enteredName = '';
  int _enteredQuantity = 1;
  Category _enteredCategory = categories[Categories.other]!;
  bool isSending = false;

  void _submitItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        isSending = true;
      });

      final url = Uri.https(
          'shopping-list-b95ac-default-rtdb.europe-west1.firebasedatabase.app',
          'shopping-list.json');
      final response = await http.post(
        url,
        headers: {
          'Content-type': 'application/json',
        },
        body: jsonEncode({
          'name': _enteredName,
          'quantity': _enteredQuantity,
          'category': _enteredCategory.title,
        }),
      );
      final Map<String, dynamic> resData = json.decode(response.body);
      if (!context.mounted) {
        return;
      }
      Navigator.of(context).pop(GroceryItem(
        id: resData['name'],
        name: _enteredName,
        quantity: _enteredQuantity,
        category: _enteredCategory,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: const InputDecoration(
                  label: Text('Name'),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().isEmpty ||
                      value.trim().length > 50) {
                    return 'Must be between 1 and 50 characters long!';
                  }

                  return null;
                },
                onSaved: (newValue) {
                  _enteredName = newValue!;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        label: Text('Quantity'),
                      ),
                      initialValue: '1',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! < 1) {
                          return 'Must be a positive number!';
                        }
                        return null;
                      },
                      onSaved: (newValue) {
                        _enteredQuantity = int.parse(newValue!);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField(
                      items: [
                        ...categories.entries.map(
                          (item) => DropdownMenuItem(
                            value: item.value,
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: item.value.color,
                                ),
                                const SizedBox(
                                  width: 6,
                                ),
                                Text(item.value.title),
                              ],
                            ),
                          ),
                        ),
                      ],
                      validator: (value) {
                        if (value == null) {
                          return 'Select category';
                        }
                        return null;
                      },
                      onChanged: (item) {},
                      onSaved: (newValue) {
                        _enteredCategory = newValue!;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: isSending
                        ? null
                        : () {
                            _formKey.currentState!.reset();
                          },
                    child: const Text('Reset'),
                  ),
                  ElevatedButton(
                    onPressed: isSending ? null : _submitItem,
                    child: isSending
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(),
                          )
                        : const Text('Submit'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
