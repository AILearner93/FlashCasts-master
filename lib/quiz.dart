import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quiz/compareWordFunc.dart';
import 'package:quiz/landing_page/auth/vm/auth_vm.dart';
import 'package:quiz/userprofile.dart';
import 'package:quiz/result.dart';
import 'package:shimmer/shimmer.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:text_to_speech/text_to_speech.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';
import 'package:provider/provider.dart';

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
bool showAnswerSection = false;
bool showColumn = true;

String lastWords = '';
String localeId = '';
String? selectedChoice;
//replaceAll(' ', '').

String currentUserID = "testUserID123";
String currentUserName = "testUser";

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

class QuizStatus {
  static const notAnswered = 'NotAnswered';
  static const correct = 'Correct';
  static const incorrect = 'Incorrect';
}

class QuizModel {
  final String id;
  final String question;
  final String answer;
  var spokenanswer;
  String status;

  QuizModel(
      this.id, this.question, this.answer, this.status, this.spokenanswer);
}

class Filter {
  final String id;
  final String title;

  Filter(this.id, this.title);
}

AudioPlayer audioPlayer = AudioPlayer(mode: PlayerMode.LOW_LATENCY);

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
    questions = [];
    super.initState();
    flutterTts = FlutterTts();
    flutterTts.setLanguage("en-US");
    flutterTts.setPitch(1.0);
    flutterTts.setSpeechRate(1);
    getMainSubject();
    getSubject();
    flutterTts.setCompletionHandler(() {
      print("TTS Finished Speaking");
      _ttsCompleter.complete();
    });
    showColumn = true;
    Set<Filter> mainSubjectsSet = {};
    selectedMainSubject = null;
    selectedSubject = null;
    selectedLevel = null;
    initSpeech();
    context.read<FbAuth>().fetchUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    duration = 5;
    currentQuestion = 0; // Resetting the duration here
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
    flutterTts.setCompletionHandler(() {
      print("TTS Finished Speaking");
      _ttsCompleter.complete();
    });
    _ttsCompleter = Completer<void>();

    ///this buttom
    flutterTts.stop();
    setState(() {});
    try {
      // Start the TTS operation
      flutterTts.speak(question);
      // Wait for its completion or for the 10-second timeout, whichever comes first
      await Future.any(
              [_ttsCompleter.future, Future.delayed(Duration(seconds: 10))])
          .then((result) {
        if (result == null) {
          throw TimeoutException("TTS took too long!");
        }
      });
    } on TimeoutException catch (e) {
      // Handle the timeout exception here
      print(e.message); // Example: prints "TTS took too long!"
      // Here, you can also stop the TTS if needed
      flutterTts.stop();
    }
    print("questions");
    ;
    print("sound3");
    AudioCache player = new AudioCache();
    print("sound4");
    const alarmAudioPath = "sound.wav";
    await player.play(alarmAudioPath);

    lastWords = '';
    listening = false;

    setState(() {});

    listenAnswer();

    for (int i = 0; i < 5; i++) {
      await Future.delayed(Duration(seconds: 1));

      String trimmedLastWords = lastWords.trim().toLowerCase();

      if (trimmedLastWords == questions[currentQuestion].answer.toLowerCase() ||
          trimmedLastWords == "true" ||
          trimmedLastWords == "false") {
        duration = 0;
        i = 5;
      } else {
        duration--;
      }

      setState(() {});
    }

    stt.stop();

    if (lastWords.trim().isEmpty) {
      questions[currentQuestion].status = QuizStatus.notAnswered;
    } else {
      if (lastWords.trim().toLowerCase() ==
          questions[currentQuestion].answer.toLowerCase()) {
        questions[currentQuestion].status = QuizStatus.correct;
      } else {
        questions[currentQuestion].status = QuizStatus.incorrect;
      }
    }

    if (questions.last.question == question) {
      // Calculate the score here
      int score = questions.where((q) => q.status == QuizStatus.correct).length;
      int totalQuestions = questions.length;

      // Store the result
      await storeQuizResults(score, totalQuestions);

      Navigator.of(context).pushReplacement(CupertinoPageRoute(
          builder: (context) => Result(
              questions: questions,
              selectedMainSubject: selectedMainSubject!,
              selectedLevel: selectedLevel!,
              selectedSubject: selectedSubject!)));
      dispose();
    } else {
      lastWords = '';
      duration = 5;
      listening = true;
      showAnswerSection = true;
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
      //print("this is spat out from the comparison: $Compresult");
      //print("this is was what was interpreted $lastWords");
      lastWords = Compresult;
      questions[currentQuestion].spokenanswer = lastWords;
      //print(questions[currentQuestion].spokenanswer);
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

  StreamSubscription? mainSubjectSubscription;

  void getMainSubject() async {
    Map<String, Filter> mainSubjectsMap = {}; // Declare a Map here

    // Fetching from mainSubject collection
    QuerySnapshot mainSubjectSnapshot =
        await FirebaseFirestore.instance.collection('mainSubject').get();
    for (var doc in mainSubjectSnapshot.docs) {
      String title = doc.get('title');
      mainSubjectsMap[title] = Filter(doc.id, title);
    }

    // Fetching from Europe_Quiz collection
    QuerySnapshot europeQuizSnapshot =
        await FirebaseFirestore.instance.collection('Europe_Quiz').get();
    for (var doc in europeQuizSnapshot.docs) {
      String title = doc.get('mainSubject');
      mainSubjectsMap[title] = Filter(doc.id, title);
    }

    mainSubjects = mainSubjectsMap.values
        .toList(); // Convert the Map values to a List here
    setState(() {});
  }

  @override
  void dispose() {
    mainSubjectSubscription?.cancel();
    super.dispose();
  }

  void resetForm() {
    selectedChoice = null;
    showAnswerSection = false;
    setState(() {});
  }

  Future<void> storeQuizResults(int score, int totalQuestions) async {
    try {
      CollectionReference userScores =
          FirebaseFirestore.instance.collection('userScores');

      // Assuming you have a variable called currentUserID for the logged-in user
      DocumentReference userDocRef = userScores.doc(currentUserID);

      // Check if user document exists
      DocumentSnapshot userDocSnap = await userDocRef.get();

      if (!userDocSnap.exists) {
        // If user document doesn't exist, create one with basic user data
        await userDocRef.set({
          'userID': currentUserID,
          'userName': currentUserName, // Assuming you have this variable
        });
      }

      // Add quiz result to the quizResults sub-collection
      await userDocRef.collection('quizResults').add({
        'mainSubject': selectedMainSubject!.title,
        'level': selectedLevel!.title,
        'subject': selectedSubject!.title,
        'score': score,
        'totalQuestions': totalQuestions,
        'dateTaken': Timestamp.now(),
      });
    } catch (e) {
      print("Error storing quiz results: $e");
    }
  }

  void getLevel() async {
    Map<String, Filter> levelsMap = {}; // Declare a Map here

    // Ensure that selectedMainSubject is not null before proceeding
    if (selectedMainSubject != null) {
      // Fetching from level sub-collection under mainSubject
      QuerySnapshot levelSnapshot = await FirebaseFirestore.instance
          .collection('mainSubject')
          .doc(selectedMainSubject!.id)
          .collection('level')
          .get();
      for (var doc in levelSnapshot.docs) {
        String title = doc.get('title');
        levelsMap[title] = Filter(doc.id, title);
      }

      // Fetching from Europe_Quiz collection
      QuerySnapshot europeQuizSnapshot = await FirebaseFirestore.instance
          .collection('Europe_Quiz')
          .where('mainSubject', isEqualTo: selectedMainSubject!.title)
          .get();
      for (var doc in europeQuizSnapshot.docs) {
        String title = doc.get('level');
        levelsMap[title] = Filter(doc.id, title);
      }

      levels =
          levelsMap.values.toList(); // Convert the Map values to a List here
      setState(() {});
    }
  }

  void getSubject() async {
    Map<String, Filter> subjectsMap = {}; // Declare a Map here

    // Ensure that selectedMainSubject and selectedLevel are not null before proceeding
    if (selectedMainSubject != null && selectedLevel != null) {
      // Fetching from subject sub-collection under level
      QuerySnapshot subjectSnapshot = await FirebaseFirestore.instance
          .collection('mainSubject')
          .doc(selectedMainSubject!.id)
          .collection('level')
          .doc(selectedLevel!.id)
          .collection('subject')
          .get();
      for (var doc in subjectSnapshot.docs) {
        String title = doc.get('title');
        subjectsMap[title] = Filter(doc.id, title);
      }

      // Fetching from Europe_Quiz collection
      QuerySnapshot europeQuizSnapshot = await FirebaseFirestore.instance
          .collection('Europe_Quiz')
          .where('mainSubject', isEqualTo: selectedMainSubject!.title)
          .where('level', isEqualTo: selectedLevel!.title)
          .get();
      for (var doc in europeQuizSnapshot.docs) {
        String title = doc.get('subject');
        subjectsMap[title] = Filter(doc.id, title);
      }

      subjects =
          subjectsMap.values.toList(); // Convert the Map values to a List here
      setState(() {});
    }
  }

  void getQuestions() async {
    Map<String, QuizModel> questionsMap = {}; // Declare a Map here

    // Ensure that selectedMainSubject, selectedLevel, and selectedSubject are not null before proceeding
    if (selectedMainSubject != null &&
        selectedLevel != null &&
        selectedSubject != null) {
      // Fetching from Europe_Quiz collection
      QuerySnapshot europeQuizSnapshot = await FirebaseFirestore.instance
          .collection('Europe_Quiz')
          .where('mainSubject', isEqualTo: selectedMainSubject!.title)
          .where('level', isEqualTo: selectedLevel!.title)
          .where('subject',
              isEqualTo: selectedSubject!.title) // Filter by subject
          .get();
      for (var doc in europeQuizSnapshot.docs) {
        List<Map<String, dynamic>> quizData =
            List<Map<String, dynamic>>.from(doc.get('questions'));
        for (var q in quizData) {
          questionsMap[q['question']] = QuizModel(doc.id, q['question'],
              q['answer'], QuizStatus.notAnswered, "empty");
        }
      }

      questions =
          questionsMap.values.toList(); // Convert the Map values to a List here
      questions.shuffle();

      listening = true;
      setState(() {});
      sayQuestion(questions[currentQuestion].question);
    }
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
        //these are the columns for the visual on the left with the quizes
        children: [
          Header(),
          SizedBox(height: 24),
          Divider(),
          SizedBox(height: MediaQuery.of(context).size.width * .025),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              showColumn
                  ? Container(
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
                            //this the wrap for teh questions on the left in the level
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
                                  //this is the wrap for the subjects
                                  runSpacing: 8,
                                  spacing: 8,
                                  children: levels.map((e) {
                                    return ChoiceChip(
                                      backgroundColor:
                                          Colors.grey.withOpacity(.15),
                                      selectedColor:
                                          Theme.of(context).primaryColor,
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
                          selectedLevel == null
                              ? SizedBox()
                              : SizedBox(height: 24),
                          selectedLevel == null
                              ? SizedBox()
                              : Text(
                                  'Subject',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey),
                                ),
                          selectedLevel == null
                              ? SizedBox()
                              : SizedBox(height: 16),
                          selectedLevel == null
                              ? SizedBox()
                              : Wrap(
                                  //wrap for get questiosn
                                  runSpacing: 8,
                                  spacing: 8,
                                  children: subjects.map((e) {
                                    return ChoiceChip(
                                      backgroundColor:
                                          Colors.grey.withOpacity(.15),
                                      selectedColor:
                                          Theme.of(context).primaryColor,
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
                          selectedSubject == null
                              ? SizedBox()
                              : SizedBox(height: 24),
                          selectedSubject == null
                              ? SizedBox()
                              : InkWell(
                                  onTap: () async {
                                    await flutterTts
                                        .stop(); // Stop the Text-to-Speech
                                    await stt.stop();
                                    Future.delayed(Duration(seconds: 1));
                                    getQuestions();
                                    showAnswerSection =
                                        true; //display the asnwer section
                                    showColumn =
                                        false; // Hide the column when it is pressed
                                    setState(
                                        () {}); //this runs getquestions function
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
                    )
                  : Container(),
              SizedBox(width: 30),
              questions.isNotEmpty
                  ? Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedContainer(
                            duration: Duration(seconds: listening ? 0 : 4),
                            width: duration == 5 ? 500.0 : 0.0,
                            height: 4, //thickness of bar at top
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
                              width: 200,
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
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 1,
                                          vertical:
                                              1), // Adjust as needed // Optional: if you want to visualize the box
                                      child: Text(
                                        listening
                                            ? 'Reading Question'
                                            : 'Question Read',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 100),
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
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Shimmer.fromColors(
                                      baseColor: Colors.orange,
                                      highlightColor: Colors.red,
                                      enabled: listening,
                                      child: Container(
                                        //container for the speaking box
                                        width: 200,
                                        padding: EdgeInsets.only(
                                            left: 16,
                                            right: 16,
                                            top: 10,
                                            bottom: 10),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color:
                                                Theme.of(context).primaryColor,
                                            width: 2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(4),
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
                                    ), //end of speaking container box
                                    SizedBox(
                                        height:
                                            10), // Give some space between speaking box and the
                                    if (showAnswerSection) // Assuming you've set up this variable as explained in previous messages
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          ChoiceChip(
                                            label: Text(
                                              "True",
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: selectedChoice == "True"
                                                    ? Colors.white
                                                    : Colors
                                                        .black, // Adjust the text color based on the selection state
                                              ),
                                            ),
                                            backgroundColor:
                                                Colors.grey.withOpacity(.15),
                                            selectedColor:
                                                Theme.of(context).primaryColor,
                                            selected: selectedChoice == "True",
                                            onSelected: (bool selected) {
                                              setState(() {
                                                selectedChoice = "True";
                                                lastWords = "true";
                                                questions[currentQuestion]
                                                    .spokenanswer = lastWords;
                                                resetForm();
                                              });
                                            },
                                          ),
                                          SizedBox(
                                              width:
                                                  20), // Spacing between the chips
                                          ChoiceChip(
                                            label: Text(
                                              "False",
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: selectedChoice == "False"
                                                    ? Colors.white
                                                    : Colors
                                                        .black, // Adjust the text color based on the selection state
                                              ),
                                            ),
                                            backgroundColor:
                                                Colors.grey.withOpacity(.15),
                                            selectedColor:
                                                Theme.of(context).primaryColor,
                                            selected: selectedChoice == "False",
                                            onSelected: (bool selected) {
                                              setState(() {
                                                selectedChoice = "False";
                                                lastWords = "false";
                                                questions[currentQuestion]
                                                    .spokenanswer = lastWords;
                                                resetForm();
                                              });
                                            },
                                          ),
                                        ],
                                      )
                                  ],
                                )
                        ], //need to keep up to here
                      ),
                    )
                  : Container(),
              SizedBox(width: 48),
              questions.isEmpty //does this if question is empty
                  ? Container() //this is the blank bit in the middle of the page
                  : Container(
                      //this container is for the question list width
                      width: MediaQuery.of(context).size.width * .1,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.withOpacity(.25)),
                      ),
                      padding: EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Question list',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16),
                          ListView.builder(
                            itemCount: questions.length,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (BuildContext context, int index) {
                              var item = questions[index];
                              var color = item.status == QuizStatus.notAnswered
                                  ? Theme.of(context)
                                      .primaryColor //going to this if it matches not answered
                                  : item.status ==
                                          QuizStatus
                                              .notAnswered //goign to this if its else
                                      ? Colors.grey
                                      : item.status == QuizStatus.correct
                                          ? Color.fromARGB(255, 7, 135, 3)
                                          : Colors.redAccent;
                              return Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      item.status == QuizStatus.notAnswered
                                          ? Icons.remove_circle
                                          : item.status == QuizStatus.correct
                                              ? Icons.check_circle
                                              : Icons.cancel,
                                      size: 20,
                                      color: color,
                                    ),
                                    SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        (index + 1).toString(),
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
              SizedBox(width: 30),
            ],
          ) //row of all things
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
                'Return',
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
        InkWell(
          onTap: () async {
            Navigator.of(context).pushReplacement(
                CupertinoPageRoute(builder: (context) => UserProfile()));
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
                'User',
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
