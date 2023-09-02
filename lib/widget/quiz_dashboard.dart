import 'package:flutter/material.dart';
import 'package:quiz/models/completed_quiz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class QuizDashboard extends StatelessWidget {
  final List<CompletedQuiz> completedQuizzes;

  QuizDashboard({required this.completedQuizzes});

  @override
  Widget build(BuildContext context) {
    List<CompletedQuiz> latestQuizzes =
        completedQuizzes.reversed.take(5).toList().reversed.toList();
    latestQuizzes.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    double textSize = MediaQuery.of(context).size.height * 0.02;
    double radiusSize = MediaQuery.of(context).size.height * 0.03;
    String decimalToPercentage(double decimalValue) {
      double percentageValue = decimalValue * 100;
      return percentageValue.toStringAsFixed(1) + '%';
    }

    return Column(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.8,
          child: ListView.builder(
            itemCount: latestQuizzes.length,
            itemBuilder: (context, index) {
              final quiz = latestQuizzes[index];
              final correctAnswers = quiz.score;
              final wrongAnswers = quiz.totalQuestions - quiz.score;
              final timeCompleted = quiz.timestamp;
              final percentageScore =
                  decimalToPercentage(quiz.score / quiz.totalQuestions);

              return Card(
                elevation: 2,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.2,
                  child: ListTile(
                    title: Text(
                      quiz.quizName,
                      textAlign: TextAlign.center,
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Total Questions: ${quiz.totalQuestions}',
                                    style: TextStyle(
                                      fontSize: textSize,
                                    )),
                                Text('Correct Answers: $correctAnswers',
                                    style: TextStyle(
                                      fontSize: textSize,
                                    )),
                                Text('Wrong Answers: $wrongAnswers',
                                    style: TextStyle(
                                      fontSize: textSize,
                                    )),
                                Text('Time Completed: $timeCompleted',
                                    style: TextStyle(
                                      fontSize: textSize,
                                    ))
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: PieChart(
                                    PieChartData(
                                      sections: [
                                        PieChartSectionData(
                                            value: correctAnswers.toDouble(),
                                            color: Colors.green,
                                            radius: radiusSize),
                                        PieChartSectionData(
                                          value: wrongAnswers.toDouble(),
                                          color: Colors.red,
                                          radius: radiusSize,
                                        ),
                                      ],
                                      borderData: FlBorderData(show: false),
                                      sectionsSpace: 10,
                                      centerSpaceRadius: radiusSize * 1,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(25.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Score',
                                        style: TextStyle(
                                          fontSize: textSize,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xff02c39a),
                                        ),
                                      ),
                                      Text(
                                        "$percentageScore",
                                        style: TextStyle(
                                          fontSize: textSize,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xfff8b250),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
