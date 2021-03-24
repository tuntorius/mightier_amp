import 'package:flutter/material.dart';
import 'models/setlist.dart';

class SetlistPage extends StatefulWidget {
  final Setlist setlist;

  SetlistPage({required this.setlist});
  @override
  _SetlistPageState createState() => _SetlistPageState();
}

class _SetlistPageState extends State<SetlistPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.setlist.name),
      ),
      body: ListTileTheme(
        iconColor: Colors.white,
        child: IndexedStack(
          index: widget.setlist.items.length > 0 ? 0 : 1,
          children: [
            ListView.builder(
                itemCount: widget.setlist.items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title:
                        Text(widget.setlist.items[index].trackReference!.name),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    onTap: () {},
                  );
                }),
            Center(
              child: Text(
                "No Tracks",
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }
}
