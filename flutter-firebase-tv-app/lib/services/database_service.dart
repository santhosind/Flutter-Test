import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static DatabaseService get instance => _instance;
  DatabaseService._internal();

  // Realtime Database instance
  final FirebaseDatabase _realtimeDb = FirebaseDatabase.instance;
  
  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // REALTIME DATABASE OPERATIONS

  // Write data to Realtime Database
  Future<void> writeRealtimeData(String path, Map<String, dynamic> data) async {
    try {
      await _realtimeDb.ref(path).set(data);
    } catch (e) {
      print('Error writing to Realtime Database: $e');
      throw e;
    }
  }

  // Update data in Realtime Database
  Future<void> updateRealtimeData(String path, Map<String, dynamic> updates) async {
    try {
      await _realtimeDb.ref(path).update(updates);
    } catch (e) {
      print('Error updating Realtime Database: $e');
      throw e;
    }
  }

  // Read data from Realtime Database
  Future<DataSnapshot> readRealtimeData(String path) async {
    try {
      return await _realtimeDb.ref(path).get();
    } catch (e) {
      print('Error reading from Realtime Database: $e');
      throw e;
    }
  }

  // Listen to Realtime Database changes
  Stream<DatabaseEvent> listenToRealtimeData(String path) {
    return _realtimeDb.ref(path).onValue;
  }

  // Delete from Realtime Database
  Future<void> deleteRealtimeData(String path) async {
    try {
      await _realtimeDb.ref(path).remove();
    } catch (e) {
      print('Error deleting from Realtime Database: $e');
      throw e;
    }
  }

  // CLOUD FIRESTORE OPERATIONS

  // Create document in Firestore
  Future<DocumentReference> createDocument(
    String collection,
    Map<String, dynamic> data,
  ) async {
    try {
      return await _firestore.collection(collection).add(data);
    } catch (e) {
      print('Error creating document in Firestore: $e');
      throw e;
    }
  }

  // Set document in Firestore
  Future<void> setDocument(
    String collection,
    String docId,
    Map<String, dynamic> data, {
    bool merge = false,
  }) async {
    try {
      await _firestore
          .collection(collection)
          .doc(docId)
          .set(data, SetOptions(merge: merge));
    } catch (e) {
      print('Error setting document in Firestore: $e');
      throw e;
    }
  }

  // Update document in Firestore
  Future<void> updateDocument(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection(collection).doc(docId).update(data);
    } catch (e) {
      print('Error updating document in Firestore: $e');
      throw e;
    }
  }

  // Get document from Firestore
  Future<DocumentSnapshot> getDocument(String collection, String docId) async {
    try {
      return await _firestore.collection(collection).doc(docId).get();
    } catch (e) {
      print('Error getting document from Firestore: $e');
      throw e;
    }
  }

  // Get collection from Firestore
  Future<QuerySnapshot> getCollection(String collection) async {
    try {
      return await _firestore.collection(collection).get();
    } catch (e) {
      print('Error getting collection from Firestore: $e');
      throw e;
    }
  }

  // Listen to document changes in Firestore
  Stream<DocumentSnapshot> listenToDocument(String collection, String docId) {
    return _firestore.collection(collection).doc(docId).snapshots();
  }

  // Listen to collection changes in Firestore
  Stream<QuerySnapshot> listenToCollection(String collection) {
    return _firestore.collection(collection).snapshots();
  }

  // Query collection in Firestore
  Future<QuerySnapshot> queryCollection(
    String collection, {
    String? whereField,
    dynamic isEqualTo,
    dynamic isGreaterThan,
    dynamic isLessThan,
    List<dynamic>? whereIn,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    try {
      Query query = _firestore.collection(collection);

      if (whereField != null) {
        if (isEqualTo != null) {
          query = query.where(whereField, isEqualTo: isEqualTo);
        }
        if (isGreaterThan != null) {
          query = query.where(whereField, isGreaterThan: isGreaterThan);
        }
        if (isLessThan != null) {
          query = query.where(whereField, isLessThan: isLessThan);
        }
        if (whereIn != null) {
          query = query.where(whereField, whereIn: whereIn);
        }
      }

      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      return await query.get();
    } catch (e) {
      print('Error querying collection in Firestore: $e');
      throw e;
    }
  }

  // Delete document from Firestore
  Future<void> deleteDocument(String collection, String docId) async {
    try {
      await _firestore.collection(collection).doc(docId).delete();
    } catch (e) {
      print('Error deleting document from Firestore: $e');
      throw e;
    }
  }

  // Batch operations in Firestore
  WriteBatch batch() {
    return _firestore.batch();
  }

  Future<void> commitBatch(WriteBatch batch) async {
    try {
      await batch.commit();
    } catch (e) {
      print('Error committing batch in Firestore: $e');
      throw e;
    }
  }

  // Transaction operations in Firestore
  Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) updateFunction,
  ) async {
    try {
      return await _firestore.runTransaction(updateFunction);
    } catch (e) {
      print('Error running transaction in Firestore: $e');
      throw e;
    }
  }

  // User-specific data operations
  Future<void> saveUserData(String userId, Map<String, dynamic> data) async {
    try {
      // Save to both Realtime Database and Firestore
      await writeRealtimeData('users/$userId', data);
      await setDocument('users', userId, data, merge: true);
    } catch (e) {
      print('Error saving user data: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      DocumentSnapshot doc = await getDocument('users', userId);
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      throw e;
    }
  }

  // TV-specific data operations
  Future<void> saveViewingHistory(String userId, Map<String, dynamic> content) async {
    try {
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      await setDocument('viewing_history', '${userId}_$timestamp', {
        'userId': userId,
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving viewing history: $e');
      throw e;
    }
  }

  Future<List<Map<String, dynamic>>> getViewingHistory(String userId, {int limit = 10}) async {
    try {
      QuerySnapshot snapshot = await queryCollection(
        'viewing_history',
        whereField: 'userId',
        isEqualTo: userId,
        orderBy: 'timestamp',
        descending: true,
        limit: limit,
      );
      
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error getting viewing history: $e');
      throw e;
    }
  }
}