import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'display_single_entry.dart';
import '../widgets/loading.dart';


// Generates listview of all Wasteagram entries and loads 'Loading' page
// if async functions have not yet received data from Firebase database.
class AppPosts extends StatefulWidget {

  @override
  AppPostsState createState() => new AppPostsState();
}

class AppPostsState extends State<AppPosts> {

  @override 
  // Rebuild widgets when changes made/ new journal entry added
  void didUpdateWidget(AppPosts oldWidget) {
    super.didUpdateWidget(oldWidget);
  }
  
  Widget build(BuildContext context){
    return     
      // StreamBuilder continuously requests updates from Firebase database for any changes/ new entries and
      // will include new data in snapshot
      StreamBuilder(
        stream: FirebaseFirestore.instance.collection('posts').orderBy('date', descending: true).snapshots(),
        builder: (BuildContext context,  AsyncSnapshot<QuerySnapshot> snapshot) {
        //Checks to see if snapshot data has been received or if there is no data yet in database
        if (snapshot.hasData && snapshot.data.docs != null && snapshot.data.docs.length > 0){
          // Calculates total sum of amounts of entries in database. 
          // Reference source: I used the example code solutio that was discussed in this post: https://stackoverflow.com/questions/58165991/flutter-firestore-calculations-not-working and modified it for my program
          final sum = snapshot.data.docs.fold(0, (total, index) => total + int.parse(index['quantity']));
          
          // Returns listView widget of all entries
          return new Scaffold(
            appBar: AppBar(
              title: Text('Wasteagram - Total: ' + sum.toString()),
              centerTitle: true,),
            
              body: ListView.builder(
              itemCount: snapshot.data.docs.length,
              itemBuilder: (BuildContext context, int index) {
              var appPost = snapshot.data.docs[index];
              return Semantics(
                  label: 'This clickable widget is used to allow the user to display a detailed entry page of this post.',
                  button: true,
                  enabled: true,
                  onTapHint: 'Clicking a tile will open a new page that displays a detailed entry of this Wasteagram post.',
                  child: ListTile(
                  // Formats date to weekday month day year
                  title: Text(DateFormat.yMMMMEEEEd().format(appPost['date'].toDate()) ),
                  // Displays entry's amount
                  trailing: Text(appPost['quantity'].toString()),
                  
                  // If user clicks on entry, widget will display detailed entry
                  onTap: () {
                    FirebaseAnalytics().logEvent(name: 'User_Tapped_for_Detailed_Post', parameters: null);
                    Navigator.push(context, MaterialPageRoute(builder: (context) {                
                        return DetailedEntries(entryData: appPost);},
                        settings: RouteSettings(name: 'DetailedEntryPage') 
                      ),
                  );},
                ),
              );
            }
          ),);
        }
        // If there are no entries in Cloud Firestore, then loading page is displayed
        // until data has been added and can be displayed
        else{
          return loading(context);}
      },
    );
  }
}
