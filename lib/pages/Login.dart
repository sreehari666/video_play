import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:video_play/pages/Home.dart';
import 'package:firebase_database/firebase_database.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  State<Login> createState() => LoginState();
}

class LoginState extends State<Login> {
  TextEditingController PhoneNumber = TextEditingController();
  TextEditingController otp = TextEditingController();
  TextEditingController name = TextEditingController();

  final storage = const FlutterSecureStorage();
  
  

  FirebaseAuth auth = FirebaseAuth.instance;
  String verificationIDRecieved = "";
  bool otpCodeVisible = false;
  bool loggedIn = false;
  String messageText ="";

  @override
  void initState() {
    PhoneNumber.text = "";
    otp.text = "";
    name.text="";
    messageText = "Login to your account";
    super.initState();
  }

  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Builder(
        builder: (context) {
          return SingleChildScrollView(
            child: Column(
              children: [
                
                SizedBox(
                  height: height - height / 2,
                  width: width,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: SizedBox(
                          height: 200,
                          width: 200,
                          child: Image.asset('assets/images/logo_v.png')),
                      ),
                      Text(messageText,
                      style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ),

                Container(
                  height: height / 2,
                  width: width,
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20)),
                      color: Color.fromARGB(255, 231, 231, 231)
                      // color:Color.fromARGB(255, 30, 56, 93),
                      ),
                  child: Center(
                      child: Padding(
                    padding: const EdgeInsets.fromLTRB(15, 20, 15, 15),
                    child: Column(children: [

                      Visibility(
                        visible: !otpCodeVisible,
                        child: Container(
                            height: 50,
                            width: width,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Color.fromARGB(255, 214, 211, 211),
                                      spreadRadius: 0.4,
                                      blurRadius: 2)
                                ]),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                              child: TextField(
                                controller: name,
                                decoration: const InputDecoration(
                                    icon: Icon(
                                      Icons.person,
                                      color: Color.fromRGBO(217, 217, 217, 1),
                                    ),
                                    border: InputBorder.none,
                                    hintText: 'Name',
                                    hintStyle: TextStyle(
                                      color: Color.fromRGBO(217, 217, 217, 1),
                                    )),
                              ),
                            )),
                      ),
                      Visibility(
                        visible: !otpCodeVisible,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: Container(
                              height: 50,
                              width: width,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Color.fromARGB(255, 214, 211, 211),
                                        spreadRadius: 0.4,
                                        blurRadius: 2)
                                  ]),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                child: TextField(
                                  controller: PhoneNumber,
                                  decoration: const InputDecoration(
                                      icon: Icon(
                                        Icons.phone,
                                        color: Color.fromRGBO(217, 217, 217, 1),
                                      ),
                                      border: InputBorder.none,
                                      hintText: 'phone number',
                                      hintStyle: TextStyle(
                                        color: Color.fromRGBO(217, 217, 217, 1),
                                      )),
                                      keyboardType: TextInputType.phone,
                                ),
                      
                              )),
                        ),
                      ),

                      !loggedIn?Visibility(
                        visible: otpCodeVisible,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: Container(
                              height: 50,
                              width: width,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Color.fromARGB(255, 214, 211, 211),
                                        spreadRadius: 0.4,
                                        blurRadius: 2)
                                  ]),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                child: TextField(
                                  controller: otp,
                                  decoration: const InputDecoration(
                                      icon: Icon(
                                        Icons.password,
                                        color: Color.fromRGBO(217, 217, 217, 1),
                                      ),
                                      border: InputBorder.none,
                                      hintText: 'OTP',
                                      hintStyle: TextStyle(
                                        color: Color.fromRGBO(217, 217, 217, 1),
                                      )),
                                      keyboardType: TextInputType.phone,
                                ),
                              )),
                        ),
                      ):Container(),

                      !loggedIn ? Visibility(
                        visible: otpCodeVisible,
                        child: TextButton(
                          child: const Text("Did not get OTP, resend ?"),
                          onPressed: () {
                            verifyNumber();
                          },
                        ),
                      ):Text(""),

                      Visibility(
                        visible: !loggedIn,
                        child: GestureDetector(
                          onTap: (){
                            print("tap");
                            print(PhoneNumber.text);
                            if (otpCodeVisible) {
                              verifyCode();
                            } else {
                              verifyNumber();
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: Container(
                              height: 50,
                              width: width,
                              decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 30, 56, 93),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Color.fromARGB(255, 214, 211, 211),
                                        spreadRadius: 0.4,
                                        blurRadius: 2)
                                  ]),
                              child: Center(
                                child: Text(
                                  otpCodeVisible ? 'Verify' : 'Next',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ), 
                        ),
                      ),

                      Visibility(
                        visible: loggedIn,
                        child: GestureDetector(
                          onTap: (){
                            print("navigate to home page");
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => const Home()));
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: Container(
                              height: 50,
                              width: width,
                              decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 30, 56, 93),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Color.fromARGB(255, 214, 211, 211),
                                        spreadRadius: 0.4,
                                        blurRadius: 2)
                                  ]),
                              child: Center(
                                child: Text(
                                  "Get started",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ), 
                        ),
                      ),


                    ]),
                  )),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  void verifyNumber() {
    
    auth.verifyPhoneNumber(
        phoneNumber: '+91${PhoneNumber.text}',
        verificationCompleted: (PhoneAuthCredential credential) async {
          await auth.signInWithCredential(credential).then((value) {
            print("Signin successfull");
          });
        },
        verificationFailed: (FirebaseAuthException exception) {
          print(exception.message);
        },
        codeSent: (String verificationID, int? resendToken) {
          verificationIDRecieved = verificationID;
          otpCodeVisible = true;
          setState(() {});
        },
        codeAutoRetrievalTimeout: (String verificationID) {});
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error!"),
          content: const Text("Login failed, try again!"),
          actions: <Widget>[
            FlatButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void verifyCode() async {
    
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationIDRecieved, smsCode: otp.text);

    await auth.signInWithCredential(credential).then((value)async {
      print("Loggedin successfully");
      print(value);
      print(value.user!.uid);

      try{
        await storage.write(key: 'userid', value:value.user!.uid.toString());
        await storage.write(key: 'name', value: name.text);
      }catch(e){
        print(e);
      }

      final ref = FirebaseDatabase.instance.ref('users/${value.user!.uid.toString()}');
      
      if(value.additionalUserInfo!.isNewUser){
          await ref.set({
          "uid":value.user!.uid,
          "name":name.text,
          "number":'+91${PhoneNumber.text}',
        }).then((res) {
            loggedIn = true;
            messageText = "Welcome";
            
            setState(() {});
        }).catchError((err){
          print(err);
        });
      }else{
        loggedIn = true;
        messageText = "Welcome";
        setState(() {});
        print("user exist");
      }
      
      
    }).catchError((error) {
      _showDialog(context);
      loggedIn=false;
    });
  }
}
