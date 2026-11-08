import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../../app/di/providers.dart';
import '../../../app/theme/brand.dart';
import '../../../app/ui/components.dart';
import '../../assistant/presentation/tr.dart';
import '../domain/need_extras.dart';

/// Pide una foto (cámara o galería), la reduce y la copia a la carpeta de la app.
/// Devuelve la ruta guardada, o `null` si se canceló o falló (ya avisa con un mensaje).
Future<String?> pickPhotoToAppFolder(
  BuildContext context,
  ImageSource source,
  String prefix,
) async {
  try {
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 80,
    );
    if (picked == null) return null;
    final dir = await getApplicationDocumentsDirectory();
    final dest = File(
      '${dir.path}/${prefix}_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await File(picked.path).copy(dest.path);
    return dest.path;
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr(
              context,
              'No pudimos usar esa foto. Prueba con otra.',
              'We could not use that photo. Try another one.',
            ),
          ),
        ),
      );
    }
    return null;
  }
}

/// Elegir de dónde viene la foto. Devuelve `null` si se cierra.
Future<ImageSource?> askPhotoSource(BuildContext context) =>
    showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded),
              title: Text(tr(ctx, 'Tomar una foto', 'Take a photo')),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: Text(tr(ctx, 'Elegir de la galería', 'Choose from gallery')),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

/// Campos opcionales del formulario: más detalle y una foto.
class NeedExtrasEditor extends StatelessWidget {
  const NeedExtrasEditor({
    super.key,
    required this.detail,
    required this.imagePath,
    required this.onImageChanged,
    required this.onTextChanged,
  });

  final TextEditingController detail;
  final String? imagePath;
  final ValueChanged<String?> onImageChanged;
  final VoidCallback onTextChanged;

  Future<void> _pick(BuildContext context) async {
    final source = await askPhotoSource(context);
    if (source == null || !context.mounted) return;
    final path = await pickPhotoToAppFolder(context, source, 'foto_pedido');
    if (path != null) onImageChanged(path);
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextField(
        controller: detail,
        minLines: 2,
        maxLines: 5,
        maxLength: NeedExtras.maxDetailLength,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: tr(
            context,
            'Más detalle (opcional)',
            'More detail (optional)',
          ),
          helperText: tr(
            context,
            'Cuenta el problema, el horario o lo que ofreces a cambio.',
            'Describe the problem, the schedule or what you offer in return.',
          ),
        ),
        onChanged: (_) => onTextChanged(),
      ),
      const SizedBox(height: 8),
      if (imagePath != null)
        Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                File(imagePath!),
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox(
                  height: 160,
                  child: Center(child: Icon(Icons.broken_image_outlined)),
                ),
              ),
            ),
            IconButton.filledTonal(
              tooltip: tr(context, 'Quitar foto', 'Remove photo'),
              onPressed: () => onImageChanged(null),
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        )
      else
        OutlinedButton.icon(
          onPressed: () => _pick(context),
          icon: const Icon(Icons.add_a_photo_rounded),
          label: Text(
            tr(context, 'Agregar una foto', 'Add a photo'),
          ),
        ),
    ],
  );
}

/// Muestra el detalle y la foto de un pedido (si los tiene).
class NeedExtrasView extends ConsumerWidget {
  const NeedExtrasView({super.key, required this.needId});

  final String needId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final extras = ref.watch(needExtrasProvider(needId)).value;
    if (extras == null || extras.isEmpty) return const SizedBox.shrink();
    final path = extras.imagePath;
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: BvPanel(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr(context, 'Más a detalle', 'More detail'),
              style: context.tt.titleSmall,
            ),
            if (extras.detail.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(extras.detail, style: context.tt.bodyMedium),
            ],
            if (path != null) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => showDialog<void>(
                  context: context,
                  builder: (_) => Dialog(
                    child: InteractiveViewer(child: Image.file(File(path))),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    File(path),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox(
                      height: 80,
                      child: Center(child: Icon(Icons.broken_image_outlined)),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
