import 'package:flutter/material.dart';
import '../models/universidad.dart';
import '../services/universidad_service.dart';

class FormularioUniversidadScreen extends StatefulWidget {
  final Universidad? universidad;

  const FormularioUniversidadScreen({super.key, this.universidad});

  @override
  State<FormularioUniversidadScreen> createState() =>
      _FormularioUniversidadScreenState();
}

class _FormularioUniversidadScreenState
    extends State<FormularioUniversidadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = UniversidadService();

  late final TextEditingController _nitCtrl;
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _direccionCtrl;
  late final TextEditingController _telefonoCtrl;
  late final TextEditingController _webCtrl;

  bool _loading = false;
  bool get _esEdicion => widget.universidad != null;

  @override
  void initState() {
    super.initState();
    final u = widget.universidad;
    _nitCtrl      = TextEditingController(text: u?.nit ?? '');
    _nombreCtrl   = TextEditingController(text: u?.nombre ?? '');
    _direccionCtrl = TextEditingController(text: u?.direccion ?? '');
    _telefonoCtrl = TextEditingController(text: u?.telefono ?? '');
    _webCtrl      = TextEditingController(text: u?.paginaWeb ?? '');
  }

  @override
  void dispose() {
    _nitCtrl.dispose();
    _nombreCtrl.dispose();
    _direccionCtrl.dispose();
    _telefonoCtrl.dispose();
    _webCtrl.dispose();
    super.dispose();
  }

  String? _validarRequerido(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es requerido';
    }
    return null;
  }

  String? _validarUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es requerido';
    }
    final uri = Uri.tryParse(value.trim());
    if (uri == null || !uri.hasScheme ||
        (!uri.scheme.startsWith('http'))) {
      return 'Ingresa una URL válida (http:// o https://)';
    }
    if (!uri.hasAuthority || uri.host.isEmpty) {
      return 'La URL no tiene un dominio válido';
    }
    return null;
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final universidad = Universidad(
        id: widget.universidad?.id,
        nit: _nitCtrl.text.trim(),
        nombre: _nombreCtrl.text.trim(),
        direccion: _direccionCtrl.text.trim(),
        telefono: _telefonoCtrl.text.trim(),
        paginaWeb: _webCtrl.text.trim(),
      );

      if (_esEdicion) {
        await _service.actualizar(universidad);
      } else {
        await _service.crear(universidad);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _esEdicion
                  ? 'Universidad actualizada correctamente'
                  : 'Universidad creada correctamente',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar Universidad' : 'Nueva Universidad'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildCampo(
              controller: _nitCtrl,
              label: 'NIT',
              hint: 'Ej: 890.123.456-7',
              icon: Icons.badge_outlined,
              validator: _validarRequerido,
            ),
            _buildCampo(
              controller: _nombreCtrl,
              label: 'Nombre',
              hint: 'Ej: Universidad del Valle',
              icon: Icons.school_outlined,
              validator: _validarRequerido,
            ),
            _buildCampo(
              controller: _direccionCtrl,
              label: 'Dirección',
              hint: 'Ej: Cra 27A #48-144, Tuluá',
              icon: Icons.location_on_outlined,
              validator: _validarRequerido,
              maxLines: 2,
            ),
            _buildCampo(
              controller: _telefonoCtrl,
              label: 'Teléfono',
              hint: 'Ej: +57 602 2242202',
              icon: Icons.phone_outlined,
              validator: _validarRequerido,
              tipo: TextInputType.phone,
            ),
            _buildCampo(
              controller: _webCtrl,
              label: 'Página web',
              hint: 'Ej: https://www.uceva.edu.co',
              icon: Icons.language_outlined,
              validator: _validarUrl,
              tipo: TextInputType.url,
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _guardar,
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(_esEdicion ? Icons.save_outlined : Icons.add),
                label: Text(
                  _esEdicion ? 'Actualizar' : 'Guardar',
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.primary,
                  foregroundColor:
                      Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampo({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType tipo = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: tipo,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
          filled: true,
        ),
        validator: validator,
      ),
    );
  }
}