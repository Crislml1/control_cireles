import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/cloudinary_url.dart';
import '../../domain/inventory_item.dart';
import '../../view_model/inventory_form_view_model.dart';
import '../widgets/inventory_photo.dart';

class InventoryFormPage extends ConsumerStatefulWidget {
  const InventoryFormPage({super.key, this.item});

  final InventoryItem? item;

  @override
  ConsumerState<InventoryFormPage> createState() => _InventoryFormPageState();
}

class _InventoryFormPageState extends ConsumerState<InventoryFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _clienteController = TextEditingController();
  final _productoController = TextEditingController();
  final _coloresController = TextEditingController();
  final _pantoneController = TextEditingController();
  final _ubicacionController = TextEditingController();
  final _imagePicker = ImagePicker();

  Uint8List? _newPhotoBytes;
  String? _newPhotoFileName;
  var _removePhoto = false;

  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    if (item != null) {
      _clienteController.text = item.cliente;
      _productoController.text = item.producto;
      _coloresController.text = item.colores ?? '';
      _pantoneController.text = item.pantone ?? '';
      _ubicacionController.text = item.ubicacion;
    }
  }

  @override
  void dispose() {
    _clienteController.dispose();
    _productoController.dispose();
    _coloresController.dispose();
    _pantoneController.dispose();
    _ubicacionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(inventoryFormViewModelProvider, (previous, next) {
      final error = next.error;
      if (error != null && mounted) {
        final message = error is AppException
            ? error.message
            : 'No se pudo guardar el cirel. Intenta nuevamente.';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 6),
          ),
        );
      }

      if (previous?.isLoading == true && next.hasValue && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Cirel actualizado.' : 'Cirel creado.'),
          ),
        );
      }
    });

    final isLoading = ref.watch(inventoryFormViewModelProvider).isLoading;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar cirel' : 'Nuevo cirel'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
            children: [
              _SectionLabel(label: 'Foto (opcional)', colorScheme: colorScheme),
              const SizedBox(height: 8),
              _PhotoSection(
                existingPhotoUrl: _resolveExistingPhotoUrl(),
                newPhotoBytes: _newPhotoBytes,
                isLoading: isLoading,
                onCamera: () => _pickImage(ImageSource.camera),
                onGallery: () => _pickImage(ImageSource.gallery),
                onRemove: _removeSelectedPhoto,
              ),
              const SizedBox(height: 28),
              _SectionLabel(
                  label: 'Datos del cirel', colorScheme: colorScheme),
              const SizedBox(height: 12),
              TextFormField(
                controller: _clienteController,
                enabled: !isLoading,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Cliente *',
                  prefixIcon: Icon(LucideIcons.user),
                ),
                validator: _required('Ingresa el cliente.'),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _productoController,
                enabled: !isLoading,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Producto *',
                  prefixIcon: Icon(LucideIcons.shapes),
                ),
                validator: _required('Ingresa el producto.'),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _coloresController,
                enabled: !isLoading,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Colores',
                  prefixIcon: Icon(LucideIcons.palette),
                  hintText: 'ej: 4',
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _pantoneController,
                enabled: !isLoading,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Pantone',
                  prefixIcon: Icon(LucideIcons.palette),
                  hintText: 'ej: PMS 286 C',
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _ubicacionController,
                enabled: !isLoading,
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Ubicacion *',
                  prefixIcon: Icon(LucideIcons.package),
                  hintText: 'ej: Estante A - Caja 3',
                ),
                validator: _required('Ingresa la ubicacion.'),
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: isLoading ? null : _submit,
                icon: isLoading
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(LucideIcons.save),
                label: Text(isLoading
                    ? 'Guardando...'
                    : _isEditing
                        ? 'Guardar cambios'
                        : 'Crear cirel'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _resolveExistingPhotoUrl() {
    if (_removePhoto) return null;
    final url = widget.item?.photoUrl;
    return url == null ? null : cloudinaryDetailUrl(url);
  }

  FormFieldValidator<String> _required(String message) {
    return (value) => (value ?? '').trim().isEmpty ? message : null;
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _imagePicker.pickImage(
      source: source,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    setState(() {
      _newPhotoBytes = bytes;
      _newPhotoFileName = picked.name;
      _removePhoto = false;
    });
  }

  void _removeSelectedPhoto() {
    setState(() {
      _newPhotoBytes = null;
      _newPhotoFileName = null;
      _removePhoto = true;
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final item = widget.item;
    ref.read(inventoryFormViewModelProvider.notifier).save(
          InventoryFormInput(
            id: item?.id,
            cliente: _clienteController.text,
            producto: _productoController.text,
            colores: _blankToNull(_coloresController.text),
            pantone: _blankToNull(_pantoneController.text),
            ubicacion: _ubicacionController.text,
            existingPhotoUrl: item?.photoUrl,
            existingPhotoPublicId: item?.photoPublicId,
            newPhotoBytes: _newPhotoBytes,
            newPhotoFileName: _newPhotoFileName,
            removePhoto: _removePhoto,
          ),
        );
  }

  String? _blankToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.colorScheme});

  final String label;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
    );
  }
}

class _PhotoSection extends StatelessWidget {
  const _PhotoSection({
    required this.existingPhotoUrl,
    required this.newPhotoBytes,
    required this.isLoading,
    required this.onCamera,
    required this.onGallery,
    required this.onRemove,
  });

  final String? existingPhotoUrl;
  final Uint8List? newPhotoBytes;
  final bool isLoading;
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasPhoto = newPhotoBytes != null || existingPhotoUrl != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: _PhotoPreview(
            existingPhotoUrl: existingPhotoUrl,
            newPhotoBytes: newPhotoBytes,
            colorScheme: colorScheme,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isLoading ? null : onCamera,
                icon: const Icon(LucideIcons.camera, size: 18),
                label: const Text('Camara'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isLoading ? null : onGallery,
                icon: const Icon(LucideIcons.images, size: 18),
                label: const Text('Galeria'),
              ),
            ),
            if (hasPhoto) ...[
              const SizedBox(width: 8),
              IconButton.outlined(
                tooltip: 'Quitar foto',
                onPressed: isLoading ? null : onRemove,
                icon: Icon(
                  LucideIcons.trash2,
                  color: colorScheme.error,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'La foto se comprime automaticamente antes de subir.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

class _PhotoPreview extends StatelessWidget {
  const _PhotoPreview({
    required this.existingPhotoUrl,
    required this.newPhotoBytes,
    required this.colorScheme,
  });

  final String? existingPhotoUrl;
  final Uint8List? newPhotoBytes;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    if (newPhotoBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(
          newPhotoBytes!,
          width: 200,
          height: 200,
          fit: BoxFit.cover,
        ),
      );
    }

    if (existingPhotoUrl != null) {
      return InventoryPhoto(
        url: existingPhotoUrl,
        size: 200,
        borderRadius: 12,
      );
    }

    return Container(
      width: 200,
      height: 120,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.imagePlus,
            size: 36,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 6),
          Text(
            'Sin foto',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
