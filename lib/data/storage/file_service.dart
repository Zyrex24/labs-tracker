import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../core/utils/result.dart';

class FileService {
  /// Get the app's documents directory
  Future<Directory> getAppDocumentsDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  /// Get the attachments directory
  Future<Directory> getAttachmentsDirectory() async {
    final appDir = await getAppDocumentsDirectory();
    final attachmentsDir = Directory(p.join(appDir.path, 'attachments'));
    if (!await attachmentsDir.exists()) {
      await attachmentsDir.create(recursive: true);
    }
    return attachmentsDir;
  }

  /// Copy a file to the attachments directory
  Future<Result<String>> copyFileToAttachments(String sourcePath, String newFileName) async {
    try {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        return const Failure('Source file does not exist');
      }

      final attachmentsDir = await getAttachmentsDirectory();
      final destinationPath = p.join(attachmentsDir.path, newFileName);
      final destinationFile = await sourceFile.copy(destinationPath);

      return Success(destinationFile.path);
    } catch (e) {
      return Failure('Failed to copy file: $e');
    }
  }

  /// Delete a file
  Future<Result<void>> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
      return const Success(null);
    } catch (e) {
      return Failure('Failed to delete file: $e');
    }
  }

  /// Check if file exists
  Future<bool> fileExists(String filePath) async {
    final file = File(filePath);
    return await file.exists();
  }

  /// Get file extension
  String getFileExtension(String filePath) {
    return p.extension(filePath);
  }

  /// Get file name from path
  String getFileName(String filePath) {
    return p.basename(filePath);
  }
}

