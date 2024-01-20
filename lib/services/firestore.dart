import 'package:cloud_firestore/cloud_firestore.dart';

class FireStoreService {
  //get collection
  final CollectionReference notes =
      FirebaseFirestore.instance.collection('notes');
  // create
  Future<void> addNote(String note) {
    return notes.add({
      'note': note,
      'timestamp': Timestamp.now(),
    });
  }

  // read
  Stream<QuerySnapshot> getNotesStream() {
    final notesStream =
        notes.orderBy('timestamp', descending: true).snapshots();

    return notesStream;
  }

  // update
  Future<void> updateNote(String docID, String newNote) {
    return notes.doc(docID).update({
      'note': newNote,
      'timestamp': Timestamp.now(),
    });
  }

  // delete
  Future<void> deleteNote(String docId) {
    return notes.doc(docId).delete();
  }
}
