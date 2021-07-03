import 'dart:collection';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:quiver/iterables.dart';
// import 'package:audioplayers/audioplayers.dart'

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: '50 Yen'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class Word {
  String label;
  String file;
  List<String> vowels;

  Word(this.label, this.file, this.vowels);

  @override
  int get hashCode => label.hashCode;
}

class _MyHomePageState extends State<MyHomePage> {
  AudioPlayer player;
  bool _playing = false;
  String _lyme = '';
  int _vibes = 0;
  Queue _wordsQueue = Queue<Word>();

  final AudioCache _ac = AudioCache();

  final bgms = [
    {'label': 'A', 'file': 'tr_a.mp3'},
  ];
  List<Word> voices = [];

  _MyHomePageState() {
    bgms.forEach((s) => _ac.load(s['file']));
    voices = [
      Word('オレは', 'v_oreha.mp3', ['o', 'e', 'a']),
      Word('オマエは', 'v_omaeha.mp3', ['o', 'a', 'e', 'a']),
      Word('ラッパー', 'v_rapper.mp3', ['a', 'x', 'a']),
      Word('河童', 'v_kappa.mp3', ['a', 'x', 'a']),
      Word('Yeah', 'v_yeah.mp3', ['i', 'e', 'e']),
      Word('Yo', 'v_yo.mp3', ['o']),
      Word('HipHop', 'v_hiphop.mp3', ['i', 'u', 'o', 'u']),
      Word('上杉謙信', 'v_uesugikenshin.mp3', ['u', 'e', 'u', 'i', 'e', 'n', 'i', 'n']),
      Word('Dancing','v_dancing.mp3',['a', 'n', 'i', 'n']),
      Word('楽しく', 'v_tanoshiku.mp3',['a', 'o', 'i', 'u']),
      Word('激しく','v_hageshiku.mp3',['a', 'e', 'i', 'u']),
    ];
    voices.forEach((s) => _ac.load(s.file));
  }

  void _startPlay() {
    _ac.loop('tr_a.mp3').then((p) => player = p);
    _wordsQueue.clear();
    setState(() {
      _playing = true;
      _lyme = '';
      _vibes = 0;
    });
  }

  void _stopPlay() {
    player?.stop();
    setState(() {
      _playing = false;
      _lyme = '';
    });
  }

  void _selectWord(Word w) {
    _ac.play(w.file);
    var vibesPoint = calcVibes(_wordsQueue, w);
    if (vibesPoint > 0) {
      _ac.play('s_cheers.mp3');
    }
    _wordsQueue.addFirst(w);
    if (_wordsQueue.length > 4) {
      _wordsQueue.removeLast();
    }
    setState(() {
      _lyme = w.label;
      _vibes = _vibes + vibesPoint;
    });
  }

  int calcVibes(Queue<Word> words, Word current) {
    var scores = words.toSet().where((w) => w.label != current.label).map((word) {
      var matchedVowels = zip([word.vowels.reversed, current.vowels.reversed])
          .takeWhile((pair) => pair[0] == pair[1])
          .length;
      return (matchedVowels > 2) ? matchedVowels : 0;
    });
    return scores.fold(0, (a, b) => a + b);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Vibes point: ' + _vibes.toString(), style: TextStyle(fontSize: 18.0)),
            Text(_lyme ?? '', style: TextStyle(fontSize: 56.0)),
            if (!_playing)
              FlatButton(
                onPressed: _startPlay,
                child: Text('play'),
              ),
            if (_playing)
              FlatButton(
                onPressed: _stopPlay,
                child: Text('stop'),
              ),
            Wrap(
              children: <Widget>[
                for (var v in voices)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RaisedButton(
                        onPressed: () => _selectWord(v),
                        child: Text(v.label ?? '')),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
