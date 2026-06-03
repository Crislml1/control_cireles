import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class InventorySearchField extends StatelessWidget {
  const InventorySearchField({
    super.key,
    required this.value,
    required this.onChanged,
    required this.onClear,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Buscar cliente, producto, pantone o ubicacion',
        prefixIcon: const Icon(LucideIcons.search),
        suffixIcon: value.isEmpty
            ? null
            : IconButton(
                tooltip: 'Limpiar busqueda',
                onPressed: onClear,
                icon: const Icon(LucideIcons.x),
              ),
      ),
    );
  }
}
