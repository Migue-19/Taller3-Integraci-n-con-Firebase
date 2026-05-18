import 'package:flutter/material.dart';
import '../models/universidad.dart';
import '../services/universidad_service.dart';
import 'formulario_universidad_screen.dart';

class ListadoUniversidadesScreen extends StatelessWidget {
  ListadoUniversidadesScreen({super.key});

  final UniversidadService _service = UniversidadService();

  Future<void> _confirmarEliminar(
      BuildContext context, Universidad u) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar universidad'),
        content: Text('¿Deseas eliminar "${u.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      await _service.eliminar(u.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Universidades'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const FormularioUniversidadScreen(),
          ),
        ),
        tooltip: 'Nueva universidad',
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Universidad>>(
        stream: _service.listar(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text('Error: ${snapshot.error}'),
                ],
              ),
            );
          }

          final lista = snapshot.data ?? [];

          if (lista.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.school_outlined,
                      size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No hay universidades registradas.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: lista.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, indent: 72),
            itemBuilder: (context, index) {
              final u = lista[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    u.nombre.isNotEmpty
                        ? u.nombre[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimaryContainer,
                    ),
                  ),
                ),
                title: Text(
                  u.nombre,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'NIT: ${u.nit}\n${u.direccion}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Editar',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FormularioUniversidadScreen(
                            universidad: u,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.red),
                      tooltip: 'Eliminar',
                      onPressed: () =>
                          _confirmarEliminar(context, u),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}