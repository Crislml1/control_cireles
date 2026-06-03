import 'app_secrets.dart';

class CloudinaryConfig {
  const CloudinaryConfig({
    required this.cloudName,
    required this.uploadPreset,
  });

  final String cloudName;
  final String uploadPreset;

  bool get isConfigured => cloudName.isNotEmpty && uploadPreset.isNotEmpty;

  // Lee desde app_secrets.dart (gitignoreado).
  // Edita ese archivo con tus credenciales reales de Cloudinary.
  static const current = CloudinaryConfig(
    cloudName: AppSecrets.cloudinaryCloudName,
    uploadPreset: AppSecrets.cloudinaryUploadPreset,
  );
}
