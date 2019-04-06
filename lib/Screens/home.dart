
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:theeye/Screens/eye_engine.dart';
import 'package:theeye/Screens/vision.dart';


const String TEXT_SCANNER="TEXT SCANNER";
const String BARCODE_SCANNER="BARCODE SCANNER";
const String FACE_SCANNER="FACE SCANNER";
const String LABEL_SCANNER="LABEL SCANNER";

class Home extends  StatefulWidget {
  @override
  _HomeState createState() =>  _HomeState();
}

class _HomeState extends State<Home>{
  static const String CAMERA_SOURCE = "CAMERA SOURCE";
  static const String GALLERY_SOURCE = "GALLERY SOURCE";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  File _file;
  String _selectedScanner =FACE_SCANNER;
  Widget scannerTypeRowBuilder(){
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Card(
          elevation: 5,
          child: Container(
            decoration: BoxDecoration(
                border: Border(left: BorderSide(
                    color: Colors.deepOrangeAccent,
                    style: BorderStyle.solid,
                    width: 4.0
                )
                )
            ),
            child: Wrap(
              children: <Widget>[
                RadioListTile<String>(
                  title: Text(" Text Recognition"),
                  groupValue: _selectedScanner,
                  value: TEXT_SCANNER,
                  onChanged: onScannerSelected,
                ),
                /* RadioListTile<String>(
          title: Text(" Barcode Scanner"),
          groupValue: _selectedScanner,
          value: BARCODE_SCANNER,
          onChanged: onScannerSelected,
        ),*/

                RadioListTile<String>(
                  title: Text(" Image Scanner"),
                  groupValue: _selectedScanner,
                  value: LABEL_SCANNER,
                  onChanged: onScannerSelected,
                ),
                RadioListTile<String>(
                  title: Text(" Face Scanner"),
                  groupValue: _selectedScanner,
                  value: FACE_SCANNER,
                  onChanged: onScannerSelected,
                )
              ],
            ),
          )
      ),
    );
  }

  Widget imageSourceRowBuilder(){

    return Row(
      children: <Widget>[
        Expanded(
          child: Padding(padding: EdgeInsets.symmetric(horizontal: 8),
            child: RaisedButton(
              onPressed: (){
                onImageSelector(CAMERA_SOURCE);
              },
              //color: Colors.blue,
              //textColor: Colors.white,
              splashColor: Colors.blueGrey,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30))),
              elevation: 4.0,
              color: Colors.deepPurpleAccent,
              textColor: Colors.white,
              // splashColor: Colors.deepOrange,
              child: Padding(
                  padding: const EdgeInsets.symmetric(vertical:12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.camera_alt),
                      Text(
                        ' Camera',
                        style: TextStyle(
                            letterSpacing: 1,
                            fontSize: 22,
                            fontWeight: FontWeight.w800),
                      )
                    ],
                  )
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(padding: EdgeInsets.symmetric(horizontal: 8),
            child: RaisedButton(
              onPressed: (){
                onImageSelector(GALLERY_SOURCE);
              },
              //color: Colors.blue,
             // textColor: Colors.white,
              splashColor: Colors.blueGrey,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30))),
              elevation: 4.0,
              color: Colors.deepPurpleAccent,
              textColor: Colors.white,
              // splashColor: Colors.deepOrange,
              child: Padding(
                  padding: const EdgeInsets.symmetric(vertical:12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.image),
                      Text(
                        ' Gallery',
                        style: TextStyle(
                            letterSpacing: 1,
                            fontSize: 22,
                            fontWeight: FontWeight.w800),
                      )
                    ],
                  )
              ),            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

   /* final chooser =List<Widget>();
    //chooser.add(Text("Choose Scanner"));
    chooser.add(scannerTypeRowBuilder());
   // SizedBox(height: 15,);
    chooser.add(Text("Choose Image from", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),));
    chooser.add(imageSourceRowBuilder());
*/
    // TODO: implement build
    return Scaffold(
      key:  _scaffoldKey,
      appBar: AppBar(
        title: Text("Choose the task"),
        centerTitle: true,
      ),

      body: Container(
          //color: Color(0xFFEEEEEE),
         child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Center(
              child: Column(
                //mainAxisAlignment: MainAxisAlignment.center,
                // children: chooser
                children: <Widget>[
                  SizedBox(height: 40,),
                  scannerTypeRowBuilder(),
                  SizedBox(height: 25,),
                  Text("Choose Image from", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),),
                  SizedBox(height: 25,),
                  imageSourceRowBuilder(),
                  SizedBox(height: 25,),

                ],
              ),
            ),
          )
      ),
    );
  }
  /// Funtions here
  void onScannerSelected(String scanner){
    setState(() {
      _selectedScanner=scanner;
    });
  }

  void onImageSelector(String source)async{
    var imageSource;
    if( source == CAMERA_SOURCE){
      imageSource = ImageSource.camera;
    }else{
      imageSource = ImageSource.gallery;
    }
    final scaffold = _scaffoldKey.currentState;
    try{
      final file=await ImagePicker.pickImage(source: imageSource);
      if(file==null){
        throw Exception("File is not available");
      }
      Navigator.push(
          context, MaterialPageRoute(
          builder: (context)=>Vision(file, _selectedScanner)));

    } catch (e){
      scaffold.showSnackBar(
          SnackBar(
              content: Text(e.toString()) ));
    }


  }


///
}
