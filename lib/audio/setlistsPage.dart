import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/popups/alertDialogs.dart';
import 'package:mighty_plug_manager/audio/trackdata/trackData.dart';

import 'setlistPage.dart';

class Setlists extends StatefulWidget {
  @override
  _SetlistsState createState() => _SetlistsState();
}

class _SetlistsState extends State<Setlists> {
  @override
  void initState() {
    super.initState();
  }

  void createSetlist() {
    AlertDialogs.showInputDialog(context,
        title: "New Setlist",
        description: "Create new setlist",
        cancelButton: "Cancel",
        confirmButton: "Create",
        value: "New Setlist",
        //TODO: validation for duplicate setlist
        confirmColor: Colors.blue, onConfirm: (name) {
      TrackData().addSetlist(name);

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    var setlists = TrackData().setlists;
    if (!kDebugMode) return Text("TODO");
    return ListTileTheme(
      iconColor: Colors.white,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          ListView.builder(
              itemCount: setlists.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(setlists[index].name),
                  trailing: Icon(Icons.keyboard_arrow_right),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => SetlistPage(
                              setlist: setlists[index],
                            )));
                  },
                );
              }),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: FloatingActionButton(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              onPressed: () {
                createSetlist();
              },
              child: Icon(
                Icons.add,
                size: 28,
                //style: TextStyle(fontSize: 28),
              ),
            ),
          )
        ],
      ),
    );
  }
}
