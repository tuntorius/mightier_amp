import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  final TextEditingController textEditingController;
  final Function onCloseSearch;

  const SearchField(
      {super.key,
      required this.onCloseSearch,
      required this.textEditingController});

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: TextField(
      controller: textEditingController,
      autofocus: true,
      decoration: InputDecoration(
        suffixIconColor: Colors.white,
        focusColor: Colors.white,
        //focusedBorder: InputBorder.none,
        prefixIcon: const Icon(Icons.search),
        border: InputBorder.none,
        suffixIcon: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            textEditingController.clear();
            onCloseSearch();
          },
        ),
      ),
    ));
  }
}
