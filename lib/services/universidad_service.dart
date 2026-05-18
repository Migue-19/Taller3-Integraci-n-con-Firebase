import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/universidad.dart';

class UniversidadService {
  final CollectionReference<Universidad> _col =
      FirebaseFirestore.instance
          .collection('universidades')
          .withConverter<Universidad>(
            fromFirestore: Universidad.fromFirestore,
            toFirestore: (universidad, _) => universidad.toFirestore(),
          );

  // CREATE
  Future<void> crear(Universidad universidad) async {
    await _col.add(universidad);
  }

  // READ — stream en tiempo real
  Stream<List<Universidad>> listar() {
    return _col.orderBy('nombre').snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => doc.data()).toList(),
    );
  }

  // UPDATE
  Future<void> actualizar(Universidad universidad) async {
    await _col.doc(universidad.id).set(universidad);
  }

  // DELETE
  Future<void> eliminar(String id) async {
    await _col.doc(id).delete();
  }
}