import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'VideoRecord.dart';

// ignore: must_be_immutable
class VideoWatch extends StatefulWidget {
  DataSnapshot snapshot;
  VideoWatch({Key? key, required this.snapshot}) : super(key: key);
  @override
  State<VideoWatch> createState() => VideoWatchState();
}

class VideoWatchState extends State<VideoWatch> {
  late int currentIndex;
  TextEditingController searchInput = TextEditingController();
  late VideoPlayerController videoController;

  @override
  void initState() {
    currentIndex = 0;
    videoController = VideoPlayerController.network(
        widget.snapshot.child("videoUrl").value.toString())
      ..initialize().then((_) {
        setState(() {});
      });
    super.initState();
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
      bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(
                Icons.explore,
              ),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.add_circle_outline,
                ),
                label: 'Create'),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.video_library_outlined,
              ),
              label: 'Library',
            ),
          ],
          currentIndex: currentIndex,
          selectedItemColor: Colors.black,
          selectedFontSize: 12,
          showUnselectedLabels: true,
          unselectedFontSize: 12,
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            color: Colors.black,
          ),
          iconSize: 24,
          onTap: (index) {
            print(index);
            currentIndex = index;
            setState(() {});
            if (index == 1) {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const VideoRecord()));
            }
          },
          elevation: 5),
      body: Builder(
        builder: (context) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 80,
                  width: width,
                  decoration:
                      const BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(
                        color: Color.fromARGB(255, 214, 211, 211),
                        spreadRadius: 0.4,
                        blurRadius: 2)
                  ]),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 14, 8, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Icon(
                          Icons.notifications,
                          color: Color.fromRGBO(147, 147, 147, 1),
                        ),
                        Row(
                          children: [
                            Container(
                              width: width - 200,
                              height: 40,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: const Color.fromRGBO(238, 238, 238, 1),
                                  boxShadow: const [
                                    BoxShadow(
                                        color:
                                            Color.fromARGB(255, 214, 211, 211),
                                        spreadRadius: 0.4,
                                        blurRadius: 2)
                                  ]),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextField(
                                  controller: searchInput,
                                  cursorColor: Colors.grey,
                                  decoration: const InputDecoration(
                                    icon: Icon(
                                      Icons.search,
                                      color: Color.fromRGBO(217, 217, 217, 1),
                                    ),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.filter_alt_rounded,
                              color: Color.fromRGBO(217, 217, 217, 1),
                            ),
                          ],
                        ),
                        GestureDetector(
                            onTap: null,
                            child: Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  color: const Color.fromRGBO(217, 217, 217, 1),
                                ),
                                child: const Icon(Icons.person))),
                      ],
                    ),
                  ),
                ),
                videoController.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: videoController.value.aspectRatio,
                        child: VideoPlayer(videoController))
                    : SizedBox(
                        height: height - height / 2,
                        width: width,
                        child: Stack(
                          children: [
                            Center(
                                child: Image.network(widget.snapshot
                                    .child("imgUrl")
                                    .value
                                    .toString())),
                            const Center(child: CircularProgressIndicator()),
                          ],
                        ),
                      ),
                VideoProgressIndicator(
                  videoController,
                  allowScrubbing: true,
                  padding: const EdgeInsets.all(0.0),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.skip_previous)),
                        IconButton(
                            onPressed: () {
                              videoController.value.isPlaying
                                  ? videoController.pause()
                                  : videoController.play();
                            },
                            icon: const Icon(Icons.play_arrow)),
                        IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.skip_next)),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(
                    height: 100,
                    width: width,
                    child: Row(
                      children: [
                        SizedBox(
                          width: width - width / 3 - 10,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 8, 0, 0),
                                child: Text(
                                  widget.snapshot
                                      .child("title")
                                      .value
                                      .toString(),
                                  overflow: TextOverflow.fade,
                                  maxLines: 1,
                                  softWrap: false,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 8, 0, 0),
                                child: SizedBox(
                                  width: 200,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: const [
                                      Icon(Icons.thumb_up),
                                      Icon(Icons.thumb_down),
                                      Icon(Icons.share),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 8, 0, 0),
                                child: Text(
                                  '${widget.snapshot.child("views").value.toString()} views  ${widget.snapshot.child("date").value.toString()}',
                                  overflow: TextOverflow.fade,
                                  maxLines: 1,
                                  softWrap: false,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: width / 3 - 10,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 0, 0),
                            child: Column(
                              children: [
                                Row(
                                  children: const [
                                    Icon(
                                      Icons.location_pin,
                                      size: 18,
                                    ),
                                    Text("Location"),
                                  ],
                                ),
                                Row(
                                  children: const [
                                    Icon(
                                      Icons.category,
                                      size: 18,
                                    ),
                                    Text("Category"),
                                  ],
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const Divider(
                  color: Colors.grey,
                ),
                SizedBox(
                  height: 45,
                  width: width,
                  child: Row(
                    children: [
                      SizedBox(
                        width: width - width / 3,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                              child: GestureDetector(
                                  onTap: null,
                                  child: Container(
                                      height: 40,
                                      width: 40,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: const Color.fromRGBO(
                                              217, 217, 217, 1),
                                          boxShadow: const [
                                            BoxShadow(
                                                color: Color.fromARGB(
                                                    255, 214, 211, 211),
                                                spreadRadius: 0.4,
                                                blurRadius: 2)
                                          ]),
                                      child: const Icon(Icons.person))),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text("Name"),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        width: width / 3,
                        child: const Text("View all videos"),
                      )
                    ],
                  ),
                ),
                const Divider(
                  color: Colors.grey,
                ),
                const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text("Comments"),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
