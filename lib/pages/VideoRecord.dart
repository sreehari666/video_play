import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:video_play/pages/VideoPreview.dart';
import 'package:video_player/video_player.dart';
import '../main.dart';

class VideoRecord extends StatefulWidget {
  const VideoRecord({Key? key}) : super(key: key);

  State<VideoRecord> createState() => VideoRecordState();
}

class VideoRecordState extends State<VideoRecord> {
  CameraController? controller;
  bool _isCameraInitialized = false;
  bool _isRecordingInProgress = false;
  VideoPlayerController? videoController;
  File? _videoFile;
  String? videoFilePath;

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = controller;
    // Instantiating the camera controller
    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    // Dispose the previous controller
    await previousCameraController?.dispose();

    // Replace with the new controller
    if (mounted) {
      setState(() {
        controller = cameraController;
      });
    }

    // Update UI if controller updated
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    // Initialize controller
    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      print('Error initializing camera: $e');
    }

    // Update the Boolean
    if (mounted) {
      setState(() {
        _isCameraInitialized = controller!.value.isInitialized;
      });
    }
  }

  // video recording functions

  Future<void> startVideoRecording() async {
    final CameraController? cameraController = controller;
    if (controller!.value.isRecordingVideo) {
      // A recording has already started, do nothing.
      return;
    }
    try {
      await cameraController!.startVideoRecording();
      setState(() {
        _isRecordingInProgress = true;
        print(_isRecordingInProgress);
      });
    } on CameraException catch (e) {
      print('Error starting to record video: $e');
    }
  }

  Future<XFile?> stopVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      // Recording is already is stopped state
      return null;
    }
    try {
      XFile file = await controller!.stopVideoRecording();
      setState(() {
        _isRecordingInProgress = false;
        print(_isRecordingInProgress);
      });
      return file;
    } on CameraException catch (e) {
      print('Error stopping video recording: $e');
      return null;
    }
  }

  Future<void> pauseVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      // Video recording is not in progress
      return;
    }
    try {
      await controller!.pauseVideoRecording();
    } on CameraException catch (e) {
      print('Error pausing video recording: $e');
    }
  }

  Future<void> resumeVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      // No video recording was in progress
      return;
    }
    try {
      await controller!.resumeVideoRecording();
    } on CameraException catch (e) {
      print('Error resuming video recording: $e');
    }
  }

  Future<void> _startVideoPlayer() async {
    if (_videoFile != null) {
      videoController = VideoPlayerController.file(_videoFile!);
      await videoController!.initialize().then((_) {
        setState(() {});
      });
      await videoController!.setLooping(true);
      await videoController!.play();
    }
  }

  @override
  void initState() {
    print(cameras);
    onNewCameraSelected(cameras[0]);
    super.initState();
  }

  @override
  void dispose() {
    controller!.dispose();
    videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: _isCameraInitialized
          ? SizedBox(
              height: height,
              width: width,
              child: AspectRatio(
                aspectRatio: 1 / controller!.value.aspectRatio,
                child: CameraPreview(
                  controller!,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                              onTap: () {
                                resumeVideoRecording();
                              },
                              child: const Icon(
                                Icons.play_arrow,
                                size: 40,
                                color: Colors.white,
                              )),
                          InkWell(
                              onTap: () {
                                pauseVideoRecording();
                              },
                              child: const Icon(
                                Icons.pause,
                                size: 40,
                                color: Colors.white,
                              )),
                          Container(
                            height: 100,
                            width: 100,
                            child: InkWell(
                              onTap: () async {
                                if (_isRecordingInProgress) {
                                  XFile? rawVideo = await stopVideoRecording();
                                  File videoFile = File(rawVideo!.path);

                                  int currentUnix =
                                      DateTime.now().millisecondsSinceEpoch;

                                  final directory =
                                      await getApplicationDocumentsDirectory();
                                  String fileFormat =
                                      videoFile.path.split('.').last;
                                  videoFilePath =
                                      '${directory.path}/$currentUnix.$fileFormat';
                                  _videoFile = await videoFile.copy(
                                    '${directory.path}/$currentUnix.$fileFormat',
                                  );

                                  _startVideoPlayer();
                                } else {
                                  await startVideoRecording();
                                }
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  const Icon(
                                    Icons.circle,
                                    color: Colors.white,
                                    size: 80,
                                  ),
                                  const Icon(
                                    Icons.circle,
                                    color: Colors.red,
                                    size: 65,
                                  ),
                                  _isRecordingInProgress
                                      ? const Icon(
                                          Icons.stop_rounded,
                                          color: Colors.white,
                                          size: 32,
                                        )
                                      : Container(),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                              child: videoController != null &&
                                      videoController!.value.isInitialized
                                  ? InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  VideoPreview(
                                                      videoFilePath:
                                                          videoFilePath)),
                                        );
                                      },
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: AspectRatio(
                                          aspectRatio: videoController!
                                              .value.aspectRatio,
                                          child: VideoPlayer(videoController!),
                                        ),
                                      ),
                                    )
                                  : Container(),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )
          : Container(),
    );
  }
}
