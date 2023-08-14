import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore_web/cloud_firestore_web.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quiz/landing.dart';
import 'package:quiz/result.dart';
import 'package:shimmer/shimmer.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:text_to_speech/text_to_speech.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:soundpool/soundpool.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:math';
import 'dart:io';
import 'dart:async';

double jaroWinklerDistance(String s1, String s2) {
  final double threshold = 0.49;
  int matches = 0;
  int transpositions = 0;
  int maxLength = max(s1.length, s2.length);
  int prefixLength = 0;
  while (prefixLength < min(s1.length, s2.length) &&
      s1[prefixLength] == s2[prefixLength]) {
    prefixLength++;
    matches++;
  }
  s1 = s1.substring(matches);
  s2 = s2.substring(matches);
  for (int i = 0; i < s1.length; i++) {
    for (int j = max(0, i - 2); j < min(s2.length, i + 3); j++) {
      if (s1[i] == s2[j]) {
        matches++;
        if (j < i) transpositions++;
        break;
      }
    }
  }
  double similarity = matches / maxLength;
  return similarity > threshold
      ? similarity + (0.1 * prefixLength * (1 - similarity))
      : similarity;
}

List<String> trueWords = ['Tr', 'Tru'];
List<String> falseWords = ['Fa', 'Fal'];

List<Map<String, dynamic>> compareWords(List<String> words, String answer) {
  return words
      .map((word) => {
            'word': word,
            'distance': jaroWinklerDistance(word, answer),
            'passThreshold': jaroWinklerDistance(word, answer) >= 0.5,
          })
      .toList();
}

String compareAnswer(
    List<String> trueWords, List<String> falseWords, String answer) {
  double highestValueTrue = compareWords(trueWords, answer.substring(0, 2))
      .fold(0.0, (maxValue, r) => max(r['distance'], maxValue));
  double highestValueFalse = compareWords(falseWords, answer.substring(0, 2))
      .fold(0.0, (maxValue, r) => max(r['distance'], maxValue));

  if (highestValueFalse > highestValueTrue && highestValueFalse > 0.3)
    return "false";
  if (highestValueTrue > highestValueFalse && highestValueTrue > 0.3)
    return "true";
  return answer;
}

List<QuizModel> questions = [];

List<Filter> mainSubjects = [];
List<Filter> levels = [];
List<Filter> subjects = [];

Filter? selectedMainSubject;
Filter? selectedLevel;
Filter? selectedSubject;

int duration = 5;
int currentQuestion = 0;

bool speechEnabled = false;
bool listening = false;

String lastWords = '';
String localeId = '';
//replaceAll(' ', '').

class Quiz extends StatefulWidget {
  const Quiz({Key? key}) : super(key: key);

  @override
  _QuizState createState() => _QuizState();
}

enum TtsState {
  playing,
  stopped,
  paused,
  continued
} //create the possible states of TttState

class QuizModel {
  final String id;
  final String question;
  final String answer;
  var spokenanswer;
  int status;

  QuizModel(
      this.id, this.question, this.answer, this.status, this.spokenanswer);
}

class Filter {
  final String id;
  final String title;

  Filter(this.id, this.title);
}

AudioPlayer audioPlayer = AudioPlayer();

class _QuizState extends State<Quiz> with TickerProviderStateMixin {
  TextToSpeech tts = TextToSpeech();
  SpeechToText stt = SpeechToText();
  late FlutterTts flutterTts;
//define the completed as a member variable
  Completer<void> _ttsCompleter = Completer<void>();

  @override
  void reassemble() {
    // TODO: implement reassemble
    super.reassemble();
  }

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    flutterTts.setLanguage("en-US");
    flutterTts.setPitch(1.0);
    flutterTts.setSpeechRate(1);
    getMainSubject();
    getSubject();
    print("yes");

    flutterTts.setCompletionHandler(() {
      print("TTS Finished Speaking");
      _ttsCompleter.complete();
    });

    initSpeech();
  }

  TtsState ttsState = TtsState.stopped;

  get isPlaying => ttsState == TtsState.playing;
  get isStopped => ttsState == TtsState.stopped;
  get isPaused => ttsState == TtsState.paused;
  get isContinued => ttsState == TtsState.continued;

  initTts() {
    flutterTts = FlutterTts();
    Future _setAwaitOptions() async {
      await flutterTts.awaitSpeakCompletion(true);
    }

    flutterTts.setStartHandler(() {
      setState(() {
        print("Playing");
        ttsState = TtsState.playing;
      });
    });

    flutterTts.setCompletionHandler(() {
      if (!_ttsCompleter.isCompleted) {
        // If not, we complete it here to let any awaiting tasks continue.
        _ttsCompleter.complete();
      }
      setState(() {
        // Print to console for debugging purposes.
        print("Complete");
        // Update the state of the Text-to-Speech to stopped.
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setCancelHandler(() {
      setState(() {
        print("Cancel");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setPauseHandler(() {
      setState(() {
        print("Paused");
        ttsState = TtsState.paused;
      });
    });

    flutterTts.setContinueHandler(() {
      setState(() {
        print("Continued");
        ttsState = TtsState.continued;
      });
    });

    flutterTts.setErrorHandler((msg) {
      setState(() {
        print("error: $msg");
        ttsState = TtsState.stopped;
      });
    });
  }

  void sayQuestion(String question) async {
    _ttsCompleter = Completer<void>();

    ///this buttom
    await flutterTts.speak(question);
    await _ttsCompleter.future;

    AudioCache player = new AudioCache();
    const alarmAudioPath = "sound.wav";
    await player.play(alarmAudioPath);

    lastWords = '';
    listening = false;

    setState(() {});

    listenAnswer();

    for (int i = 0; i < 5; i++) {
      await Future.delayed(Duration(seconds: 1));
      duration--;
      setState(() {});
    }

    stt.stop();

    if (lastWords.trim().isEmpty) {
      questions[currentQuestion].status = 0;
    } else {
      if (lastWords.trim().toLowerCase() ==
          questions[currentQuestion].answer.toLowerCase()) {
        questions[currentQuestion].status = 1;
      } else {
        questions[currentQuestion].status = 2;
      }
    }

    if (questions.last.question == question) {
      Navigator.of(context).pushReplacement(CupertinoPageRoute(
          builder: (context) => Result(
              questions: questions,
              selectedMainSubject: selectedMainSubject!,
              selectedLevel: selectedLevel!,
              selectedSubject: selectedSubject!)));
    } else {
      lastWords = '';
      duration = 5;
      listening = true;
      currentQuestion++;
      setState(() {});

      sayQuestion(questions[currentQuestion].question);
    }
  }

// Get a reference to the Firebase Firestore collection for user scores
  final userScoresCollection =
      FirebaseFirestore.instance.collection('user_scores');

  void onSpeechResult(SpeechRecognitionResult result) async {
    setState(() {
      lastWords = result.recognizedWords;
      String Compresult = compareAnswer(trueWords, falseWords, lastWords);
      print("this is spat out from the comparison: $Compresult");
      print("this is was what was interpreted $lastWords");
      lastWords = Compresult;
      questions[currentQuestion].spokenanswer = lastWords;
      print(questions[currentQuestion].spokenanswer);
    });
  }

  void listenAnswer() async {
    await stt.stop();
    lastWords = '';
    setState(() {});
    await stt.listen(onResult: onSpeechResult, cancelOnError: true);
    setState(() {});
  }

  void errorListener(SpeechRecognitionError error) {
    print(error);
  }

  void cancelListening() {
    stt.cancel();
  }

  void stopListening() async {
    await stt.stop();
    setState(() {});
  }

  void initSpeech() async {
    speechEnabled = await stt.initialize(
      onError: errorListener,
    );

    setState(() {});
  }

  void getMainSubject() async {
    await FirebaseFirestore.instance
        .collection('mainSubject')
        .get()
        .then((value) {
      value.docs.forEach((element) {
        mainSubjects.add(Filter(element.id, element.get('title')));
      });
    });

    setState(() {});
  }

  void getLevel() async {
    levels.clear();

    await FirebaseFirestore.instance
        .collection('mainSubject')
        .doc(selectedMainSubject!.id)
        .collection('level')
        .get()
        .then((value) {
      value.docs.forEach((element) {
        levels.add(Filter(element.id, element.get('title')));
      });
    });

    setState(() {});
  }

  void getSubject() async {
    subjects.clear();

    await FirebaseFirestore.instance
        .collection('mainSubject')
        .doc(selectedMainSubject!.id)
        .collection('level')
        .doc(selectedLevel!.id)
        .collection('subject')
        .get()
        .then((value) {
      value.docs.forEach((element) {
        subjects.add(Filter(element.id, element.get('title')));
      });
    });

    setState(() {});
  }

  void getQuestions() async {
    questions.clear();

    await FirebaseFirestore.instance
        .collection('mainSubject')
        .doc(selectedMainSubject!.id)
        .collection('level')
        .doc(selectedLevel!.id)
        .collection('subject')
        .doc(selectedSubject!.id)
        .collection('quiz')
        .get()
        .then((data) {
      data.docs.forEach((quiz) {
        questions.add(QuizModel(
            quiz.id, quiz.get('question'), quiz.get('answer'), 1, "empty"));
      });
    });
    listening = true;
    setState(() {});
    sayQuestion(questions[currentQuestion].question);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.width * .025,
          bottom: MediaQuery.of(context).size.width * .025,
          left: MediaQuery.of(context).size.width * .07,
          right: MediaQuery.of(context).size.width * .07),
      child: Column(
        children: [
          Header(),
          SizedBox(height: 24),
          Divider(),
          SizedBox(height: MediaQuery.of(context).size.width * .025),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withOpacity(.25)),
                ),
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Main subject',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                    SizedBox(height: 16),
                    Wrap(
                      runSpacing: 8,
                      spacing: 8,
                      children: mainSubjects.map((e) {
                        return ChoiceChip(
                          backgroundColor: Colors.grey.withOpacity(.15),
                          selectedColor: Theme.of(context).primaryColor,
                          labelStyle: TextStyle(
                            color: selectedMainSubject == e
                                ? Colors.white
                                : Colors.black,
                          ),
                          selected: selectedMainSubject == e,
                          onSelected: (v) {
                            selectedMainSubject = e;
                            selectedSubject = null;
                            selectedLevel = null;
                            setState(() {});
                            getLevel();
                          },
                          label: Text(e.title),
                        );
                      }).toList(),
                    ),
                    selectedMainSubject == null
                        ? SizedBox()
                        : SizedBox(height: 24),
                    selectedMainSubject == null
                        ? SizedBox()
                        : Text(
                            'Level',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                          ),
                    selectedMainSubject == null
                        ? SizedBox()
                        : SizedBox(height: 16),
                    selectedMainSubject == null
                        ? SizedBox()
                        : Wrap(
                            runSpacing: 8,
                            spacing: 8,
                            children: levels.map((e) {
                              return ChoiceChip(
                                backgroundColor: Colors.grey.withOpacity(.15),
                                selectedColor: Theme.of(context).primaryColor,
                                labelStyle: TextStyle(
                                  color: selectedLevel == e
                                      ? Colors.white
                                      : Colors.black,
                                ),
                                selected: selectedLevel == e,
                                onSelected: (v) {
                                  selectedLevel = e;
                                  selectedSubject = null;
                                  setState(() {});
                                  getSubject();
                                },
                                label: Text(e.title),
                              );
                            }).toList(),
                          ),
                    selectedLevel == null ? SizedBox() : SizedBox(height: 24),
                    selectedLevel == null
                        ? SizedBox()
                        : Text(
                            'Subject',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                          ),
                    selectedLevel == null ? SizedBox() : SizedBox(height: 16),
                    selectedLevel == null
                        ? SizedBox()
                        : Wrap(
                            runSpacing: 8,
                            spacing: 8,
                            children: subjects.map((e) {
                              return ChoiceChip(
                                backgroundColor: Colors.grey.withOpacity(.15),
                                selectedColor: Theme.of(context).primaryColor,
                                labelStyle: TextStyle(
                                  color: selectedSubject == e
                                      ? Colors.white
                                      : Colors.black,
                                ),
                                selected: selectedSubject == e,
                                onSelected: (v) {
                                  selectedSubject = e;
                                  setState(() {});
                                },
                                label: Text(e.title),
                              );
                            }).toList(),
                          ),
                    selectedSubject == null ? SizedBox() : SizedBox(height: 24),
                    selectedSubject == null
                        ? SizedBox()
                        : InkWell(
                            onTap: () {
                              getQuestions();
                            },
                            child: Container(
                              height: 44,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(32),
                                color: Theme.of(context).primaryColor,
                              ),
                              child: Center(
                                child: Text('Get Questions',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
              SizedBox(width: 48),
              questions.isNotEmpty
                  ? Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedContainer(
                            duration: Duration(seconds: listening ? 0 : 4),
                            width: duration == 5 ? 500.0 : 0.0,
                            height: 4,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(32),
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          SizedBox(height: 16),
                          listening
                              ? Text('')
                              : Text('Answer Time: $duration',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  )),
                          SizedBox(height: 32),
                          Text(
                            'QUESTION',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                          ),
                          SizedBox(height: 16),
                          Text(
                            questions[currentQuestion].question,
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 24),
                          Shimmer.fromColors(
                            baseColor: Colors.orange,
                            highlightColor: Colors.red,
                            enabled: listening,
                            child: Container(
                              width: 150,
                              padding: EdgeInsets.only(
                                  left: 16, right: 16, top: 10, bottom: 10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(context).primaryColor,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.volume_down_rounded),
                                    SizedBox(width: 8),
                                    Text(
                                      listening ? 'Listening...' : 'Listen',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 24),
                          listening
                              ? Container()
                              : Text(
                                  'ANSWER',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey),
                                ),
                          lastWords.trim().isEmpty
                              ? SizedBox()
                              : SizedBox(height: 16),
                          lastWords.trim().isEmpty || listening
                              ? SizedBox()
                              : Text(
                                  lastWords,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                          SizedBox(height: 24),
                          listening
                              ? Container()
                              : Shimmer.fromColors(
                                  baseColor: Colors.cyan,
                                  highlightColor:
                                      Theme.of(context).primaryColor,
                                  enabled: stt.isListening,
                                  child: Container(
                                    width: 150,
                                    padding: EdgeInsets.only(
                                        left: 16,
                                        right: 16,
                                        top: 10,
                                        bottom: 10),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Theme.of(context).primaryColor,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.mic),
                                          SizedBox(width: 8),
                                          Text(
                                            stt.isListening
                                                ? 'Speaking...'
                                                : 'Speak',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    )
                  : Container(),
              SizedBox(width: 48),
              questions.isEmpty
                  ? Container()
                  : Container(
                      width: 250,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.withOpacity(.25)),
                      ),
                      padding: EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Question list',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                          ),
                          SizedBox(height: 16),
                          ListView.builder(
                            itemCount: questions.length,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (BuildContext context, int index) {
                              var item = questions[index];
                              var color = item.status == 1
                                  ? Theme.of(context).primaryColor
                                  : item.status == 0
                                      ? Colors.grey
                                      : Colors.redAccent;
                              return Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Row(
                                  children: [
                                    Icon(
                                      item.status == 0
                                          ? Icons.remove_circle
                                          : item.status == 1
                                              ? Icons.check_circle
                                              : Icons.clear,
                                      size: 20,
                                      color: color,
                                    ),
                                    SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        item.question,
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: color,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
              SizedBox(width: 16),
            ],
          )
        ],
      ),
    ));
  }

  Soundpool({streamType}) {}
}

class Header extends StatelessWidget {
  const Header({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          'assets/logo.png',
          width: 35,
          height: 35,
        ),
        SizedBox(width: 24),
        Text(
          'Flashcast',
          style: TextStyle(
              fontSize: 20, color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        Spacer(),
        InkWell(
          onTap: () async {
            Navigator.of(context).pushReplacement(
                CupertinoPageRoute(builder: (context) => Quiz()));
          },
          child: Container(
            padding: EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                'Logorut',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 16),
      ],
    );
  }
}