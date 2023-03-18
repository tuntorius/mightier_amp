import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/modules/cloud/cloudManager.dart';

import '../widgets/searchTextField.dart';

class ToneShareHome extends StatefulWidget {
  ToneShareHome({super.key});

  @override
  State<ToneShareHome> createState() => _ToneShareHomeState();
}

class _ToneShareHomeState extends State<ToneShareHome> {
  final TextEditingController searchCtrl = TextEditingController(text: "");

  List? data;
  @override
  void initState() {
    super.initState();
    //searchCtrl.addListener(_search);
  }

  void _search(String? query) async {
    if (query == null || query.isEmpty) return;

    final response = null;
    /*await Supabase.instance.client
        .from("presets")
        .select("*")
        .textSearch("name", query, type: TextSearchType.websearch);*/

    if (response != null) {
      // Process results
      //final results = response.data;
      // Do something with the results
      data = response;
    }
    setState(() {});
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    //searchCtrl.removeListener(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SearchTextField(controller: searchCtrl, onSearch: _search),
        Expanded(
            child: ListView.builder(
          itemCount: data?.length ?? 0,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(data![index]["name"]),
            );
          },
        )),
        ElevatedButton(
            child: const Text("Sign Out"),
            onPressed: CloudManager.instance.signOut)
      ],
    );
  }
}
