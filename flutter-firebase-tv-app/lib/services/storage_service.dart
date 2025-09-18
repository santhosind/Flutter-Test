import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  static StorageService get instance => _instance;
  StorageService._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload file from path
  Future<String> uploadFile({
    required String filePath,
    required String fileName,
    required String folder,
    Function(double)? onProgress,
  }) async {
    try {
      File file = File(filePath);
      Reference ref = _storage.ref().child('$folder/$fileName');
      
      UploadTask uploadTask = ref.putFile(file);
      
      // Listen to upload progress
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          double progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }
      
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('Error uploading file: $e');
      throw e;
    }
  }

  // Upload data (Uint8List)
  Future<String> uploadData({
    required Uint8List data,
    required String fileName,
    required String folder,
    String? contentType,
    Function(double)? onProgress,
  }) async {
    try {
      Reference ref = _storage.ref().child('$folder/$fileName');
      
      SettableMetadata metadata = SettableMetadata(
        contentType: contentType,
      );
      
      UploadTask uploadTask = ref.putData(data, metadata);
      
      // Listen to upload progress
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          double progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }
      
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('Error uploading data: $e');
      throw e;
    }
  }

  // Download file
  Future<Uint8List?> downloadFile(String url) async {
    try {
      Reference ref = _storage.refFromURL(url);
      Uint8List? data = await ref.getData();
      return data;
    } catch (e) {
      print('Error downloading file: $e');
      throw e;
    }
  }

  // Get download URL
  Future<String> getDownloadURL(String path) async {
    try {
      Reference ref = _storage.ref().child(path);
      String url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      print('Error getting download URL: $e');
      throw e;
    }
  }

  // Delete file
  Future<void> deleteFile(String path) async {
    try {
      Reference ref = _storage.ref().child(path);
      await ref.delete();
    } catch (e) {
      print('Error deleting file: $e');
      throw e;
    }
  }

  // List files in a directory
  Future<ListResult> listFiles(String path) async {
    try {
      Reference ref = _storage.ref().child(path);
      ListResult result = await ref.listAll();
      return result;
    } catch (e) {
      print('Error listing files: $e');
      throw e;
    }
  }

  // Get file metadata
  Future<FullMetadata> getMetadata(String path) async {
    try {
      Reference ref = _storage.ref().child(path);
      FullMetadata metadata = await ref.getMetadata();
      return metadata;
    } catch (e) {
      print('Error getting metadata: $e');
      throw e;
    }
  }

  // Update file metadata
  Future<FullMetadata> updateMetadata(
    String path,
    SettableMetadata metadata,
  ) async {
    try {
      Reference ref = _storage.ref().child(path);
      FullMetadata updatedMetadata = await ref.updateMetadata(metadata);
      return updatedMetadata;
    } catch (e) {
      print('Error updating metadata: $e');
      throw e;
    }
  }

  // Upload user profile image
  Future<String> uploadProfileImage({
    required String userId,
    required String filePath,
    Function(double)? onProgress,
  }) async {
    try {
      String fileName = 'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      return await uploadFile(
        filePath: filePath,
        fileName: fileName,
        folder: 'profiles',
        onProgress: onProgress,
      );
    } catch (e) {
      print('Error uploading profile image: $e');
      throw e;
    }
  }

  // Upload video thumbnail
  Future<String> uploadVideoThumbnail({
    required String videoId,
    required Uint8List thumbnailData,
    Function(double)? onProgress,
  }) async {
    try {
      String fileName = 'thumb_${videoId}.jpg';
      return await uploadData(
        data: thumbnailData,
        fileName: fileName,
        folder: 'thumbnails',
        contentType: 'image/jpeg',
        onProgress: onProgress,
      );
    } catch (e) {
      print('Error uploading video thumbnail: $e');
      throw e;
    }
  }

  // Upload video file
  Future<String> uploadVideo({
    required String videoId,
    required String filePath,
    Function(double)? onProgress,
  }) async {
    try {
      String fileName = 'video_${videoId}.mp4';
      return await uploadFile(
        filePath: filePath,
        fileName: fileName,
        folder: 'videos',
        onProgress: onProgress,
      );
    } catch (e) {
      print('Error uploading video: $e');
      throw e;
    }
  }

  // Batch upload multiple files
  Future<List<String>> batchUpload({
    required List<String> filePaths,
    required String folder,
    Function(int, double)? onProgress,
  }) async {
    List<String> downloadUrls = [];
    
    for (int i = 0; i < filePaths.length; i++) {
      String filePath = filePaths[i];
      String fileName = 'batch_${i}_${DateTime.now().millisecondsSinceEpoch}_${filePath.split('/').last}';
      
      String url = await uploadFile(
        filePath: filePath,
        fileName: fileName,
        folder: folder,
        onProgress: (progress) {
          if (onProgress != null) {
            onProgress(i, progress);
          }
        },
      );
      
      downloadUrls.add(url);
    }
    
    return downloadUrls;
  }

  // Clean up old files
  Future<void> cleanupOldFiles(String folder, {int daysOld = 30}) async {
    try {
      ListResult result = await listFiles(folder);
      DateTime cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
      
      for (Reference ref in result.items) {
        FullMetadata metadata = await ref.getMetadata();
        if (metadata.timeCreated != null && 
            metadata.timeCreated!.isBefore(cutoffDate)) {
          await ref.delete();
          print('Deleted old file: ${ref.fullPath}');
        }
      }
    } catch (e) {
      print('Error cleaning up old files: $e');
      throw e;
    }
  }
}