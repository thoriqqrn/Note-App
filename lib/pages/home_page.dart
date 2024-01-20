import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud_firebase/services/firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //firestore
  final FireStoreService fireStoreService = FireStoreService();

  //text controller
  final TextEditingController textController = TextEditingController();

  //dialog box
  void openNoteBox({String? docID}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Add Note",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: TextField(
          controller: textController,
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              //add a new note
              if (docID == null) {
                fireStoreService.addNote(textController.text);
              }
              //update an existing note
              else {
                fireStoreService.updateNote(docID, textController.text);
              }
              //clear text controlller
              textController.clear();
              //close box
              Navigator.pop(context);
            },
            style: ButtonStyle(
                backgroundColor: MaterialStateColor.resolveWith(
                    (states) => Colors.yellowAccent)),
            child: const Text(
              "Save",
              style:
                  TextStyle(fontWeight: FontWeight.w700, color: Colors.black),
            ),
          )
        ],
      ),
    );
  }

  void showDeleteConfirmationDialog(BuildContext context, String docID) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shadowColor: Colors.yellowAccent,
          title: const Text(
            'Delete Confirmation',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          content: const Text('Are you sure you want to delete this note?'),
          actions: [
            ElevatedButton(
              style: const ButtonStyle(
                  backgroundColor:
                      MaterialStatePropertyAll(Colors.yellowAccent)),
              onPressed: () => Navigator.of(context).pop(), // Close the dialog
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.black),
              ),
            ),
            ElevatedButton(
              style: const ButtonStyle(
                  backgroundColor:
                      MaterialStatePropertyAll(Colors.yellowAccent)),
              onPressed: () {
                // Call the delete function here
                fireStoreService.deleteNote(docID);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Notes',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.yellowAccent,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.yellowAccent,
        onPressed: openNoteBox,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: fireStoreService.getNotesStream(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List notesList = snapshot.data!.docs;

              //display as a list
              return ListView.builder(
                itemCount: notesList.length,
                itemBuilder: (context, index) {
                  //get individual
                  DocumentSnapshot document = notesList[index];
                  String docID = document.id;

                  // get each
                  Map<String, dynamic> data =
                      document.data() as Map<String, dynamic>;
                  String noteText = data['note'];

                  // display
                  return Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 15.0,
                        horizontal: 15), // Adjust margin as needed
                    decoration: const BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.yellow, // Shadow color
                          blurRadius: 10.0, // Adjust the blur radius as needed
                          spreadRadius:
                              1.0, // Adjust the spread radius as needed
                          offset: Offset(0, 0), // Offset of the shadow
                        ),
                      ],
                    ),
                    child: Card(
                      elevation:
                          0, // Set Card's elevation to 0 to avoid double shadow
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            12.0), // Set border radius for rounded corners
                      ),
                      child: ListTile(
                        title: Text(noteText),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Update button
                            IconButton(
                              icon: const Icon(
                                Icons.settings,
                                color: Colors.black,
                              ),
                              onPressed: () => openNoteBox(docID: docID),
                            ),
                            // Delete button
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.black,
                              ),
                              onPressed: () =>
                                  showDeleteConfirmationDialog(context, docID),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            } else {
              return const Text("No Notes...");
            }
          }),
    );
  }
}
