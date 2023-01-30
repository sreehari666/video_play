import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:video_play/pages/Login.dart';
import 'package:video_play/pages/VideoRecord.dart';
import 'package:firebase_database/firebase_database.dart';
import 'VideoWatch.dart';


class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
  TextEditingController searchInput = TextEditingController();
  late int currentIndex = 0;
  final ref = FirebaseDatabase.instance.ref('videos/');
  FlutterSecureStorage storage = FlutterSecureStorage();
  String name = "";
  

  void fetchUid() async{
    String uid ="";
    try{
      uid = (await storage.read(key: "userid"))!;
      name = (await storage.read(key: "name"))!;
      print(name);
      setState(() {
        
      });
      print(uid);
       if(uid == ""){
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Login()));
    }
    }catch(e){
      print(e);
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Login()));
    }
    
    
   


  }

  @override
  void initState() {
    currentIndex = 0;
    name;
    fetchUid();
    super.initState();
  }

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
              children: [
                Container(
                  height: 100,
                  width: width,
                  decoration:
                      const BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(
                        color: Color.fromARGB(255, 214, 211, 211),
                        spreadRadius: 0.4,
                        blurRadius: 2)
                  ]),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 18, 8, 0),
                    child: Column(
                      children: [
                        Row(
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
                                    child: const Icon(Icons.person)))
                            
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 25,top: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(name),
                              GestureDetector(
                                onTap: ()async{
                                  await storage.deleteAll();
                                  setState(() {
                                    fetchUid();
                                  });
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(builder: (context) => const Login()));
                                },
                                child: const Padding(
                                  padding: EdgeInsets.only(left: 5),
                                  child: Icon(Icons.logout,),
                                ),
                              )
                            ],
                          ),
                        ),
                        
                      ],
                    ),
                  ),
                ),
                
                SizedBox(
                  height: height - 80 - 72,
                  width: width,
                  child: FirebaseAnimatedList(
                      defaultChild: Center(child: Text("Loading.....")),
                      query: ref,
                      itemBuilder: (context, snapshot, animation, index) {
                        return GestureDetector(
                          onTap: () {
                            // route to video watch screen with data
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      VideoWatch(snapshot: snapshot)),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                            child: Container(
                              height: 100,
                              width: width,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                  boxShadow: const [
                                    BoxShadow(
                                        color:
                                            Color.fromARGB(255, 214, 211, 211),
                                        spreadRadius: 0.4,
                                        blurRadius: 2)
                                  ]),
                              child: Row(
                                children: [
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      snapshot.child('imgUrl').value.toString(),
                                      height: 90,
                                      width: 90,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  SizedBox(
                                    height: 90,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                            width: width - width / 2.5,
                                            child: Text(
                                              snapshot
                                                  .child('title')
                                                  .value
                                                  .toString(),
                                              maxLines: 1,
                                              softWrap: false,
                                              overflow: TextOverflow.fade,
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold),
                                            )),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.category_rounded,
                                              size: 14,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              snapshot
                                                  .child('category')
                                                  .value
                                                  .toString(),
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey),
                                            )
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.location_pin,
                                              size: 14,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            SizedBox(
                                              width: width - width / 2,
                                              child: Text(
                                                snapshot
                                                    .child('location')
                                                    .value
                                                    .toString(),
                                                maxLines: 1,
                                                softWrap: false,
                                                overflow: TextOverflow.fade,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                            "${snapshot.child('views').value.toString()} views ${snapshot.child('time').value.toString()}")
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
