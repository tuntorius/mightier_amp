import 'package:flutter/material.dart';

class Setlists extends StatefulWidget {
  @override
  _SetlistsState createState() => _SetlistsState();
}

class _SetlistsState extends State<Setlists> {
  List<String> setlists = [];
  @override
  void initState() {
    super.initState();
    setlists.add("All Tracks");
  }

  @override
  Widget build(BuildContext context) {
    return ListTileTheme(
      iconColor: Colors.white,
      child: ListView.builder(
          itemCount: 1,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(setlists[index]),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () {},
            );
          }),
    );
  }
}
