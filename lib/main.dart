import 'package:flutter/material.dart';

List<Color> colorList = [
  Colors.indigo,
  Colors.blue,
  Colors.green,
  Colors.yellow,
  Colors.orange,
  Colors.red
];

void main() => runApp(MaterialApp(
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    ));

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Offset> _points = <Offset>[];
  List<Offset> _setPoints = <Offset>[];
  List<PointsGroup> _ptsGroupList = <PointsGroup>[];
  int startIndex;
  int endIndex;

  @override
  void initState() {
    ColorChoser.penColor = Colors.black;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          GestureDetector(
            onPanStart: (details) {
              setState(() {
                _points.clear();
                startIndex = _ptsGroupList.length;
                ColorChoser.showColorSelector = false;
              });
            },
            onPanUpdate: (DragUpdateDetails details) {
              setState(() {
                RenderBox object = context.findRenderObject();
                Offset _localPosition =
                    object.globalToLocal(details.globalPosition);
                _points = new List.from(_points)..add(_localPosition);
                _setPoints = new List.from(_points);
                _ptsGroupList.add(new PointsGroup(
                    setPoints: _setPoints, setColor: ColorChoser.penColor));
              });
            },
            onPanEnd: (DragEndDetails details) {
              setState(() {
                _points.add(null);
                ColorChoser.showColorSelector = true;
                endIndex = _ptsGroupList.length;
                if (startIndex < endIndex) {
                  _ptsGroupList.replaceRange(
                      startIndex, endIndex - 1, [_ptsGroupList.removeLast()]);
                }
              });
            },
            child: CustomPaint(
              painter: SignaturePainter(grpPointsList: _ptsGroupList),
              size: Size.infinite,
            ),
          ),
          ColorChoser(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.undo),
          onPressed: () {
            setState(() {
              if (_ptsGroupList.length > 0) {
                _ptsGroupList.removeLast();
              }
            });
          }),
    );
  }
}

class ColorChoser extends StatefulWidget {
  const ColorChoser({
    Key key,
  }) : super(key: key);

  static Color backgroundColor = Colors.white;
  static Color penColor = Colors.blue;
  static bool showColorSelector = true;

  @override
  _ColorChoserState createState() => _ColorChoserState();
}

class _ColorChoserState extends State<ColorChoser> {
  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: ColorChoser.showColorSelector,
      child: Positioned(
        bottom: 0,
        left: 0,
        width: MediaQuery.of(context).size.width,
        child: Container(
          height: 60,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: colorList.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      ColorChoser.penColor = colorList[index];
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4.0, vertical: 5.0),
                    child: Container(
                      color: colorList[index],
                      // height: 30,
                      width: 45,
                    ),
                  ),
                );
              }),
        ),
      ),
    );
  }
}

class SignaturePainter extends CustomPainter {
  List<Offset> points;
  List<PointsGroup> grpPointsList = <PointsGroup>[];
  var paintObj;

  SignaturePainter({
    this.grpPointsList = const [],
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (PointsGroup pts in grpPointsList) {
      points = pts.setPoints;
      paintObj = Paint()
        ..color = pts.setColor
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 5.0;

      for (int i = 0; i < points.length - 1; i++) {
        if (points[i] != null && points[i + 1] != null) {
          canvas.drawLine(points[i], points[i + 1], paintObj);
        }
      }
    }
  }

  @override
  bool shouldRepaint(SignaturePainter oldDelegate) =>
      oldDelegate.points != points;
}

class PointsGroup {
  List<Offset> setPoints = <Offset>[];
  Color setColor;
  PointsGroup({this.setPoints, this.setColor});
}
