import 'package:cloud_firestore/cloud_firestore.dart';

class Universidad {
  final String? id;
  final String nit;
  final String nombre;
  final String direccion;
  final String telefono;
  final String paginaWeb;

  Universidad({
    this.id,
    required this.nit,
    required this.nombre,
    required this.direccion,
    required this.telefono,
    required this.paginaWeb,
  });

  factory Universidad.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    SnapshotOptions? options,
  ) {
    final data = doc.data()!;
    return Universidad(
      id: doc.id,
      nit: data['nit'] ?? '',
      nombre: data['nombre'] ?? '',
      direccion: data['direccion'] ?? '',
      telefono: data['telefono'] ?? '',
      paginaWeb: data['pagina_web'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => {
    'nit': nit,
    'nombre': nombre,
    'direccion': direccion,
    'telefono': telefono,
    'pagina_web': paginaWeb,
  };
}