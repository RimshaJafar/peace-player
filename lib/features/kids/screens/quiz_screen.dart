import 'package:flutter/material.dart';
import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/common/widgets/containers/kids_screen_background.dart';
import 'package:ecommerce_app/common/widgets/loaders/loaders.dart';
import 'package:ecommerce_app/common/widgets/list_tiles/quiz_option_tile.dart';
import 'package:ecommerce_app/common/widgets/containers/icon_button_container.dart';
import 'package:ecommerce_app/features/kids/controllers/kids_stories_controller.dart';
import 'package:ecommerce_app/features/kids/models/kids_story_detail_model.dart';
import 'package:ecommerce_app/features/kids/models/kids_story_quiz_result_model.dart';
import 'package:ecommerce_app/features/kids/screens/quiz_success_screen.dart';
import 'package:ecommerce_app/utils/constants/text_direction.dart';
import 'package:ecommerce_app/utils/helpers/app_language_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/common/controllers/app_language_controller.dart';
import 'dart:async';

class QuizScreen extends StatefulWidget {
  const QuizScreen({
    super.key,
    this.categoryKey,
    this.storyId,
    this.storyTitle,
  });

  final String? categoryKey;
  final int? storyId;
  final String? storyTitle;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final KidsStoriesController _storiesController =
      Get.put(KidsStoriesController());
  final Map<int, String> _selectedAnswers = <int, String>{};
  int _currentQuestionIndex = 0;
  String? _selectedCategoryKey;
  StreamSubscription<String?>? _textLangSub;
  StreamSubscription<String?>? _titleLangSub;

  bool get _hasStoryContext =>
      widget.categoryKey != null && widget.storyId != null;

  @override
  void initState() {
    super.initState();
    if (_hasStoryContext) {
      _loadStoryDetail();
    } else {
      _prepareStandaloneQuizSelection();
    }
    // React to language changes so UI updates immediately
    final langController = Get.isRegistered<AppLanguageController>()
        ? Get.find<AppLanguageController>()
        : Get.put(AppLanguageController());
    _textLangSub =
        langController.textLanguageCode.listen((_) => setState(() {}));
    _titleLangSub =
        langController.titleLanguageCode.listen((_) => setState(() {}));
  }

  void _prepareStandaloneQuizSelection() {
    _selectedCategoryKey = null;
    _selectedAnswers.clear();
    _currentQuestionIndex = 0;
    _storiesController.storyDetail.value = null;
    _storiesController.storyDetailError.value = '';
    _storiesController.quizResult.value = null;
    _storiesController.quizAnalytics.value = null;
    _storiesController.quizError.value = '';
    _storiesController.analyticsError.value = '';

    if (_storiesController.categories.isNotEmpty ||
        _storiesController.isCategoriesLoading.value) {
      return;
    }

    _storiesController.fetchCategories();
  }

  Future<void> _loadStoryDetail() async {
    final categoryKey = widget.categoryKey;
    final storyId = widget.storyId;
    if (categoryKey == null || storyId == null) {
      return;
    }
    _storiesController.quizResult.value = null;
    _storiesController.quizAnalytics.value = null;
    await _storiesController.fetchStoryDetail(categoryKey, storyId);
    if (!mounted) {
      return;
    }
    setState(() {
      _currentQuestionIndex = 0;
      _selectedAnswers.clear();
    });
    _fetchQuizAnalytics();
  }

  void _fetchQuizAnalytics() {
    final categoryKey = widget.categoryKey;
    final storyId = widget.storyId;
    final userId = _resolveUserId();
    if (categoryKey == null || storyId == null || userId.isEmpty) {
      return;
    }
    _storiesController.fetchQuizAnalytics(
      categoryKey: categoryKey,
      storyId: storyId,
      userId: userId,
    );
  }

  String _resolveUserId() {
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  void _nextQuestion(int totalQuestions) {
    if (_currentQuestionIndex + 1 >= totalQuestions) {
      return;
    }
    setState(() {
      _currentQuestionIndex += 1;
    });
  }

  void _previousQuestion() {
    if (_currentQuestionIndex == 0) {
      return;
    }
    setState(() {
      _currentQuestionIndex -= 1;
    });
  }

  void _resetQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _selectedAnswers.clear();
    });
    _storiesController.quizResult.value = null;
  }

  @override
  void dispose() {
    _textLangSub?.cancel();
    _titleLangSub?.cancel();
    super.dispose();
  }

  Future<void> _submitQuiz(List<KidsStoryQuestion> questions) async {
    if (questions.isEmpty || _storiesController.isQuizSubmitting.value) {
      return;
    }
    if (_selectedAnswers.length < questions.length) {
      PLoaders.warningSnackBar(
        title: 'Incomplete',
        message: 'Please answer all questions before submitting.',
        context: context,
      );
      return;
    }
    final userId = _resolveUserId();
    if (userId.isEmpty) {
      PLoaders.warningSnackBar(
        title: 'Sign in required',
        message: 'Please sign in to submit your quiz.',
        context: context,
      );
      return;
    }

    final categoryKey = widget.categoryKey;
    final storyId = widget.storyId;
    if (categoryKey == null || storyId == null) {
      return;
    }

    final answers = questions.map((question) {
      final selectedOption = _selectedAnswers[question.id] ?? '';
      return KidsStoryQuizAnswer(
        questionId: question.id,
        selectedOption: selectedOption,
      );
    }).toList();

    if (answers.any((answer) => answer.selectedOption.isEmpty)) {
      PLoaders.warningSnackBar(
        title: 'Incomplete',
        message: 'Please answer all questions before submitting.',
        context: context,
      );
      return;
    }

    final result = await _storiesController.submitQuiz(
      categoryKey: categoryKey,
      storyId: storyId,
      answers: answers,
      userId: userId,
    );

    if (result == null || !mounted) {
      return;
    }

    final action = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => QuizSuccessScreen(
          result: result,
          storyTitle: widget.storyTitle ?? 'Kids Story Quiz',
          questions: questions,
        ),
      ),
    );

    _storiesController.quizResult.value = null;
    if (!mounted) {
      return;
    }

    if (action == 'retry') {
      _resetQuiz();
      return;
    }

    if (action == 'done') {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasStoryContext) {
      return _buildSelectionScaffold();
    }

    return _buildQuizScaffold();
  }

  Widget _buildSelectionScaffold() {
    final titleLanguageCode = AppLanguageHelper.titleLanguageCode();
    final titleDirection = TextDirectionUtils.directionFor(titleLanguageCode);
    final isTitleRtl = titleDirection == TextDirection.rtl;

    return Scaffold(
      backgroundColor: const Color(0xFFE9F3EF),
      appBar: const PAppBar(
        title: Text(
          'Quiz',
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF749BC2),
        showBackArrow: true,
      ),
      body: KidsScreenBackground(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Obx(() {
            if (_storiesController.isCategoriesLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (_storiesController.categories.isEmpty) {
              return const Center(child: Text('No categories available'));
            }
            return ListView(
              children: _storiesController.categories.map((category) {
                final title = AppLanguageHelper.pickText(
                  category.categoryTitle,
                  titleLanguageCode,
                );
                final displayTitle =
                    title.isNotEmpty ? title : category.categoryKey;
                return Directionality(
                  textDirection: titleDirection,
                  child: Card(
                    elevation: 4,
                    shadowColor:
                        const Color(0xFF526F83).withValues(alpha: 0.20),
                    surfaceTintColor: Colors.transparent,
                    color: Colors.white.withValues(alpha: 0.94),
                    clipBehavior: Clip.antiAlias,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.85),
                        width: 1.5,
                      ),
                    ),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                      iconColor: const Color(0xFF667799),
                      collapsedIconColor: const Color(0xFF667799),
                      backgroundColor: Colors.white.withValues(alpha: 0.55),
                      collapsedBackgroundColor: Colors.transparent,
                      shape: const RoundedRectangleBorder(
                        side: BorderSide.none,
                      ),
                      collapsedShape: const RoundedRectangleBorder(
                        side: BorderSide.none,
                      ),
                      title: Text(
                        displayTitle,
                        textDirection: titleDirection,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: const Color(0xFF273B47),
                          fontFamily: isTitleRtl ? 'Lateef' : 'Poppins',
                          fontSize: isTitleRtl ? 23 : 17,
                          height: isTitleRtl ? 1.35 : 1.3,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Align(
                        alignment: isTitleRtl
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            'Total stories: ${category.totalStories}',
                            style: const TextStyle(
                              color: Color(0xFF6E7F88),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      onExpansionChanged: (expanded) {
                        if (expanded) {
                          setState(() {
                            _selectedCategoryKey = category.categoryKey;
                          });
                          _storiesController.fetchStories(category.categoryKey);
                        }
                      },
                      children: [
                        _buildStoryList(
                          category.categoryKey,
                          titleLanguageCode,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildStoryList(String categoryKey, String titleLanguageCode) {
    if (_selectedCategoryKey != categoryKey) {
      return const SizedBox.shrink();
    }

    return Obx(() {
      final titleDirection = TextDirectionUtils.directionFor(titleLanguageCode);
      final isTitleRtl = titleDirection == TextDirection.rtl;
      if (_storiesController.isStoriesLoading.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Center(child: CircularProgressIndicator()),
        );
      }
      if (_storiesController.stories.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Center(child: Text('No stories available')),
        );
      }

      return Column(
        children: List.generate(_storiesController.stories.length, (index) {
          final story = _storiesController.stories[index];
          final storyTitle = AppLanguageHelper.pickText(
            story.title,
            titleLanguageCode,
          );
          final displayTitle =
              storyTitle.isNotEmpty ? storyTitle : 'Story ${index + 1}';
          final storyId = story.storyId > 0 ? story.storyId : index + 1;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
            child: Directionality(
              textDirection: titleDirection,
              child: Material(
                color: const Color(0xFFF2F7F6),
                borderRadius: BorderRadius.circular(16),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 5,
                  ),
                  leading: Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF82ADD2), Color(0xFF668FB7)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFF668FB7).withValues(alpha: 0.22),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        storyId.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    displayTitle,
                    textDirection: titleDirection,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: const Color(0xFF273B47),
                      fontFamily: isTitleRtl ? 'Lateef' : 'Poppins',
                      fontSize: isTitleRtl ? 21 : 15,
                      height: isTitleRtl ? 1.4 : 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuizScreen(
                          categoryKey: categoryKey,
                          storyId: storyId,
                          storyTitle: displayTitle,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        }),
      );
    });
  }

  Widget _buildQuizScaffold() {
    final textLanguageCode = AppLanguageHelper.textLanguageCode();
    final textDirection = TextDirectionUtils.directionFor(textLanguageCode);
    final isTextRtl = textDirection == TextDirection.rtl;
    final titleLanguageCode = AppLanguageHelper.titleLanguageCode();
    final titleDirection = TextDirectionUtils.directionFor(titleLanguageCode);
    final isTitleRtl = titleDirection == TextDirection.rtl;
    final appBarTitle = widget.storyTitle ?? 'Quiz';

    return Scaffold(
      backgroundColor: const Color(0xFFE9F3EF),
      appBar: PAppBar(
        title: Text(
          appBarTitle,
          textDirection: titleDirection,
          style: TextStyle(
            color: Colors.white,
            fontFamily: isTitleRtl ? 'Lateef' : 'Poppins',
            fontSize: isTitleRtl ? 29 : 25,
            height: isTitleRtl ? 1.25 : 1.2,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF749BC2),
        showBackArrow: true,
      ),
      body: KidsScreenBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Obx(() {
              if (_storiesController.isStoryDetailLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final detail = _storiesController.storyDetail.value;
              if (detail == null || detail.questions.isEmpty) {
                return const Center(child: Text('No quiz available'));
              }

              final questions = detail.questions;
              final currentIndex = _currentQuestionIndex < questions.length
                  ? _currentQuestionIndex
                  : 0;
              final question = questions[currentIndex];
              final questionText = AppLanguageHelper.pickText(
                question.question,
                textLanguageCode,
              );
              final displayQuestion = questionText.isNotEmpty
                  ? questionText
                  : 'Question ${currentIndex + 1}';
              final options = question.orderedOptions();

              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFFFFF), Color(0xFFF8FBFA)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.9),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF526F83).withValues(alpha: 0.18),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Flexible(
                      flex: 4,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFFFFFFF), Color(0xFFF1F6F8)],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(0xFF6B83A2),
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6B83A2)
                                  .withValues(alpha: 0.10),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 0,
                              left: isTextRtl ? null : 0,
                              right: isTextRtl ? 0 : null,
                              child: Container(
                                width: 56,
                                height: 54,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFFE48586),
                                      Color(0xFFD96F72),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(
                                      isTextRtl ? 0 : 14,
                                    ),
                                    topRight: Radius.circular(
                                      isTextRtl ? 14 : 0,
                                    ),
                                    bottomLeft: Radius.circular(
                                      isTextRtl ? 22 : 0,
                                    ),
                                    bottomRight: Radius.circular(
                                      isTextRtl ? 0 : 22,
                                    ),
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${currentIndex + 1}/${questions.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 20,
                                ),
                                child: Text(
                                  displayQuestion,
                                  textDirection: textDirection,
                                  style: TextStyle(
                                    fontFamily:
                                        isTextRtl ? 'Lateef' : 'Poppins',
                                    fontSize: isTextRtl ? 25 : 18,
                                    height: isTextRtl ? 1.45 : 1.4,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF263842),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      flex: 6,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            if (options.isEmpty)
                              const Text('No options available')
                            else
                              ...List.generate(options.length, (index) {
                                final option = options[index];
                                final optionText = AppLanguageHelper.pickText(
                                  option.text,
                                  textLanguageCode,
                                );
                                final displayOption = optionText.isNotEmpty
                                    ? optionText
                                    : option.key;

                                return Padding(
                                  padding: EdgeInsets.only(
                                      bottom:
                                          index == options.length - 1 ? 0 : 12),
                                  child: QuizOptionTile(
                                    optionNumber: index + 1,
                                    optionText: displayOption,
                                    textDirection: textDirection,
                                    isSelected: _selectedAnswers[question.id] ==
                                        option.key,
                                    onTap: () {
                                      setState(() {
                                        _selectedAnswers[question.id] =
                                            option.key;
                                      });
                                    },
                                  ),
                                );
                              }),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          IconButtonContainer(
                            iconPath: 'assets/icons/play-button-arrowhead.png',
                            backgroundColor: const Color(0xFFCAA5CB),
                            rotate90: true,
                            onTap: _currentQuestionIndex > 0
                                ? _previousQuestion
                                : null,
                          ),
                          IconButtonContainer(
                            iconPath: 'assets/icons/check.png',
                            backgroundColor: const Color(0xFFCAA5CB),
                            onTap: () => _submitQuiz(questions),
                          ),
                          IconButtonContainer(
                            iconPath: 'assets/icons/play-button-arrowhead.png',
                            backgroundColor: const Color(0xFFCAA5CB),
                            onTap: currentIndex + 1 < questions.length
                                ? () => _nextQuestion(questions.length)
                                : null,
                          ),
                          IconButtonContainer(
                            iconPath: 'assets/icons/refresh.png',
                            backgroundColor: const Color(0xFFE48586),
                            onTap: _resetQuiz,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_storiesController.quizError.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _storiesController.quizError.value,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
