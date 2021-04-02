import 'package:flutter/material.dart';

class SearchTextField extends StatelessWidget {
  final TextEditingController controller;

  SearchTextField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: "Search",
        hintStyle: TextStyle(color: Colors.grey),
        prefixIcon: Icon(
          Icons.search,
          color: Colors.grey,
        ),
        suffixIcon: IconButton(
          onPressed: () {
            controller.clear();
            FocusScope.of(context).unfocus();
          },
          icon: Icon(Icons.clear),
          color: Colors.grey,
        ),
      ),
    );
  }
}
