import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:audioplayers/audio_cache.dart';
import 'dart:math';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(brightness: Brightness.dark),
      home: MusicPage(),
    );
  }
}

class MusicPage extends StatefulWidget {
  createState() => MusicPageState();
}

class MusicPageState extends State<MusicPage> with TickerProviderStateMixin {
  Map<int, int> _song;

  AnimationController _controller;
  Animation<double> _loop;

  int _bar = 0;

  @override
  void initState() {
    print(Colors.primaries.length);
    super.initState();
    _song = _makeSong(_range(8));
    _controller =
        AnimationController(duration: Duration(seconds: 6), vsync: this)
          ..addListener(() {
            setState(() {
              int bar = _loop.value.round();
              if (bar != _bar) {
                _bar = bar;
                int note = _song[bar];
                if (note != null && note > 0) plyr.play('${_song[bar]}.mp3');
              }
            });
          });
    _loop = Tween(begin: 0.0, end: 8.0).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('MagicMusic'), actions: [
        Padding(
          padding: EdgeInsets.only(right: 20),
          child: IconButton(
            icon: Icon(FontAwesomeIcons.dice),
            onPressed: _randomize,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 20),
          child: IconButton(
            icon: Icon(
              _playing ? FontAwesomeIcons.stop : FontAwesomeIcons.play,
              color: _playing ? Colors.red : Colors.green,
            ),
            onPressed: () {
              setState(() {
                _playing ? _controller.stop() : _controller.repeat();
              });
            },
          ),
        ),
      ]),
      body: Stack(
        children: [
          Container(
            child: Column(
              children: _range(15)
                  .map((row) => row == 15 ? _bottomRow() : _row(row))
                  .toList(),
            ),
          ),
          Transform.translate(
            offset: Offset(
                (_loop.value / 8) * MediaQuery.of(context).size.width, 0),
            child: Container(
                color: Colors.blue,
                width: 3,
                height: MediaQuery.of(context).size.height),
          ),
        ],
      ),
    );
  }

  Widget _row(int row) {
    return Expanded(
      child: Row(
        children: _range(8).map((col) => _cell(row, col)).toList(),
      ),
    );
  }

  Widget _bottomRow() {
    return Row(
      children: _range(8).map((i) {
        return Expanded(
            child: FlatButton(
          child: Text('$i',
              style: TextStyle(fontSize: 20)),
          onPressed: () => plyr.play('s${i + 1}.mp3'),
        ));
      }).toList(),
    );
  }

  Widget _cell(int row, int col) {
    bool up = _isActive(row, col) && _isPlaying(col);
    return Expanded(
      child: GestureDetector(
        onTapDown: (_) => _activateCell(row, col),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 750),
          curve: Curves.easeInOut,
          margin: EdgeInsets.all(2),
          transform: Matrix4.rotationX(up ? 1.5 : 0),
          child: _isActive(row, col)
              ? Center(child: Text('${Notes.values[row]}'.split('.').last))
              : Container(),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: _isActive(row, col)
                  ? colors[row][up ? 700 : 400]
                  : _isPlaying(col)
                      ? Colors.blueGrey[600]
                      : Colors.blueGrey[800]),
        ),
      ),
    );
  }

  List<int> _range(int len, {bool rand = false}) {
    return List<int>.generate(len, (i) => rand ? Random().nextInt(14) : i + 1);
  }

  bool get _playing => _controller.isAnimating;

  bool _isActive(int row, int col) => _song[col] == row;

  bool _isPlaying(int col) => _loop.value.ceil() == col;

  void _activateCell(int row, int col) {
    setState(() {
      _isActive(row, col) ? _song.remove(col) : _song[col] = row;
    });
  }

  void _randomize() {
    setState(() {
      List song = _range(14, rand: true);
      song.shuffle();
      _song = _makeSong(song);
    });
  }

  Map<int, int> _makeSong(List<int> rows) {
    rows.insert(0, 0);
    return Map.from(rows.sublist(0, 9).asMap());
  }
}

AudioCache plyr = AudioCache();

enum Notes { n, am, am2, f, f2, c, c2, g, g2, dm, dm2, e7, e72, esus, esus2 }

const List colors = Colors.primaries;