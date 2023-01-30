// @dart=2.9

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'Home.dart';

File videoFile;

// ignore: must_be_immutable
class VideoPreview extends StatefulWidget {
  String videoFilePath;

  VideoPreview({Key key, this.videoFilePath}) : super(key: key);

  @override
  State<VideoPreview> createState() =>
      VideoPreviewState(videoFilePath: this.videoFilePath);
}

class VideoPreviewState extends State<VideoPreview> {
  String videoFilePath;
  VideoPreviewState({this.videoFilePath});
  VideoPlayerController videoController;
  Future<void> _initializeVideoPlayerFuture;
  TextEditingController title = TextEditingController();
  TextEditingController category = TextEditingController();
  String _currentAddress;
  Position _currentPosition;
  UploadTask uploadTask;
  bool uploadState;
  bool uploadCompleted;
  String uploadMessage;

  Future<void> uploadThumnail(TaskSnapshot video_snap) async {
    setState(() {
      uploadMessage = "creating thumbnail..";
    });
    UploadTask upload_task;
    TaskSnapshot snapshot;

    final thumbnail = await VideoThumbnail.thumbnailFile(
      video: videoFilePath,
      imageFormat: ImageFormat.JPEG,
      quality: 25,
    );

    String fileName = videoFile.path.split('/').last;
    final path = 'thumnails/${fileName}.jpeg';
    final ref = FirebaseStorage.instance.ref().child(path);
    upload_task = ref.putFile(File(thumbnail));
    snapshot = await upload_task.whenComplete(() {
      print("image uploaded snapshot:$snapshot");
      uploadState = false;
      uploadMessage = "uploaded thumbnail";
      setState(() {});
    });

    print('snapshot::$snapshot');
    uploadData(snapshot, video_snap);
  }

  Future<void> uploadData(TaskSnapshot snapshot, video_snap) async {
    setState(() {
      uploadMessage = "uploading data..";
    });
    String fileName = videoFile.path.split('/').last;
    DatabaseReference DBref = FirebaseDatabase.instance.ref('videos/');
    String imgUrl;
    String videoUrl;
    String date = DateFormat("MMMM, dd, yyyy").format(DateTime.now());
    print(date);

    String time = DateFormat("hh:mm:ss a").format(DateTime.now());
    print(time);

    try {
      imgUrl = await snapshot.ref.getDownloadURL();
      print("image url:");
      print(imgUrl);
    } catch (e) {
      print('image url error: $e');
    }

    try {
      videoUrl = await video_snap.ref.getDownloadURL();
      print("video url:");
      print(videoUrl);
    } catch (e) {
      print('video url error: $e');
    }

    print(imgUrl);
    await DBref.push().set({
      "fileName": fileName,
      "location": _currentAddress,
      "title": title.text,
      "category": category.text,
      "date": date,
      "time": time,
      "views": 0,
      "imgUrl": imgUrl,
      "videoUrl": videoUrl
    }).then((value) {
      setState(() {
        uploadMessage = "completed..";
        uploadState = false;
        uploadCompleted = true;
      });
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Home()));
    }).catchError((err) => print(err));
  }

  Future<void> uploadVideo() async {
    setState(() {
      uploadMessage = "preparing video..";
    });
    videoFile = File(videoFilePath);
    String date = DateFormat("MMMM, dd, yyyy").format(DateTime.now());
    String time = DateFormat("hh:mm:ss a").format(DateTime.now());
    String fileName = videoFile.path.split('/').last;
    final videoRef = FirebaseStorage.instance.ref().child('videos/${fileName}');

    final newCustomMetadata = SettableMetadata(
      customMetadata: {
        "location": _currentAddress,
        "title": title.text,
        "category": category.text,
        "date": date,
        "time": time,
        "views": '0',
      },
    );
    uploadTask = videoRef.putFile(videoFile, newCustomMetadata);

    final snapshot = await uploadTask.whenComplete(() {
      print("video uploaded");
      setState(() {
        uploadMessage = "video uploaded";
      });
    });
    print(snapshot);
    uploadThumnail(snapshot);
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
      print(position);
      _getAddressFromLatLng(_currentPosition);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(
            _currentPosition.latitude, _currentPosition.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() {
        _currentAddress =
            '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}';
      });
      print(_currentAddress);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  @override
  void initState() {
    _getCurrentPosition();
    uploadState = false;
    uploadCompleted = false;
    uploadMessage = "";
    videoFile = File(videoFilePath);
    if (videoFile != null) {
      videoController = VideoPlayerController.file(videoFile);

      _initializeVideoPlayerFuture = videoController.initialize();
      videoController.setLooping(true);
      videoController.play();
      super.initState();
    }
  }

  @override
  void dispose() {
    videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return SingleChildScrollView(
              child: Container(
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: height - 250,
                      child: AspectRatio(
                        aspectRatio: videoController.value.aspectRatio,
                        child: VideoPlayer(videoController),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 10, 10),
                      child: Row(
                        children: [
                          const Icon(Icons.location_pin, size: 18),
                          _currentAddress != null
                              ? Text(
                                  _currentAddress,
                                  style: const TextStyle(fontSize: 12),
                                )
                              : const Text("Loading..."),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 45,
                      width: width - 50,
                      child: TextField(
                        controller: title,
                        decoration: const InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 2,
                              color: Colors.blueAccent,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 2, color: Colors.blueAccent),
                          ),
                          labelText: 'Title',
                          hintText: 'Enter title of your video',
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 45,
                      width: width - 50,
                      child: TextField(
                        controller: category,
                        decoration: const InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 2,
                              color: Colors.blueAccent,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 2, color: Colors.blueAccent),
                          ),
                          labelText: 'Category',
                          hintText: 'Enter category of your video',
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 200,
                          child: ElevatedButton(
                            onPressed: () {
                              uploadState = true;
                              setState(() {});
                              uploadVideo();
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 10.0),
                              primary: Colors.blue,
                              shape: const StadiumBorder(),
                              elevation: 3,
                            ),
                            child: const Text(
                              "Upload",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                        )
                      ],
                    ),
                    uploadState
                        ? const LinearProgressIndicator(
                            minHeight: 5,
                          )
                        : const Text(""),
                    Text(
                      uploadMessage,
                      style: const TextStyle(fontSize: 12),
                    )
                  ],
                ),
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
