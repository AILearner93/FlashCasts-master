import 'package:flutter/material.dart';
import 'package:quiz/models/completed_quiz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class QuizDashboard extends StatelessWidget {
  final List<CompletedQuiz> completedQuizzes;

  QuizDashboard({required this.completedQuizzes});

  @override
  Widget build(BuildContext context) {
    List<CompletedQuiz> latestQuizzes = completedQuizzes;

    return Column(
      children: [
        Container(
          height: 300,
          child: ListView.builder(
            itemCount: latestQuizzes.length,
            itemBuilder: (context, index) {
              final quiz = latestQuizzes[index];
              final correctAnswers = quiz.score;
              final wrongAnswers = quiz.totalQuestions - quiz.score;

              return Card(
                elevation: 2,
                child: ListTile(
                  title: Text(quiz.quizName),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Total Questions: ${quiz.totalQuestions}'),
                              Text('Correct Answers: $correctAnswers'),
                              Text('Wrong Answers: $wrongAnswers'),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: PieChart(
                                    PieChartData(
                                      sections: [
                                        PieChartSectionData(
                                          value: correctAnswers.toDouble(),
                                          color: Colors.green,
                                          radius: 30,
                                        ),
                                        PieChartSectionData(
                                          value: wrongAnswers.toDouble(),
                                          color: Colors.red,
                                          radius: 30,
                                        ),
                                      ],
                                      borderData: FlBorderData(show: false),
                                      sectionsSpace: 0,
                                      centerSpaceRadius: 40,
                                    ),
                                  ),
                                ),
                              ),
                              Column(
                                children: [
                                  Text(
                                    'Correct',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xff02c39a),
                                    ),
                                  ),
                                  Text(
                                    'Wrong',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xfff8b250),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
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
