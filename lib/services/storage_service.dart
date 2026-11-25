import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';
import '../core/constants/app_constants.dart';
import '../core/exceptions/app_exception.dart';
import '../core/l10n/app_strings.dart';

class StorageService {
  final SupabaseClient? _supabaseClient;
  final ImagePicker _picker = ImagePicker();

  StorageService({SupabaseClient? client}) : _supabaseClient = client;

  /// Pick an image from gallery
  Future<XFile?> pickImageFromGallery() async {
    return await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1920,
      maxHeight: 1080,
    );
  }

  /// Pick multiple images
  Future<List<XFile>> pickMultiImages() async {
    return await _picker.pickMultiImage(
      imageQuality: 85,
      maxWidth: 1920,
      maxHeight: 1080,
    );
  }

  /// Upload an image to Supabase Storage with size and type verification
  Future<String> uploadPropertyImage({
    required XFile file,
    required String userId,
    required String propertyId,
  }) async {
    // 1. Check file size
    final length = await file.length();
    if (length > AppConstants.maxImageSizeInBytes) {
      throw AppException(tr.sys_image_too_large);
    }

    // 2. Check extension
    final name = file.name.toLowerCase();
    if (!name.endsWith('.jpg') &&
        !name.endsWith('.jpeg') &&
        !name.endsWith('.png') &&
        !name.endsWith('.webp')) {
      throw AppException(
        tr.sys_unsupported_image_format,
      );
    }

    if (AppConfig.isDemoMode || _supabaseClient == null) {
      // In demo mode without configured Supabase, return a high quality architectural placeholder
      return 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=1200&q=80';
    }

    try {
      final ext = name.split('.').last;
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${(length % 1000)}.$ext';
      final path = '$userId/$propertyId/$fileName';

      final Uint8List bytes = await file.readAsBytes();

      await _supabaseClient.storage
          .from(AppConstants.propertyImagesBucket)
          .uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(contentType: 'image/$ext', upsert: true),
          );

      final publicUrl = _supabaseClient.storage
          .from(AppConstants.propertyImagesBucket)
          .getPublicUrl(path);

      return publicUrl;
    } catch (e) {
      throw AppException(tr.sys_upload_failed(e.toString()));
    }
  }
}
