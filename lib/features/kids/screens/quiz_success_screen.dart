import 'dart:math' as math;

import 'package:ecommerce_app/features/kids/models/kids_story_detail_model.dart';
import 'package:ecommerce_app/features/kids/models/kids_story_quiz_result_model.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/constants/image_strings.dart';
import 'package:ecommerce_app/utils/helpers/app_language_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuizSuccessScreen extends StatelessWidget {
  const QuizSuccessScreen({
    super.key,
    required this.result,
    required this.storyTitle,
    required this.questions,
  });

  final KidsStoryQuizResult result;
  final String storyTitle;
  final List<KidsStoryQuestion> questions;

  @override
  Widget build(BuildContext context) {
    final score = result.scorePercent.clamp(0, 100).toInt();
    final totalQuestions = result.totalQuestions > 0
        ? result.totalQuestions
        : math.max(result.answers.length, questions.length);
    final correctCount = result.correctCount.clamp(0, totalQuestions).toInt();
    final resolvedStoryTitle =
        storyTitle.isNotEmpty ? storyTitle : 'Kids Story Quiz';

    return Scaffold(
      backgroundColor: const Color(0xFFEFF7F4),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  PImages.mosqueBackground,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.06),
                        Colors.white.withValues(alpha: 0.36),
                        Colors.white.withValues(alpha: 0.10),
                      ],
                      stops: const [0, 0.58, 1],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 22, 18, 20),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final mosqueHeaderHeight = (constraints.maxHeight * 0.25)
                          .clamp(160.0, 220.0)
                          .toDouble();

                      return Column(
                        children: [
                          SizedBox(height: mosqueHeaderHeight),
                          Expanded(
                            child: _ScrollableResultPanel(
                              storyTitle: resolvedStoryTitle,
                              score: score,
                              correctCount: correctCount,
                              totalQuestions: totalQuestions,
                              result: result,
                              questions: questions,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuizResultHeader extends StatelessWidget {
  const _QuizResultHeader({required this.storyTitle});

  final String storyTitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Quiz Completed!',
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            color: const Color(0xFF0C4D3D),
            fontSize: 30,
            fontWeight: FontWeight.w800,
            height: 1.08,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          constraints: const BoxConstraints(maxWidth: 360),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: const Color(0xFFD7E8E2).withValues(alpha: 0.92),
            ),
          ),
          child: Text(
            storyTitle,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: const Color(0xFF4E5661),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.28,
            ),
          ),
        ),
      ],
    );
  }
}

class _ScrollableResultPanel extends StatelessWidget {
  const _ScrollableResultPanel({
    required this.storyTitle,
    required this.score,
    required this.correctCount,
    required this.totalQuestions,
    required this.result,
    required this.questions,
  });

  final String storyTitle;
  final int score;
  final int correctCount;
  final int totalQuestions;
  final KidsStoryQuizResult result;
  final List<KidsStoryQuestion> questions;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFFD7E8E2),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1C5D4E).withValues(alpha: 0.10),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(27),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _QuizResultHeader(storyTitle: storyTitle),
              const SizedBox(height: 20),
              _ScoreCard(
                score: score,
                correctCount: correctCount,
                totalQuestions: totalQuestions,
              ),
              const SizedBox(height: 18),
              _ResultMessage(score: score),
              const SizedBox(height: 18),
              _AnswersCard(
                answers: result.answers,
                questions: questions,
              ),
              const SizedBox(height: 20),
              _PrimaryActionButton(
                text: 'Try Again',
                icon: Icons.refresh_rounded,
                onPressed: () => Navigator.of(context).pop('retry'),
              ),
              const SizedBox(height: 12),
              _SecondaryActionButton(
                text: 'Back',
                onPressed: () => Navigator.of(context).pop('done'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({
    required this.score,
    required this.correctCount,
    required this.totalQuestions,
  });

  final int score;
  final int correctCount;
  final int totalQuestions;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD7E8E2), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1C5D4E).withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '$score%',
            style: GoogleFonts.poppins(
              color: const Color(0xFF0C4D3D),
              fontSize: 54,
              fontWeight: FontWeight.w800,
              height: 0.95,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'You answered $correctCount of $totalQuestions correctly',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: const Color(0xFF56655F),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: score / 100,
              minHeight: 10,
              backgroundColor: const Color(0xFFE6F1ED),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF329070)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultMessage extends StatelessWidget {
  const _ResultMessage({required this.score});

  final int score;

  String get _message {
    if (score >= 90) {
      return 'Excellent work! You remembered the story beautifully.';
    }
    if (score >= 70) {
      return 'Great effort! A quick review can make it even stronger.';
    }
    if (score >= 50) {
      return 'Good try! Read the story once more and try again.';
    }
    return 'Keep learning. Every story becomes easier with practice.';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E7).withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEBD59B)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            color: Color(0xFFC69628),
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _message,
              style: GoogleFonts.poppins(
                color: const Color(0xFF725813),
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswersCard extends StatelessWidget {
  const _AnswersCard({
    required this.answers,
    required this.questions,
  });

  final List<KidsStoryQuizAnswerResult> answers;
  final List<KidsStoryQuestion> questions;

  @override
  Widget build(BuildContext context) {
    final textLanguageCode = AppLanguageHelper.textLanguageCode();
    final questionById = {
      for (final question in questions) question.id: question,
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD7E8E2), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question Details',
            style: GoogleFonts.poppins(
              color: const Color(0xFF0C4D3D),
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          if (answers.isEmpty)
            const Text('No answer details available.')
          else
            ...List.generate(answers.length, (index) {
              final answer = answers[index];
              final question = questionById[answer.questionId];
              final questionText = question == null
                  ? 'Question ${index + 1}'
                  : AppLanguageHelper.pickText(
                      question.question,
                      textLanguageCode,
                    );
              final selectedText = _optionText(
                question,
                answer.selectedOption,
                textLanguageCode,
              );
              final correctText = _optionText(
                question,
                answer.correctOption,
                textLanguageCode,
              );

              return _AnswerResultTile(
                number: index + 1,
                question: questionText.isNotEmpty
                    ? questionText
                    : 'Question ${index + 1}',
                selectedAnswer: selectedText,
                correctAnswer: correctText,
                isCorrect: answer.isCorrect,
              );
            }),
        ],
      ),
    );
  }

  String _optionText(
    KidsStoryQuestion? question,
    String optionKey,
    String languageCode,
  ) {
    final option = question?.options[optionKey];
    final text = option == null
        ? ''
        : AppLanguageHelper.pickText(option.text, languageCode);

    if (text.isNotEmpty) {
      return text;
    }

    return optionKey.isNotEmpty ? optionKey.toUpperCase() : 'Not answered';
  }
}

class _AnswerResultTile extends StatelessWidget {
  const _AnswerResultTile({
    required this.number,
    required this.question,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.isCorrect,
  });

  final int number;
  final String question;
  final String selectedAnswer;
  final String correctAnswer;
  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    final statusColor =
        isCorrect ? const Color(0xFF329070) : const Color(0xFFE48586);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$number',
                  style: GoogleFonts.poppins(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  question,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF173D34),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: statusColor,
                size: 22,
              ),
            ],
          ),
          const SizedBox(height: 10),
          _AnswerLine(label: 'Your answer', value: selectedAnswer),
          if (!isCorrect) ...[
            const SizedBox(height: 6),
            _AnswerLine(label: 'Correct answer', value: correctAnswer),
          ],
        ],
      ),
    );
  }
}

class _AnswerLine extends StatelessWidget {
  const _AnswerLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: GoogleFonts.poppins(
          color: const Color(0xFF5B6863),
          fontSize: 12,
          height: 1.35,
        ),
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 22),
        label: Text(text),
        style: FilledButton.styleFrom(
          backgroundColor: PColors.primary,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  const _SecondaryActionButton({
    required this.text,
    required this.onPressed,
  });

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF0C4D3D),
          side: const BorderSide(color: PColors.primary, width: 1.2),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(text),
      ),
    );
  }
}
