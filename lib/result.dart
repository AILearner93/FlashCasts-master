import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quiz/quiz.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:text_to_speech/text_to_speech.dart';

class Result extends StatefulWidget {
  final List<QuizModel> questions;
  final Filter selectedMainSubject;
  final Filter selectedLevel;
  final Filter selectedSubject;

  const Result(
      {Key? key,
      required this.questions,
      required this.selectedMainSubject,
      required this.selectedLevel,
      required this.selectedSubject})
      : super(key: key);

  @override
  _ResultState createState() => _ResultState();
}

class _ResultState extends State<Result> {
  TextToSpeech tts = TextToSpeech();
  SpeechToText stt = SpeechToText();
  bool speechEnabled = false;
  String lastWords = '';

  speakResult() async {
    num length =
        'You have got ${widget.questions.where((element) => element.status == 1).length} out of ${widget.questions.length}. Would you like to restart?'
                .trim()
                .length *
            .075;
    int delay = length.round();

    tts.setLanguage('en-US');
    tts.speak(
        'You have got ${widget.questions.where((element) => element.status == 1).length} out of ${widget.questions.length}. Would you like to restart?');

    await Future.delayed(Duration(seconds: delay));

    listenAnswer();
  }

  void listenAnswer() async {
    await stt.stop();
    lastWords = '';
    setState(() {});
    await stt.listen(onResult: onSpeechResult, cancelOnError: true);
    setState(() {});
  }

  void onSpeechResult(SpeechRecognitionResult result) async {
    setState(() {
      lastWords = result.recognizedWords;
    });

    if (lastWords.trim().toLowerCase().contains('restart') ||
        lastWords.trim().toLowerCase().contains('yes')) {
      await stt.stop();
      Navigator.of(context)
          .pushReplacement(CupertinoPageRoute(builder: (context) => Quiz()));
    }
  }

  void errorListener(SpeechRecognitionError error) {
    print(error);
  }

  void initSpeech() async {
    speechEnabled = await stt.initialize(
      onError: errorListener,
    );

    speakResult();
    setState(() {});
  }

  @override
  void initState() {
    initSpeech();
    super.initState();
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
            Text(
              'You have got ${widget.questions.where((element) => element.status == 1).length} out of ${widget.questions.length}. Would you like to restart?',
              style: TextStyle(fontSize: 20, color: Colors.black87),
            ),
            SizedBox(height: MediaQuery.of(context).size.width * .025),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withOpacity(.25)),
              ),
              padding: EdgeInsets.all(24),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Questions',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                        ),
                        SizedBox(height: 16),
                        ListView.separated(
                          separatorBuilder: (v, i) => Divider(),
                          itemCount: widget.questions.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            var item = widget.questions[index];
                            var color = item.status == 1
                                ? Theme.of(context).primaryColor
                                : item.status == 0
                                    ? Colors.grey
                                    : Colors.redAccent;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 8),
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Answers',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                        ),
                        SizedBox(height: 16),
                        ListView.separated(
                          separatorBuilder: (v, i) => Divider(),
                          itemCount: widget.questions.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            var item = widget.questions[index];
                            var color = item.status == 1
                                ? Theme.of(context).primaryColor
                                : item.status == 0
                                    ? Colors.grey
                                    : Colors.redAccent;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 8),
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
                                      item.answer,
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ' Your Answers',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                        ),
                        SizedBox(height: 16),
                        ListView.separated(
                          separatorBuilder: (v, i) => Divider(),
                          itemCount: widget.questions.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            var item = widget.questions[index];
                            var color = item.status == 1
                                ? Theme.of(context).primaryColor
                                : item.status == 0
                                    ? Colors.grey
                                    : Colors.redAccent;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 8),
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
                                      item.spokenanswer,
                                      maxLines: 2,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
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
                'Quiz',
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
