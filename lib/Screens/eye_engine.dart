
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mlkit/mlkit.dart';
import 'package:theeye/Screens/home.dart';

class EyeEngine extends StatefulWidget{
  File file; String selectedScanner;
  @override
 _EyeEngineState createState() => _EyeEngineState();
 EyeEngine(this.file, this.selectedScanner);
}

class _EyeEngineState  extends State<EyeEngine>{
  FirebaseVisionTextDetector textDetector = FirebaseVisionTextDetector.instance;
  FirebaseVisionBarcodeDetector barcodeDetector = FirebaseVisionBarcodeDetector.instance;
  FirebaseVisionFaceDetector faceDetector = FirebaseVisionFaceDetector.instance;
  FirebaseVisionLabelDetector labelDetector = FirebaseVisionLabelDetector.instance;
  List<VisionText>  _currentTextLabels = <VisionText>[];
  List<VisionBarcode> _currentBarcodeLabels = <VisionBarcode>[];
  List<VisionFace> _currentFaceLabels = <VisionFace>[];
  List<VisionLabel> _currentLabelLabels = <VisionLabel>[];

  Stream sub;
  StreamSubscription<dynamic> subscription;


  @override
  void initState() {
    super.initState();
    sub = new Stream.empty();
    subscription = sub.listen((_) => _getImageSize)..onDone(analyzeLabels);

  }

  void analyzeLabels() async{

    try{
      var currentLabels;
      if(widget.selectedScanner== TEXT_SCANNER){
        currentLabels =await textDetector.detectFromPath(widget.file.path);
        if(this.mounted){
          setState(() {
            _currentTextLabels = currentLabels;
          });
        }
      }
      else if(widget.selectedScanner== BARCODE_SCANNER){
          currentLabels =await barcodeDetector.detectFromPath(widget.file.path);
          if(this.mounted){
            setState(() {
              _currentTextLabels = currentLabels;
            });
          }
        }
        else if(widget.selectedScanner== FACE_SCANNER){
          currentLabels =await faceDetector.detectFromPath(widget.file.path);
          if(this.mounted){
            setState(() {
              _currentTextLabels = currentLabels;
            });
          }
        }
        else if(widget.selectedScanner== LABEL_SCANNER){
          currentLabels =await labelDetector.detectFromPath(widget.file.path);
          if(this.mounted){
            setState(() {
              _currentTextLabels = currentLabels;
            });
          }
        }
    }catch(e){
      print("errororere>>>>>>>"+ e.toString());
    }
  }


  @override
  void dispose() {
    super.dispose();
    subscription?.cancel();
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Column(
        children: <Widget>[
          imageBuilder(context),
          widget.selectedScanner == TEXT_SCANNER
            ?textListBuilder(_currentTextLabels)
              :widget.selectedScanner == BARCODE_SCANNER
              ?listBuilder<VisionBarcode>(_currentBarcodeLabels)
                :widget.selectedScanner == FACE_SCANNER
                ?listBuilder<VisionFace>(_currentFaceLabels)
                :listBuilder<VisionLabel>(_currentLabelLabels)


        ],

      ),
    );
  }

  Widget imageBuilder(BuildContext context){

    return Expanded(
      flex: 2,
      child:  Container(
        decoration: BoxDecoration(
          color:  Colors.black
        ),
        child: Center(
          child: widget.file==null
              ? Text("Image Invalid")
              : FutureBuilder<Size>(
                 future: _getImageSize(
                     Image.file(widget.file,fit: BoxFit.fitWidth,)) ,
               builder: (BuildContext context , AsyncSnapshot<Size> snapshot){
                    if(snapshot.hasData){
                      return Container(
                        foregroundDecoration: (widget.selectedScanner == TEXT_SCANNER)
                        ?TextDetectDecoration(
                          _currentTextLabels , snapshot.data)
                            :widget.selectedScanner == FACE_SCANNER
                          ?FaceDetectDecoration(
                            _currentFaceLabels, snapshot.data)
                            :widget.selectedScanner ==BARCODE_SCANNER
                             ?BarcodeDetectDecoration(
                                _currentBarcodeLabels, snapshot.data)
                                :LabelDetectDecoration(
                                 _currentLabelLabels, snapshot.data),
                        child: Image.file(widget.file, fit:BoxFit.fitWidth),
                      );

                    }else{
                      return CircularProgressIndicator();
                    }
                   },
          )
          ,
        ),

      ),
    );
  }


  Widget listBuilder <T>(List<T> lists){
    if(lists.length == 0){
      return Expanded(
        flex: 1,
        child: Center(
          child: Text( " NOTHING DETECTED ",
                 style:Theme.of(context).textTheme.subhead ,),
        ),
      );
    }
      return Expanded(
        flex:  1,
        child: Container(
          child: ListView.builder(
            padding: EdgeInsets.all(1),
            itemCount: lists.length,
            itemBuilder: (context, i){
              var text;
              final list= lists[i];

              switch(widget.selectedScanner){
                case BARCODE_SCANNER:
                  VisionBarcode res = list as VisionBarcode;
                  text = "Raw Value : ${res.rawValue}";
                  break;
                case FACE_SCANNER:
                  VisionFace res = list as VisionFace;
                  text = "Raw Value : ${res.smilingProbability}, ${res.trackingID}";
                  break;
                case LABEL_SCANNER:
                  VisionLabel res = list as VisionLabel;
                  text = "Raw Value : ${res.label}";
                  break;
              }
              return Text( text);
            }
          ),
        )   ,
      );
  }

  Widget  textListBuilder(List<VisionText> texts){
    if(texts.length == 0){
      return Expanded(
        flex: 1,
        child: Center(
          child: Text(
            "No text Detected",
            style: Theme.of(context).textTheme.subhead,
          ),
      ),
      );
    }
    return Expanded(
      flex:  1,
      child: Container(
        child: ListView.builder(
            padding:  EdgeInsets.all(1),
            itemCount: texts.length,
            itemBuilder: (context, i){
              return  Text(texts[i].text);
            }
        ),
      ),
    );
  }

  Future<Size> _getImageSize(Image image){
    Completer<Size> completer =Completer<Size>();
    image.image.resolve(ImageConfiguration())
        .addListener((ImageInfo info, bool _) => completer.complete(
        Size(info.image.width.toDouble(), info.image.height.toDouble())
    ));
    return completer.future;
  }

}/// end of EYESTATE class


class BarcodeDetectDecoration extends Decoration{
  final List <VisionBarcode> _barcodes;
  final Size _originalImage;
  BarcodeDetectDecoration(this._barcodes, this._originalImage,);

  @override
  BoxPainter createBoxPainter([VoidCallback onChanged]) {
    // TODO: implement createBoxPainter
    return _BarcodeDetectPainter(_barcodes, _originalImage);
  }
}

class _BarcodeDetectPainter extends BoxPainter {
  final List<VisionBarcode> _barcodes;
  final Size _originalImageSize;
  _BarcodeDetectPainter(this. _barcodes, this._originalImageSize);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    // TODO: implement paint
    final paint =Paint()
    ..strokeWidth = 2.0
    ..color = Colors.red
    ..style = PaintingStyle.stroke;

    final _heightRatio = _originalImageSize.height/configuration.size.height;
    final _widthRatio = _originalImageSize.width/configuration.size.width;

    for(var barcode in _barcodes){
      final _rect = Rect.fromLTRB(
          offset.dx + barcode.rect.left / _widthRatio,
          offset.dy + barcode.rect.top / _heightRatio,
          offset.dx + barcode.rect.right / _widthRatio,
          offset.dy + barcode.rect.bottom / _heightRatio);
      canvas.drawRect(_rect, paint);
    }
    canvas.restore();
  }
}


class TextDetectDecoration extends Decoration {
  final Size _originalImageSize;
  final List<VisionText> _texts;
  TextDetectDecoration(List<VisionText> texts, Size originalImageSize)
      : _texts = texts,
        _originalImageSize = originalImageSize;

  @override
  BoxPainter createBoxPainter([VoidCallback onChanged]) {
    return _TextDetectPainter(_texts, _originalImageSize);
  }
}

class _TextDetectPainter extends BoxPainter {
  final List<VisionText> _texts;
  final Size _originalImageSize;
  _TextDetectPainter(texts, originalImageSize)
      : _texts = texts,
        _originalImageSize = originalImageSize;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final paint = Paint()
      ..strokeWidth = 2.0
      ..color = Colors.red
      ..style = PaintingStyle.stroke;

    final _heightRatio = _originalImageSize.height / configuration.size.height;
    final _widthRatio = _originalImageSize.width / configuration.size.width;
    for (var text in _texts) {
      final _rect = Rect.fromLTRB(
          offset.dx + text.rect.left / _widthRatio,
          offset.dy + text.rect.top / _heightRatio,
          offset.dx + text.rect.right / _widthRatio,
          offset.dy + text.rect.bottom / _heightRatio);
      canvas.drawRect(_rect, paint);
    }
    canvas.restore();
  }
}

class FaceDetectDecoration extends Decoration {
  final Size _originalImageSize;
  final List<VisionFace> _faces;
  FaceDetectDecoration(List<VisionFace> faces, Size originalImageSize)
      : _faces = faces,
        _originalImageSize = originalImageSize;

  @override
  BoxPainter createBoxPainter([VoidCallback onChanged]) {
    return _FaceDetectPainter(_faces, _originalImageSize);
  }
}

class _FaceDetectPainter extends BoxPainter {
  final List<VisionFace> _faces;
  final Size _originalImageSize;
  _FaceDetectPainter(faces, originalImageSize)
      : _faces = faces,
        _originalImageSize = originalImageSize;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final paint = Paint()
      ..strokeWidth = 2.0
      ..color = Colors.red
      ..style = PaintingStyle.stroke;

    final _heightRatio = _originalImageSize.height / configuration.size.height;
    final _widthRatio = _originalImageSize.width / configuration.size.width;
    for (var face in _faces) {
      final _rect = Rect.fromLTRB(
          offset.dx + face.rect.left / _widthRatio,
          offset.dy + face.rect.top / _heightRatio,
          offset.dx + face.rect.right / _widthRatio,
          offset.dy + face.rect.bottom / _heightRatio);
      canvas.drawRect(_rect, paint);
    }
    canvas.restore();
  }
}

class LabelDetectDecoration extends Decoration {
  final Size _originalImageSize;
  final List<VisionLabel> _labels;
  LabelDetectDecoration(List<VisionLabel> labels, Size originalImageSize)
      : _labels = labels,
        _originalImageSize = originalImageSize;

  @override
  BoxPainter createBoxPainter([VoidCallback onChanged]) {
    return _LabelDetectPainter(_labels, _originalImageSize);
  }
}

class _LabelDetectPainter extends BoxPainter {
  final List<VisionLabel> _labels;
  final Size _originalImageSize;
  _LabelDetectPainter(labels, originalImageSize)
      : _labels = labels,
        _originalImageSize = originalImageSize;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final paint = Paint()
      ..strokeWidth = 2.0
      ..color = Colors.red
      ..style = PaintingStyle.stroke;

    final _heightRatio = _originalImageSize.height / configuration.size.height;
    final _widthRatio = _originalImageSize.width / configuration.size.width;
    for (var label in _labels) {
      final _rect = Rect.fromLTRB(
          offset.dx + label.rect.left / _widthRatio,
          offset.dy + label.rect.top / _heightRatio,
          offset.dx + label.rect.right / _widthRatio,
          offset.dy + label.rect.bottom / _heightRatio);
      canvas.drawRect(_rect, paint);
    }
    canvas.restore();
  }
}