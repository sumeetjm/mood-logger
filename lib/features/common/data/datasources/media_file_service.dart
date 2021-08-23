import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mood_manager/core/constants/app_constants.dart';
import 'package:mood_manager/features/common/domain/entities/base_states.dart';
import 'package:mood_manager/features/common/domain/entities/media_collection_mapping.dart';
import 'package:mood_manager/features/memory/presentation/pages/media_collection_grid_page.dart';
import 'package:uuid/uuid.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:image/image.dart' as img;

import '../../../../home.dart';

class MediaFileService {
  final Uuid uuid;
  final ImagePicker imagePicker;
  final Directory tempDirectory;
  final FlutterVideoInfo videoInfo;

  MediaFileService(
      {this.uuid, this.imagePicker, this.tempDirectory, this.videoInfo});

  Future<List<File>> pickFiles({FileType type}) async {
    List<File> files = await FilePicker.getMultiFile(type: type);
    return handleFuture<List<File>>(() async {
      if (type == FileType.video) {
        List<File> validFiles = [];
        for (final file in (files ?? [])) {
          final fileInfo = await videoInfo.getVideoInfo(file.path);
          if (fileInfo.duration <=
              AppConstants.videoDurationAllowed.inMilliseconds) {
            validFiles.add(file);
          }
        }
        if ((files ?? []).length != validFiles.length) {
          Fluttertoast.showToast(
              gravity: ToastGravity.TOP,
              msg:
                  'One or more videos have duration more than ${AppConstants.videoDurationAllowed.inSeconds > 60 ? AppConstants.videoDurationAllowed.inMinutes.toString() + ' minutes' : AppConstants.videoDurationAllowed.inSeconds.toString() + ' seconds'}',
              backgroundColor: Colors.red);
        }
        files = validFiles;
      }
      List<File> newFiles = (files ?? []).map((e) => copyAndReturn(e)).toList();
      return newFiles;
    });
  }

  Future<File> pickFile({FileType type}) async {
    final file = await FilePicker.getFile(type: type);
    return handleFuture<File>(() => copyAndReturn(file));
  }

  File copyAndReturn(File file) {
    if (file == null) {
      return null;
    }
    File newFile = file.copySync(tempDirectory.path +
        "/" +
        uuid.v1() +
        file.path.substring(file.path.lastIndexOf(".")));
    return newFile;
  }

  Future<List<File>> pickFilesFromAlbum(
      {String mediaType, BuildContext context}) async {
    final List<MediaCollectionMapping> selectedMediaCollectionMappingList =
        await Navigator.of(appNavigatorContext(context)).push(MaterialPageRoute(
      builder: (context) {
        return MediaCollectionGridPage(
          arguments: {'selectMode': true, 'mediaType': mediaType},
        );
      },
    ));
    return handleFuture<List<File>>(() async {
      List<File> files = await Future.wait(
          (selectedMediaCollectionMappingList ?? [])
              .map((e) => e.media.mediaFile())
              .toList());
      if (mediaType == 'VIDEO') {
        List<File> validFiles = [];
        for (final file in (files ?? [])) {
          final fileInfo = await videoInfo.getVideoInfo(file.path);
          if (fileInfo.duration <=
              AppConstants.videoDurationAllowed.inMicroseconds) {
            validFiles.add(file);
          }
        }
        if ((files ?? []).length != validFiles.length) {
          Fluttertoast.showToast(
              gravity: ToastGravity.TOP,
              msg:
                  'One or more videos have duration more than ${AppConstants.videoDurationAllowed.inSeconds > 60 ? AppConstants.videoDurationAllowed.inMinutes.toString() + 'minutes' : AppConstants.videoDurationAllowed.inSeconds.toString() + 'seconds'}',
              backgroundColor: Colors.red);
        }
        files = validFiles;
      }
      List<File> newFiles = files.map((e) => copyAndReturn(e)).toList();

      return newFiles;
    });
  }

  Future<File> pickFileFromCamera(
      {String mediaType, BuildContext context}) async {
    PickedFile pickedFile;
    if (mediaType == 'PHOTO') {
      pickedFile = await imagePicker.getImage(source: ImageSource.camera);
    } else if (mediaType == 'VIDEO') {
      pickedFile = await imagePicker.getVideo(
          source: ImageSource.camera,
          maxDuration: AppConstants.videoDurationAllowed);
    }
    return handleFuture(
        () => copyAndReturn(pickedFile != null ? File(pickedFile.path) : null));
  }

  Future<File> getThumbnail(File file, {String mediaType}) async {
    final thumbnailFile = File(tempDirectory.path + "/" + uuid.v1() + ".jpg");
    if (mediaType == 'PHOTO') {
      final thumbnailImage =
          img.copyResize(img.decodeImage(file.readAsBytesSync()), width: 200);
      thumbnailFile.writeAsBytesSync(img.encodeJpg(thumbnailImage));
    } else if (mediaType == 'VIDEO') {
      await VideoThumbnail.thumbnailFile(
        video: file.path,
        thumbnailPath: thumbnailFile.path,
        imageFormat: ImageFormat.JPEG,
        maxHeight:
            200, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
        quality: 50,
      );
    }
    return thumbnailFile;
  }
}
